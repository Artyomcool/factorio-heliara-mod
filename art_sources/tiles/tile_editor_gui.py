#!/usr/bin/env python3
"""
Tile texture editor — heliara mod.

Per-tile sprite layouts are derived from the actual Lua definitions:
  tile()    → 512×512:  16×1×1(64px) + 12×2×2(128px)
  tile_hd() → 1024×1024: 11×4×4(256px) + 16×1×1(64px,packed) + 16×2×2(128px)

Click a sprite to select it; edit overlays in the right panel.
"""

import sys, json, pathlib, shutil
import numpy as np
from PIL import Image

from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QHBoxLayout, QVBoxLayout,
    QGridLayout, QPushButton, QLabel, QScrollArea, QGroupBox,
    QMessageBox, QButtonGroup, QSlider, QComboBox,
    QDialog, QDialogButtonBox, QSpinBox,
)
from PyQt5.QtCore import Qt, QSize, QTimer, pyqtSignal, QRectF
from PyQt5.QtGui import QPixmap, QImage, QPainter, QColor, QIcon, QPen

# ── paths ─────────────────────────────────────────────────────────────────────

ROOT          = pathlib.Path(__file__).resolve().parents[2]
TEX_PATH      = ROOT / 'art_sources/weathered_siliceous_crust/textures/decal_source_texture.png'
TILE_DIR      = ROOT / 'heliara/graphics/terrain'
ORIGINALS_DIR = ROOT / 'art_sources/tiles/originals'
INDIVIDUAL    = ROOT / 'art_sources/weathered_siliceous_crust/masks/individual'
BATCH_PATHS   = [ROOT / f'art_sources/weathered_siliceous_crust/masks/batch{i:02d}_mask_2x2_1024.png'
                 for i in range(1, 5)]
STATE_PATH    = pathlib.Path(__file__).parent / 'tile_state.json'

# ── per-tile sprite layouts ───────────────────────────────────────────────────

def _sprites(x0, y0, count, per_row, px, label):
    return [(x0 + (i % per_row)*px, y0 + (i // per_row)*px, px, px, label)
            for i in range(count)]

# tile()  — 512×512
_LAYOUT_SIMPLE = {
    'sheet_w': 512, 'sheet_h': 512,
    'sprites': (
        _sprites(  0,   0, 16, 8,  64, '1×1') +   # 16 × 64×64
        _sprites(  0, 128, 12, 4, 128, '2×2')      # 12 × 128×128
    ),
}

# tile_hd()  — 1024×1024
# 11 × 4×4 (256px) at (0,0), 4/row → rows 0-1 have 4, row 2 has 3
# 16 × 1×1  (64px) at (768,512), 4/row → fits in 256×256 gap
# 16 × 2×2 (128px) at (0,768), 8/row → 2 rows
_LAYOUT_HD = {
    'sheet_w': 1024, 'sheet_h': 1024,
    'sprites': (
        _sprites(  0,   0, 11, 4, 256, '4×4') +
        _sprites(768, 512, 16, 4,  64, '1×1') +
        _sprites(  0, 768, 16, 8, 128, '2×2')
    ),
}

TILE_LAYOUTS = {
    'heliara_weathered_siliceous_crust': _LAYOUT_HD,
}
_SIMPLE_TILES = [
    'heliara_clay_shale', 'heliara_dust', 'heliara_ferocalcite_crust',
    'heliara_iron_carbon_slag', 'heliara_rusty_sand', 'heliara_silcrete_crust',
]
for _n in _SIMPLE_TILES:
    TILE_LAYOUTS[_n] = _LAYOUT_SIMPLE

TILE_NAMES = ['heliara_weathered_siliceous_crust'] + _SIMPLE_TILES

# Design-source backgrounds (used for viewing/editing; export still goes to game dir)
TILE_BG = {
    'heliara_weathered_siliceous_crust':
        ROOT / 'art_sources/weathered_siliceous_crust/textures/base_bg_a2.png',
}

LOW  = int(0.20 * 255)
HIGH = int(0.80 * 255)

STYLE = """
QWidget { background: #1e1e1e; color: #ddd; }
QPushButton {
    background: #2d2d2d; border: 1px solid #555; border-radius: 3px;
    color: #ccc; padding: 2px 8px;
}
QPushButton:hover   { background: #3c3c3c; border-color: #888; }
QPushButton:pressed { background: #1a1a1a; }
QPushButton:checked { background: #1f4a2a; border-color: #4a9a6a; color: #9dca9d; }
QSlider::groove:horizontal { height:4px; background:#333; border:1px solid #444; border-radius:2px; }
QSlider::handle:horizontal {
    background:#5a8a6a; width:14px; height:14px; margin:-5px 0; border-radius:7px;
}
QSlider::sub-page:horizontal { background:#2a5a3a; border-radius:2px; }
QGroupBox { border:1px solid #3a3a3a; border-radius:4px; margin-top:10px; color:#888; font-size:11px; }
QGroupBox::title { subcontrol-origin:margin; left:8px; padding:0 4px; }
QComboBox {
    background:#252525; border:1px solid #555; border-radius:3px;
    color:#ccc; padding:2px 6px; min-height:22px;
}
QComboBox:hover { border-color:#888; }
QScrollBar:vertical   { background:#1e1e1e; width:10px; border:none; }
QScrollBar:horizontal { background:#1e1e1e; height:10px; border:none; }
QScrollBar::handle:vertical, QScrollBar::handle:horizontal
    { background:#444; border-radius:5px; min-width:20px; min-height:20px; }
QScrollBar::add-line, QScrollBar::sub-line { width:0; height:0; }
"""

# ── mask loading ───────────────────────────────────────────────────────────────

def extract_quadrants(path):
    img = Image.open(path).convert('L'); w, h = img.size
    return [img.crop((0,0,w//2,h//2)), img.crop((w//2,0,w,h//2)),
            img.crop((0,h//2,w//2,h)), img.crop((w//2,h//2,w,h))]

def load_mask_groups():
    groups = [('Batch', [q for p in BATCH_PATHS for q in extract_quadrants(p)])]
    for prefix, label in [('slag16','Slag16'), ('step1','Step1')]:
        imgs = [Image.open(f).convert('L') for f in sorted(INDIVIDUAL.glob(f'{prefix}_*.png'))]
        if imgs: groups.append((label, imgs))
    return groups

# ── image helpers ──────────────────────────────────────────────────────────────

def build_mask(mask_pil, px_w, px_h, angle, flip_h, flip_v, scale=1.0):
    m = mask_pil
    if flip_h: m = m.transpose(Image.FLIP_LEFT_RIGHT)
    if flip_v: m = m.transpose(Image.FLIP_TOP_BOTTOM)
    m = m.rotate(angle, resample=Image.BILINEAR, expand=True)
    sw = max(1, int(px_w*scale)); sh = max(1, int(px_h*scale))
    m = m.resize((sw, sh), Image.LANCZOS)
    if scale > 1.0:
        m = m.crop(((sw-px_w)//2, (sh-px_h)//2, (sw-px_w)//2+px_w, (sh-px_h)//2+px_h))
    elif scale < 1.0:
        c = Image.new('L', (px_w, px_h), 0); c.paste(m, ((px_w-sw)//2, (px_h-sh)//2)); m = c
    arr = np.array(m, dtype=float); arr[0,:]=arr[-1,:]=arr[:,0]=arr[:,-1]=0
    return Image.fromarray(np.clip((arr-LOW)/(HIGH-LOW)*255, 0, 255).astype(np.uint8), 'L')


def make_overlay(mask_pil, px_w, px_h, angle, flip_h, flip_v,
                 tex_arr, bg_arr, cx, cy,
                 alpha_pct=100, blend_pct=0, tile_mean=None, scale=1.0, mx=0, my=0):
    mask = build_mask(mask_pil, px_w, px_h, angle, flip_h, flip_v, scale)
    if mx != 0 or my != 0:
        shifted = Image.new('L', (px_w, px_h), 0); shifted.paste(mask, (mx, my)); mask = shifted
    th, tw = tex_arr.shape[:2]
    cx = max(0, min(cx, tw-px_w)); cy = max(0, min(cy, th-px_h))
    mat = tex_arr[cy:cy+px_h, cx:cx+px_w].astype(float)
    if blend_pct > 0 and tile_mean is not None:
        f = blend_pct/100.0; mean = np.asarray(tile_mean, dtype=float)
        above = mat > mean[np.newaxis, np.newaxis, :]
        mat = np.clip(np.where(above, mat+(mean-mat)*f, mat), 0, 255)
    mask_arr = np.clip(np.array(mask, dtype=float)*(alpha_pct/100.0), 0, 255)
    m = mask_arr[:,:,np.newaxis]/255.0
    comp = np.clip(bg_arr.astype(float)*(1-m)+mat*m, 0, 255).astype(np.uint8)
    mat_u8 = np.clip(mat, 0, 255).astype(np.uint8)
    rgba = Image.merge('RGBA', [Image.fromarray(mat_u8[:,:,i],'L') for i in range(3)]
                               + [Image.fromarray(mask_arr.astype(np.uint8),'L')])
    return rgba, Image.fromarray(comp)


def pil_to_qpixmap(img):
    img = img.convert('RGB'); data = img.tobytes('raw','RGB')
    qi = QImage(data, img.width, img.height, img.width*3, QImage.Format_RGB888)
    return QPixmap.fromImage(qi)

# ── Sheet canvas ───────────────────────────────────────────────────────────────

class SheetCanvas(QWidget):
    spriteClicked = pyqtSignal(int)

    ZOOM_STEPS = [0.20, 0.25, 0.33, 0.5, 0.67, 1.0, 1.5, 2.0]

    def __init__(self, parent=None):
        super().__init__(parent)
        self._arr      = None
        self._sprites  = []      # list of (x,y,w,h,label)
        self._sheet_w  = 512
        self._sheet_h  = 512
        self._zidx     = 3       # 0.5×
        self._selected = -1
        self.setCursor(Qt.PointingHandCursor)

    @property
    def zoom(self): return self.ZOOM_STEPS[self._zidx]

    def zoom_in(self):
        if self._zidx < len(self.ZOOM_STEPS)-1: self._zidx += 1; self._resize(); self.update()
    def zoom_out(self):
        if self._zidx > 0:                      self._zidx -= 1; self._resize(); self.update()

    def _resize(self):
        z = self.zoom
        self.setFixedSize(max(1, int(self._sheet_w*z)), max(1, int(self._sheet_h*z)))

    def set_layout(self, layout):
        self._sheet_w = layout['sheet_w']
        self._sheet_h = layout['sheet_h']
        self._sprites = layout['sprites']
        self._selected = -1
        self._resize()

    def set_sheet(self, arr):
        self._arr = arr; self.update()

    def set_selected(self, idx):
        self._selected = idx; self.update()

    def paintEvent(self, _e):
        p = QPainter(self); z = self.zoom
        w = max(1, int(self._sheet_w*z)); h = max(1, int(self._sheet_h*z))

        if self._arr is not None:
            rsmp = Image.NEAREST if z >= 1.0 else Image.LANCZOS
            img  = Image.fromarray(self._arr).resize((w, h), rsmp)
            data = img.tobytes('raw','RGB')
            qi   = QImage(data, w, h, w*3, QImage.Format_RGB888)
            p.drawPixmap(0, 0, QPixmap.fromImage(qi))
        else:
            p.fillRect(0, 0, w, h, QColor(30,30,30))

        for i, (sx, sy, sw, sh, gn) in enumerate(self._sprites):
            x0, y0 = int(sx*z), int(sy*z)
            x1, y1 = int((sx+sw)*z)-1, int((sy+sh)*z)-1
            if i == self._selected:
                p.setPen(QPen(QColor(80,220,110), 2))
            else:
                col = {'1×1': QColor(200,60,60), '2×2': QColor(60,120,200),
                       '4×4': QColor(200,160,40)}.get(gn, QColor(200,60,60))
                p.setPen(QPen(col, 1))
            p.drawRect(x0, y0, x1-x0, y1-y0)
        p.end()

    def mousePressEvent(self, e):
        if e.button() != Qt.LeftButton: return
        z = self.zoom; px = int(e.x()/z); py = int(e.y()/z)
        for i, (sx, sy, sw, sh, gn) in enumerate(self._sprites):
            if sx <= px < sx+sw and sy <= py < sy+sh:
                self._selected = i; self.update(); self.spriteClicked.emit(i); return

    def wheelEvent(self, e):
        if e.modifiers() & Qt.ControlModifier:
            (self.zoom_in if e.angleDelta().y() > 0 else self.zoom_out)(); e.accept()
        else: super().wheelEvent(e)


class SheetView(QScrollArea):
    spriteClicked = pyqtSignal(int)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._canvas = SheetCanvas()
        self._canvas.spriteClicked.connect(self.spriteClicked)
        self.setWidget(self._canvas); self.setWidgetResizable(False)
        self.setStyleSheet('QScrollArea{background:#111;border:none;}')

    def set_layout(self, layout):  self._canvas.set_layout(layout)
    def set_sheet(self, arr):      self._canvas.set_sheet(arr)
    def set_selected(self, idx):   self._canvas.set_selected(idx)
    def zoom_in(self):             self._canvas.zoom_in()
    def zoom_out(self):            self._canvas.zoom_out()
    def zoom_label(self):          return f'{int(self._canvas.zoom*100)}%'

    def wheelEvent(self, e):
        if e.modifiers() & Qt.ControlModifier:
            (self._canvas.zoom_in if e.angleDelta().y() > 0 else self._canvas.zoom_out)()
            e.accept()
        else: super().wheelEvent(e)

# ── Texture crop widget ───────────────────────────────────────────────────────

class TextureCropWidget(QWidget):
    """Shows source texture; drag to set crop position (cx, cy)."""
    posChanged = pyqtSignal(int, int)

    def __init__(self, tex_pil, dpw, dph, cx, cy, parent=None):
        super().__init__(parent)
        self._tex_pil = tex_pil; self._dpw = dpw; self._dph = dph
        self._cx = cx; self._cy = cy
        self._tex_w, self._tex_h = tex_pil.size
        self._dragging = False; self._drag_start = None; self._qpix = None
        self.setCursor(Qt.OpenHandCursor); self.setMinimumSize(200, 100)

    def _make_qpix(self):
        if self._qpix is None: self._qpix = pil_to_qpixmap(self._tex_pil)
        return self._qpix

    def _sf_ofs(self):
        sf = min(self.width()/self._tex_w, self.height()/self._tex_h)
        return sf, (self.width()-self._tex_w*sf)/2, (self.height()-self._tex_h*sf)/2

    def paintEvent(self, _e):
        p = QPainter(self); p.setRenderHint(QPainter.SmoothPixmapTransform)
        sf, ox, oy = self._sf_ofs()
        p.drawPixmap(QRectF(ox, oy, self._tex_w*sf, self._tex_h*sf).toRect(), self._make_qpix())
        rx = ox+self._cx*sf; ry = oy+self._cy*sf
        rw = self._dpw*sf;   rh = self._dph*sf
        tw = self._tex_w*sf; th = self._tex_h*sf
        p.setBrush(QColor(0,0,0,120)); p.setPen(Qt.NoPen)
        def fill(x, y, w, h):
            if w>0 and h>0: p.drawRect(int(x), int(y), int(w+.5)+1, int(h+.5)+1)
        fill(ox,    oy,    tw,          ry-oy)
        fill(ox,    ry+rh, tw,          oy+th-ry-rh)
        fill(ox,    ry,    rx-ox,       rh)
        fill(rx+rw, ry,    ox+tw-rx-rw, rh)
        p.setBrush(Qt.NoBrush); p.setPen(QPen(QColor(100,200,130), 2))
        p.drawRect(int(rx), int(ry), int(rw), int(rh)); p.end()

    def mousePressEvent(self, e):
        if e.button()==Qt.LeftButton:
            self._dragging=True; self._drag_start=(e.x(),e.y(),self._cx,self._cy)
            self.setCursor(Qt.ClosedHandCursor)

    def mouseReleaseEvent(self, e):
        if e.button()==Qt.LeftButton: self._dragging=False; self.setCursor(Qt.OpenHandCursor)

    def mouseMoveEvent(self, e):
        if not self._dragging: return
        sf,_,_ = self._sf_ofs(); mx0,my0,cx0,cy0 = self._drag_start
        cx = max(0, min(int(round(cx0+(e.x()-mx0)/sf)), self._tex_w-self._dpw))
        cy = max(0, min(int(round(cy0+(e.y()-my0)/sf)), self._tex_h-self._dph))
        if cx!=self._cx or cy!=self._cy:
            self._cx=cx; self._cy=cy; self.posChanged.emit(cx,cy); self.update()

    def set_pos(self, cx, cy):
        self._cx=max(0,min(cx,self._tex_w-self._dpw))
        self._cy=max(0,min(cy,self._tex_h-self._dph)); self.update()


# ── Draggable preview label ───────────────────────────────────────────────────

class DraggablePreview(QLabel):
    """Preview label; drag moves the overlay (emits delta in canvas pixels)."""
    deltaDragged = pyqtSignal(int, int)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._scale = 1.0; self._drag_start = None
        self.setCursor(Qt.OpenHandCursor)

    def set_scale(self, s): self._scale = max(s, 0.01)

    def mousePressEvent(self, e):
        if e.button() == Qt.LeftButton:
            self._drag_start = (e.x(), e.y()); self.setCursor(Qt.ClosedHandCursor)

    def mouseReleaseEvent(self, e):
        if e.button() == Qt.LeftButton:
            self._drag_start = None; self.setCursor(Qt.OpenHandCursor)

    def mouseMoveEvent(self, e):
        if self._drag_start is None: return
        dx = e.x() - self._drag_start[0]; dy = e.y() - self._drag_start[1]
        self._drag_start = (e.x(), e.y())
        dcx = int(round(dx / self._scale)); dcy = int(round(dy / self._scale))
        if dcx or dcy: self.deltaDragged.emit(dcx, dcy)


# ── Overlay edit dialog ────────────────────────────────────────────────────────

class OverlayEditDialog(QDialog):
    PREV = 240; MASK_BTN = 38

    def __init__(self, overlay, tex_arr, bg_arr, tile_mean, mask_groups, parent=None):
        super().__init__(parent)
        self.setWindowTitle('Оверлей'); self.setModal(True); self.setMinimumSize(760, 680)
        self._w   = dict(overlay)
        self._tex = tex_arr; self._bg = bg_arr; self._mean = tile_mean
        self._deb = QTimer(self); self._deb.setSingleShot(True); self._deb.timeout.connect(self._regen)
        self._build_ui(mask_groups); self._regen()

    def _build_ui(self, mask_groups):
        root = QVBoxLayout(self); root.setSpacing(8)
        top  = QWidget(); tl = QHBoxLayout(top); tl.setContentsMargins(0,0,0,0); tl.setSpacing(8)

        # Left column: render preview + texture drag
        left = QWidget(); lcl = QVBoxLayout(left); lcl.setContentsMargins(0,0,0,0); lcl.setSpacing(4)
        left.setFixedWidth(self.PREV)

        self._prev = DraggablePreview(); self._prev.setFixedSize(self.PREV, self.PREV)
        self._prev.setAlignment(Qt.AlignCenter)
        self._prev.setStyleSheet('background:#111; cursor:openhand;')
        self._prev.deltaDragged.connect(self._on_prev_drag)
        lcl.addWidget(self._prev)

        hint_prev = QLabel('⠿ Тащи превью — двигает оверлей')
        hint_prev.setStyleSheet('color:#555; font-size:9px;'); lcl.addWidget(hint_prev)

        hint = QLabel('⠿ Тащи текстуру — позиция кропа')
        hint.setStyleSheet('color:#555; font-size:9px;'); lcl.addWidget(hint)

        w = self._w; cw = w.get('canvas_w', 128); ch = w.get('canvas_h', 128)
        tex_pil = Image.fromarray(self._tex.astype(np.uint8))
        self._tex_drag = TextureCropWidget(tex_pil, cw, ch, w.get('cx',0), w.get('cy',0))
        self._tex_drag.posChanged.connect(self._on_tex_drag)
        lcl.addWidget(self._tex_drag, stretch=1)
        tl.addWidget(left)

        # Right: mask selector
        mbox = QGroupBox('Маска'); ml = QVBoxLayout(mbox); ml.setContentsMargins(4,4,4,4)
        mscroll = QScrollArea(); mscroll.setWidgetResizable(True)
        minner = QWidget(); mgrid = QVBoxLayout(minner)
        mgrid.setContentsMargins(2,2,2,2); mgrid.setSpacing(2)
        self._mask_grp = QButtonGroup(self); self._mask_grp.setExclusive(True)
        self._all_masks = []; cur = w.get('mask'); idx = 0; MCOLS = 6
        for grp_name, masks in mask_groups:
            hdr = QLabel(f'── {grp_name} ──')
            hdr.setStyleSheet('color:#555; font-size:9px; margin-top:3px;')
            mgrid.addWidget(hdr)
            row_w = QWidget(); row_l = QHBoxLayout(row_w)
            row_l.setContentsMargins(0,0,0,0); row_l.setSpacing(2); col = 0
            for m in masks:
                arr = np.array(m.resize((self.MASK_BTN-4, self.MASK_BTN-4), Image.LANCZOS), dtype=float)
                arr = np.clip((arr-LOW)/(HIGH-LOW)*255, 0, 255).astype(np.uint8)
                pm  = pil_to_qpixmap(Image.fromarray(arr,'L').convert('RGB'))
                btn = QPushButton(); btn.setCheckable(True); btn.setChecked(m is cur)
                btn.setFixedSize(self.MASK_BTN, self.MASK_BTN)
                btn.setIcon(QIcon(pm)); btn.setIconSize(QSize(self.MASK_BTN-4, self.MASK_BTN-4))
                self._mask_grp.addButton(btn, idx); row_l.addWidget(btn)
                self._all_masks.append(m); idx += 1; col += 1
                if col == MCOLS:
                    mgrid.addWidget(row_w); row_w = QWidget(); row_l = QHBoxLayout(row_w)
                    row_l.setContentsMargins(0,0,0,0); row_l.setSpacing(2); col = 0
            if col > 0: row_l.addStretch(); mgrid.addWidget(row_w)
        mgrid.addStretch()
        self._mask_grp.buttonClicked.connect(lambda b: self._pick(self._mask_grp.id(b)))
        mscroll.setWidget(minner); ml.addWidget(mscroll)
        tl.addWidget(mbox, stretch=1)
        root.addWidget(top, stretch=1)

        # Params grid
        pg = QWidget(); pgl = QGridLayout(pg); pgl.setColumnStretch(1,1); pgl.setSpacing(4)
        th, tw = self._tex.shape[:2]

        def row(r, lbl, lo, hi, val, suf, key, sc=1):
            pgl.addWidget(QLabel(lbl), r, 0)
            sl = QSlider(Qt.Horizontal)
            sl.blockSignals(True); sl.setRange(lo, hi); sl.setValue(val); sl.blockSignals(False)
            vl = QLabel(f'{val}{suf}'); vl.setFixedWidth(54); vl.setAlignment(Qt.AlignRight|Qt.AlignVCenter)
            sl.valueChanged.connect(lambda v, l=vl, s=suf, k=key, sc_=sc:
                (l.setText(f'{v}{s}'), w.__setitem__(k, v/sc_ if sc_!=1 else v), self._deb.start(60)))
            cw2 = QWidget(); cl2 = QHBoxLayout(cw2); cl2.setContentsMargins(0,0,0,0); cl2.setSpacing(0)
            cl2.addWidget(sl); cl2.addWidget(vl); pgl.addWidget(cw2, r, 1)
            return sl, vl

        row(0,'Угол:',    0,359, int(w.get('angle',0))%360,        '°', 'angle')
        self._sl_cx, self._vl_cx = row(1,'Поз X:', 0,max(0,tw-cw), w.get('cx',0),  '', 'cx')
        self._sl_cy, self._vl_cy = row(2,'Поз Y:', 0,max(0,th-ch), w.get('cy',0),  '', 'cy')
        self._sl_mx, self._vl_mx = row(3,'Маска X:', -(cw-1), cw-1, w.get('mx', 0), '', 'mx')
        self._sl_my, self._vl_my = row(4,'Маска Y:', -(ch-1), ch-1, w.get('my', 0), '', 'my')
        row(5,'Масштаб:', 10,300, int(w.get('scale',1.0)*100),      '%', 'scale', sc=100)
        row(6,'Alpha:',   0,1000, w.get('ov_alpha',100),            '%', 'ov_alpha')
        row(7,'Blend:',   0,100,  w.get('ov_blend',  0),            '%', 'ov_blend')

        # Sync position sliders → tex_drag
        self._sl_cx.valueChanged.connect(lambda v: self._tex_drag.set_pos(v, self._w.get('cy',0)))
        self._sl_cy.valueChanged.connect(lambda v: self._tex_drag.set_pos(self._w.get('cx',0), v))

        fr = QWidget(); fl = QHBoxLayout(fr); fl.setContentsMargins(0,0,0,0); fl.setSpacing(4)
        self._fh = QPushButton('↔ Flip H'); self._fh.setCheckable(True); self._fh.setChecked(w.get('flip_h',False))
        self._fv = QPushButton('↕ Flip V'); self._fv.setCheckable(True); self._fv.setChecked(w.get('flip_v',False))
        self._fh.toggled.connect(lambda v: (w.__setitem__('flip_h',v), self._deb.start(60)))
        self._fv.toggled.connect(lambda v: (w.__setitem__('flip_v',v), self._deb.start(60)))
        fl.addWidget(self._fh); fl.addWidget(self._fv); fl.addStretch()
        pgl.addWidget(QLabel('Отражение:'),8,0); pgl.addWidget(fr,8,1)
        root.addWidget(pg)

        bb = QDialogButtonBox(QDialogButtonBox.Ok|QDialogButtonBox.Cancel)
        bb.accepted.connect(self.accept); bb.rejected.connect(self.reject)
        root.addWidget(bb)

    def _pick(self, idx): self._w['mask'] = self._all_masks[idx]; self._deb.start(60)

    def _on_prev_drag(self, dcx, dcy):
        w = self._w; cw = w.get('canvas_w', 128); ch = w.get('canvas_h', 128)
        mx = max(-(cw-1), min(w.get('mx', 0) + dcx, cw-1))
        my = max(-(ch-1), min(w.get('my', 0) + dcy, ch-1))
        if mx == w.get('mx', 0) and my == w.get('my', 0): return
        w['mx'] = mx; w['my'] = my
        self._sl_mx.blockSignals(True); self._sl_mx.setValue(mx); self._sl_mx.blockSignals(False)
        self._sl_my.blockSignals(True); self._sl_my.setValue(my); self._sl_my.blockSignals(False)
        self._vl_mx.setText(str(mx)); self._vl_my.setText(str(my))
        self._deb.start(30)

    def _on_tex_drag(self, cx, cy):
        self._w['cx'] = cx; self._w['cy'] = cy
        self._sl_cx.blockSignals(True); self._sl_cx.setValue(cx); self._sl_cx.blockSignals(False)
        self._sl_cy.blockSignals(True); self._sl_cy.setValue(cy); self._sl_cy.blockSignals(False)
        self._vl_cx.setText(str(cx)); self._vl_cy.setText(str(cy))
        self._deb.start(60)

    _PREV_PAD = 22  # pixels of margin around sprite in preview (for oob mask)

    def _regen(self):
        d = self._w; cw = d.get('canvas_w',128); ch = d.get('canvas_h',128)
        mx = d.get('mx', 0); my = d.get('my', 0)
        bh, bw = self._bg.shape[:2]
        bg = self._bg[:min(ch,bh), :min(cw,bw)]
        if bg.shape[:2] != (ch, cw):
            pad = np.zeros((ch, cw, 3), dtype=np.uint8)
            pad[:bg.shape[0], :bg.shape[1]] = bg; bg = pad
        _, preview = make_overlay(d['mask'], cw, ch, d.get('angle',0), d.get('flip_h',False),
                                  d.get('flip_v',False), self._tex, bg, d.get('cx',0), d.get('cy',0),
                                  d.get('ov_alpha',100), d.get('ov_blend',0), self._mean,
                                  d.get('scale',1.0), mx=mx, my=my)
        inner = self.PREV - 2*self._PREV_PAD
        s = min(inner/cw, inner/ch)
        sw = max(1, int(cw*s)); sh = max(1, int(ch*s))
        ox = (self.PREV - sw)//2; oy = (self.PREV - sh)//2

        ext = np.full((self.PREV, self.PREV, 3), 28, dtype=np.uint8)
        ext[oy:oy+sh, ox:ox+sw] = np.array(preview.resize((sw, sh), Image.LANCZOS))
        # sprite border
        for bx, by, bw2, bh2 in [(ox-1,oy-1,sw+2,1),(ox-1,oy+sh,sw+2,1),
                                   (ox-1,oy-1,1,sh+2),(ox+sw,oy-1,1,sh+2)]:
            bx = max(0, bx); by = max(0, by)
            bw2 = min(bw2, self.PREV-bx); bh2 = min(bh2, self.PREV-by)
            if bw2>0 and bh2>0: ext[by:by+bh2, bx:bx+bw2] = [140,140,140]

        # blue highlight for out-of-bounds mask
        if mx != 0 or my != 0:
            raw = build_mask(d['mask'], cw, ch, d.get('angle',0), d.get('flip_h',False),
                             d.get('flip_v',False), d.get('scale',1.0))
            raw_sc = np.array(raw.resize((sw, sh), Image.LANCZOS), dtype=float) / 255.0
            mx_sc = int(round(mx*s)); my_sc = int(round(my*s))
            # place mask in ext coords
            m_y0 = oy+my_sc; m_x0 = ox+mx_sc
            m_full = np.zeros((self.PREV, self.PREV), dtype=float)
            sy0=max(0,-m_y0); sx0=max(0,-m_x0)
            dy0=max(0,m_y0);  dx0=max(0,m_x0)
            dy1=min(self.PREV,m_y0+sh); dx1=min(self.PREV,m_x0+sw)
            sy1=sy0+(dy1-dy0); sx1=sx0+(dx1-dx0)
            if dy0<dy1 and dx0<dx1: m_full[dy0:dy1,dx0:dx1] = raw_sc[sy0:sy1,sx0:sx1]
            # sprite region mask
            sp = np.zeros((self.PREV,self.PREV),dtype=bool)
            sp[oy:oy+sh,ox:ox+sw] = True
            oob = m_full * (~sp).astype(float)
            a = (oob * 0.85)[:,:,np.newaxis]
            blue = np.array([0,80,255],dtype=float)
            ext = np.clip(ext.astype(float)*(1-a) + blue*a, 0, 255).astype(np.uint8)

        self._prev.set_scale(s)
        self._prev.setPixmap(pil_to_qpixmap(Image.fromarray(ext)))

    def result(self): return self._w

# ── Sprite editor (right panel) ───────────────────────────────────────────────

class SpriteEditor(QWidget):
    changed       = pyqtSignal(int)
    weightChanged = pyqtSignal(int, int)
    PREV = 256

    def __init__(self, tex_arr, mask_groups, parent=None):
        super().__init__(parent)
        self._tex   = tex_arr; self._masks = mask_groups
        self._idx   = -1; self._base = None; self._ovs = []; self._mean = None
        self.setFixedWidth(300); self._build_ui()

    def _build_ui(self):
        lay = QVBoxLayout(self); lay.setContentsMargins(6,6,6,6); lay.setSpacing(6)
        self._info = QLabel('Выберите спрайт')
        self._info.setStyleSheet('color:#888; font-size:10px;'); lay.addWidget(self._info)
        self._prev = QLabel(); self._prev.setFixedSize(self.PREV, self.PREV)
        self._prev.setAlignment(Qt.AlignCenter)
        self._prev.setStyleSheet('border:1px solid #444; background:#111;')
        lay.addWidget(self._prev, alignment=Qt.AlignHCenter)

        wrow = QWidget(); wl = QHBoxLayout(wrow)
        wl.setContentsMargins(0,0,0,0); wl.setSpacing(6)
        wl.addWidget(QLabel('Вес:'))
        self._w_spin = QSpinBox()
        self._w_spin.setRange(1, 10000); self._w_spin.setValue(100)
        self._w_spin.setFixedWidth(80)
        self._w_spin.valueChanged.connect(lambda v: self.weightChanged.emit(self._idx, v))
        wl.addWidget(self._w_spin); wl.addStretch()
        lay.addWidget(wrow)

        ov_grp = QGroupBox('Оверлеи'); ovl = QVBoxLayout(ov_grp); ovl.setContentsMargins(4,8,4,4)
        self._ov_scroll = QScrollArea(); self._ov_scroll.setWidgetResizable(True)
        self._ov_scroll.setFixedHeight(120)
        self._ov_w = QWidget(); self._ov_l = QHBoxLayout(self._ov_w)
        self._ov_l.setContentsMargins(2,2,2,2); self._ov_l.setSpacing(4); self._ov_l.addStretch()
        self._ov_scroll.setWidget(self._ov_w); ovl.addWidget(self._ov_scroll); lay.addWidget(ov_grp)
        add_btn = QPushButton('+ Добавить оверлей'); add_btn.clicked.connect(self._add)
        lay.addWidget(add_btn)
        reset_btn = QPushButton('↺ Сбросить к оригиналу')
        reset_btn.setStyleSheet('QPushButton{color:#f88;} QPushButton:hover{color:#faa;}')
        reset_btn.clicked.connect(self._reset); lay.addWidget(reset_btn); lay.addStretch()

    def load_sprite(self, idx, base_arr, overlays, tile_mean, sprite_info, weight=100):
        self._idx = idx; self._base = base_arr.copy()
        self._ovs = list(overlays); self._mean = tile_mean
        self._w_spin.blockSignals(True); self._w_spin.setValue(weight); self._w_spin.blockSignals(False)
        sx, sy, sw, sh, gn = sprite_info
        self._info.setText(f'Спрайт #{idx}  ({gn}, {sw}×{sh} px)  @({sx},{sy})')
        self._refresh_preview(); self._refresh_ov_list()

    def get_weight(self): return self._w_spin.value()

    def _result_arr(self):
        if self._base is None: return None
        arr = self._base.copy()
        for ov in self._ovs:
            _, comp = make_overlay(ov['mask'], arr.shape[1], arr.shape[0],
                                   ov['angle'], ov['flip_h'], ov['flip_v'],
                                   self._tex, arr, ov['cx'], ov['cy'],
                                   ov['ov_alpha'], ov['ov_blend'],
                                   arr.mean(axis=(0,1)), ov['scale'],
                                   mx=ov.get('mx',0), my=ov.get('my',0))
            arr = np.array(comp)
        return arr

    def _refresh_preview(self):
        arr = self._result_arr()
        if arr is None: self._prev.setPixmap(QPixmap()); return
        img = Image.fromarray(arr)
        s   = min(self.PREV/img.width, self.PREV/img.height)
        img = img.resize((max(1,int(img.width*s)), max(1,int(img.height*s))), Image.NEAREST)
        self._prev.setPixmap(pil_to_qpixmap(img))

    def _refresh_ov_list(self):
        while self._ov_l.count() > 1:
            item = self._ov_l.takeAt(0)
            if item.widget(): item.widget().deleteLater()
        if self._base is None: return
        tw = min(self._base.shape[1], 64); th = min(self._base.shape[0], 64)
        bg = self._base[:th, :tw]
        for i, ov in enumerate(self._ovs):
            _, prev = make_overlay(ov['mask'], tw, th, ov['angle'], ov['flip_h'], ov['flip_v'],
                                   self._tex, bg,
                                   min(ov['cx'], self._tex.shape[1]-tw),
                                   min(ov['cy'], self._tex.shape[0]-th),
                                   ov['ov_alpha'], ov['ov_blend'], self._mean, ov['scale'])
            cell = QWidget(); cl = QVBoxLayout(cell); cl.setContentsMargins(2,2,2,2); cl.setSpacing(2)
            lbl = QLabel(); lbl.setFixedSize(60,60); lbl.setAlignment(Qt.AlignCenter)
            lbl.setStyleSheet('border:1px solid #555;')
            lbl.setPixmap(pil_to_qpixmap(prev.resize((60,60), Image.NEAREST)))
            lbl.setCursor(Qt.PointingHandCursor); lbl.setToolTip('Двойной клик — редактировать')
            lbl.mouseDoubleClickEvent = lambda _e, ii=i: self._edit(ii)
            del_btn = QPushButton('✕'); del_btn.setFixedSize(18,14)
            del_btn.setStyleSheet('QPushButton{color:#f66;font-size:8px;border:1px solid #533;}')
            del_btn.clicked.connect(lambda _, ii=i: self._del(ii))
            cl.addWidget(lbl); cl.addWidget(del_btn, alignment=Qt.AlignHCenter)
            self._ov_l.insertWidget(i, cell)

    def _open_dlg(self, init):
        if self._idx < 0 or self._base is None: return None
        dlg = OverlayEditDialog(init, self._tex, self._base, self._mean, self._masks, parent=self)
        return dlg if dlg.exec_() == QDialog.Accepted else None

    def _add(self):
        if self._idx < 0 or self._base is None: return
        h, w = self._base.shape[:2]
        flat = [m for _,ms in self._masks for m in ms]
        init = {'mask': flat[0], 'angle': 0, 'flip_h': False, 'flip_v': False,
                'cx': 0, 'cy': 0, 'scale': 1.0, 'ov_alpha': 100, 'ov_blend': 0,
                'canvas_w': w, 'canvas_h': h}
        dlg = self._open_dlg(init)
        if dlg:
            res = dlg.result(); res['canvas_w'] = w; res['canvas_h'] = h
            self._ovs.append(res)
            self._refresh_preview(); self._refresh_ov_list(); self.changed.emit(self._idx)

    def _edit(self, i):
        dlg = self._open_dlg(dict(self._ovs[i]))
        if dlg:
            self._ovs[i].update(dlg.result())
            self._refresh_preview(); self._refresh_ov_list(); self.changed.emit(self._idx)

    def _del(self, i):
        self._ovs.pop(i)
        self._refresh_preview(); self._refresh_ov_list(); self.changed.emit(self._idx)

    def _reset(self):
        if not self._ovs: return
        if QMessageBox.question(self,'Сбросить?','Убрать все оверлеи этого спрайта?',
                                QMessageBox.Yes|QMessageBox.No) == QMessageBox.Yes:
            self._ovs.clear()
            self._refresh_preview(); self._refresh_ov_list(); self.changed.emit(self._idx)

    def get_overlays(self): return list(self._ovs)

# ── Main window ───────────────────────────────────────────────────────────────

class TileEditor(QMainWindow):

    def __init__(self):
        super().__init__()
        self.setWindowTitle('Tile Editor — Heliara')
        self.resize(1400, 900)
        ORIGINALS_DIR.mkdir(parents=True, exist_ok=True)
        self.tex_arr     = np.array(Image.open(TEX_PATH).convert('RGB'))
        self.mask_groups = load_mask_groups()
        self._tile_overlays: dict = {}  # {tile: {sprite_idx: [overlay_dicts]}}
        self._tile_weights:  dict = {}  # {tile: {sprite_idx: int}}
        self._originals:     dict = {}  # {tile: np.array}
        self._current  = TILE_NAMES[0]
        self._selected = -1
        self._build_ui()
        self._switch_tile(TILE_NAMES[0])
        self._load_state()

    def _build_ui(self):
        root = QWidget(); self.setCentralWidget(root)
        root.setStyleSheet('background:#1e1e1e; color:#ddd;')
        ml = QVBoxLayout(root); ml.setContentsMargins(8,8,8,4); ml.setSpacing(6)

        top = QWidget(); tl = QHBoxLayout(top); tl.setContentsMargins(0,0,0,0); tl.setSpacing(8)
        tl.addWidget(QLabel('Тайл:'))
        self._cb = QComboBox()
        for n in TILE_NAMES: self._cb.addItem(n.replace('heliara_',''))
        self._cb.currentIndexChanged.connect(lambda i: self._switch_tile(TILE_NAMES[i]))
        self._cb.setFixedWidth(240); tl.addWidget(self._cb)
        zm = QPushButton('−'); zp = QPushButton('+'); zm.setFixedSize(26,26); zp.setFixedSize(26,26)
        self._zlbl = QLabel('50%'); self._zlbl.setFixedWidth(42); self._zlbl.setAlignment(Qt.AlignCenter)
        zm.clicked.connect(lambda: (self._view.zoom_out(), self._zlbl.setText(self._view.zoom_label())))
        zp.clicked.connect(lambda: (self._view.zoom_in(),  self._zlbl.setText(self._view.zoom_label())))
        tl.addWidget(zm); tl.addWidget(self._zlbl); tl.addWidget(zp); tl.addStretch()
        rev = QPushButton('↺ Откатить тайл'); rev.setFixedHeight(28)
        rev.setStyleSheet('color:#f88; border-color:#633; padding:0 10px;')
        rev.clicked.connect(self._revert_tile); tl.addWidget(rev)
        exp = QPushButton('⚡  Экспортировать'); exp.setFixedHeight(28)
        exp.setStyleSheet('font-weight:bold; padding:0 14px;'); exp.clicked.connect(self._export)
        tl.addWidget(exp); ml.addWidget(top)

        mid = QWidget(); midl = QHBoxLayout(mid); midl.setContentsMargins(0,0,0,0); midl.setSpacing(8)
        ml.addWidget(mid, stretch=1)
        self._view = SheetView()
        self._view.spriteClicked.connect(self._on_sprite_click)
        midl.addWidget(self._view, stretch=1)
        self._editor = SpriteEditor(self.tex_arr, self.mask_groups)
        self._editor.changed.connect(self._on_sprite_changed)
        self._editor.weightChanged.connect(self._on_weight_changed)
        midl.addWidget(self._editor)

        bot = QWidget(); bl = QHBoxLayout(bot); bl.setContentsMargins(0,2,0,2)
        self._status = QLabel(''); self._status.setStyleSheet('color:#888; font-size:10px;')
        bl.addWidget(self._status, stretch=1); ml.addWidget(bot)

    def _switch_tile(self, name):
        if self._selected >= 0:
            self._tile_overlays.setdefault(self._current, {})[self._selected] = \
                self._editor.get_overlays()
            self._tile_weights.setdefault(self._current, {})[self._selected] = \
                self._editor.get_weight()
        self._current = name; self._selected = -1
        if name not in self._originals:
            self._originals[name] = self._load_original(name)
        if name not in self._tile_overlays:
            self._tile_overlays[name] = {}
        layout = TILE_LAYOUTS[name]
        self._view.set_layout(layout)
        self._view.set_sheet(self._build_result(name))
        self._view.set_selected(-1)
        n = len(layout['sprites'])
        self._status.setText(f'{name}  —  {layout["sheet_w"]}×{layout["sheet_h"]}, {n} спрайтов')

    def _load_original(self, name):
        layout = TILE_LAYOUTS[name]
        ew, eh = layout['sheet_w'], layout['sheet_h']

        # Design-source background has priority (not backed up — it's a source asset)
        bg_path = TILE_BG.get(name)
        if bg_path and bg_path.exists():
            img = np.array(Image.open(bg_path).convert('RGB'))
            if img.shape[:2] == (eh, ew):
                return img
            print(f'[warn] TILE_BG {bg_path.name} is {img.shape[1]}×{img.shape[0]}, expected {ew}×{eh} — ignored', flush=True)

        # Fall back to backup / game file
        orig = ORIGINALS_DIR / f'{name}.png'
        src  = TILE_DIR / f'{name}.png'
        for path in (orig, src):
            if path.exists():
                img = np.array(Image.open(path).convert('RGB'))
                if img.shape[:2] == (eh, ew):
                    if path == src and not orig.exists():
                        shutil.copy(src, orig)
                    return img
                print(f'[warn] {name}: {path.name} is {img.shape[1]}×{img.shape[0]}, expected {ew}×{eh} — ignored', flush=True)
        return np.zeros((eh, ew, 3), dtype=np.uint8)

    def _build_result(self, name):
        base = self._originals.get(name)
        if base is None:
            layout = TILE_LAYOUTS[name]
            base = np.zeros((layout['sheet_h'], layout['sheet_w'], 3), dtype=np.uint8)
        base  = base.copy()
        ovs   = self._tile_overlays.get(name, {})
        mean  = base.mean(axis=(0,1))
        sprites = TILE_LAYOUTS[name]['sprites']
        for i, (sx, sy, sw, sh, gn) in enumerate(sprites):
            sprite_ovs = ovs.get(i, [])
            if not sprite_ovs: continue
            arr = base[sy:sy+sh, sx:sx+sw].copy()
            for ov in sprite_ovs:
                _, comp = make_overlay(ov['mask'], sw, sh,
                                       ov['angle'], ov['flip_h'], ov['flip_v'],
                                       self.tex_arr, arr, ov['cx'], ov['cy'],
                                       ov['ov_alpha'], ov['ov_blend'], mean, ov['scale'],
                                       mx=ov.get('mx',0), my=ov.get('my',0))
                arr = np.array(comp)
            base[sy:sy+sh, sx:sx+sw] = arr
        return base

    def _on_weight_changed(self, idx, w):
        if idx >= 0:
            self._tile_weights.setdefault(self._current, {})[idx] = w

    def _on_sprite_click(self, idx):
        if self._selected >= 0:
            self._tile_overlays.setdefault(self._current, {})[self._selected] = \
                self._editor.get_overlays()
            self._tile_weights.setdefault(self._current, {})[self._selected] = \
                self._editor.get_weight()
        self._selected = idx
        sprites = TILE_LAYOUTS[self._current]['sprites']
        sx, sy, sw, sh, gn = sprites[idx]
        base = self._originals.get(self._current)
        if base is None:
            base = np.zeros((sh, sw, 3), dtype=np.uint8)
        sprite_base = base[sy:sy+sh, sx:sx+sw].copy()
        ovs    = self._tile_overlays.get(self._current, {}).get(idx, [])
        weight = self._tile_weights.get(self._current, {}).get(idx, 100)
        mean   = base.mean(axis=(0,1))
        self._editor.load_sprite(idx, sprite_base, ovs, mean, sprites[idx], weight=weight)
        self._status.setText(f'{self._current}  —  #{idx} {gn}  {sw}×{sh} px  @({sx},{sy})')

    def _on_sprite_changed(self, idx):
        self._tile_overlays.setdefault(self._current, {})[idx] = self._editor.get_overlays()
        self._view.set_sheet(self._build_result(self._current))

    def _revert_tile(self):
        name = self._current
        orig = ORIGINALS_DIR / f'{name}.png'
        dst  = TILE_DIR / f'{name}.png'
        if not orig.exists():
            QMessageBox.warning(self, 'Нет бэкапа', f'Оригинал не найден:\n{orig}'); return
        if QMessageBox.question(self, 'Откатить?',
                f'Восстановить {name} из оригинала и убрать все оверлеи?',
                QMessageBox.Yes | QMessageBox.No) != QMessageBox.Yes: return
        shutil.copy(orig, dst)
        self._tile_overlays[name] = {}
        self._tile_weights[name]  = {}
        self._originals[name] = np.array(Image.open(orig).convert('RGB'))
        self._selected = -1
        self._editor.load_sprite(-1, np.zeros((1,1,3),dtype=np.uint8), [], None, (0,0,1,1,''))
        self._view.set_sheet(self._build_result(name))
        self._view.set_selected(-1)
        self._save_state()
        self._status.setText(f'{name}  — восстановлен из оригинала')

    def _export(self):
        if self._selected >= 0:
            self._tile_overlays.setdefault(self._current, {})[self._selected] = \
                self._editor.get_overlays()
        result = Image.fromarray(self._build_result(self._current))
        out    = TILE_DIR / f'{self._current}.png'
        result.save(out); self._save_state()
        QMessageBox.information(self, 'Готово', f'Сохранено:\n{out}')

    def _flat_masks(self): return [m for _,ms in self.mask_groups for m in ms]

    def _serialise(self, ovs_by_sprite):
        flat   = self._flat_masks(); id_map = {id(m): i for i,m in enumerate(flat)}
        return {str(si): [{k:v for k,v in ov.items() if k!='mask'} | {'mask_idx': id_map.get(id(ov.get('mask')),0)}
                          for ov in ovs]
                for si, ovs in ovs_by_sprite.items()}

    def _deserialise(self, data):
        flat = self._flat_masks()
        return {int(si): [dict(sd, mask=flat[min(sd.get('mask_idx',0), len(flat)-1)])
                          for sd in ovs]
                for si, ovs in data.items()}

    def _save_state(self):
        if self._selected >= 0:
            self._tile_overlays.setdefault(self._current, {})[self._selected] = \
                self._editor.get_overlays()
            self._tile_weights.setdefault(self._current, {})[self._selected] = \
                self._editor.get_weight()
        state = {n: self._serialise(ovs) for n, ovs in self._tile_overlays.items()}
        state['_weights_'] = {n: {str(k): v for k, v in ws.items()}
                              for n, ws in self._tile_weights.items()}
        try: STATE_PATH.write_text(json.dumps(state, indent=2))
        except Exception as e: print(f'[save] {e}', flush=True)

    def _load_state(self):
        if not STATE_PATH.exists(): return
        try:
            raw = json.loads(STATE_PATH.read_text())
            weights_raw = raw.pop('_weights_', {})
            for name, data in raw.items():
                if name not in TILE_LAYOUTS: continue
                if name not in self._originals: self._originals[name] = self._load_original(name)
                self._tile_overlays[name] = self._deserialise(data)
            for name, ws in weights_raw.items():
                if name in TILE_LAYOUTS:
                    self._tile_weights[name] = {int(k): v for k, v in ws.items()}
            self._view.set_sheet(self._build_result(self._current))
        except Exception as e: print(f'[load] {e}', flush=True)

    def closeEvent(self, e): self._save_state(); super().closeEvent(e)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    app.setStyle('Fusion'); app.setStyleSheet(STYLE)
    w = TileEditor(); w.show()
    sys.exit(app.exec_())
