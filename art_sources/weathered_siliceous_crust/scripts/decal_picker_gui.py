#!/usr/bin/env python3
"""
Decal picker GUI v5 — weathered_siliceous_crust.

Mask sources (104 total):
  • Batch    — 16 quadrant masks from batch01-04_mask_2x2_1024.png
  • Slag16   — 16 individual masks from masks/individual/slag16_*.png
  • Step1    — 72 individual masks from masks/individual/step1_*.png

Left:   scrollable mask selector (grouped) + generated decal grid (4×4).
Center: selected decals, scrollable, grouped.
Right:  zoomable/scrollable 4096×4096 preview — generated in a background thread.
        Ctrl+scroll or +/− to zoom.
        Separate Preview Alpha (0–300 %) and Blend sliders override the atlas values.
Top:    Atlas Alpha + Atlas Blend sliders (used for export).
"""

import sys, json, pathlib, random
from collections import defaultdict
from copy import deepcopy
import numpy as np
from PIL import Image

from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QHBoxLayout, QVBoxLayout,
    QGridLayout, QPushButton, QLabel, QScrollArea, QFrame,
    QGroupBox, QMessageBox, QButtonGroup, QSizePolicy,
    QSlider, QCheckBox, QDoubleSpinBox, QSpinBox,
    QDialog, QDialogButtonBox,
)
from PyQt5.QtCore import Qt, QSize, QTimer, QThread, pyqtSignal
from PyQt5.QtGui import QPixmap, QImage, QFont, QPainter, QColor, QIcon

# ── paths ─────────────────────────────────────────────────────────────────────

ROOT         = pathlib.Path(__file__).resolve().parents[3]
TEX_PATH     = ROOT / 'art_sources/weathered_siliceous_crust/textures/decal_source_texture.png'
TILE_PATH    = ROOT / 'art_sources/weathered_siliceous_crust/tiles/base_128.png'
INDIVIDUAL   = ROOT / 'art_sources/weathered_siliceous_crust/masks/individual'
STATE_PATH   = ROOT / 'art_sources/weathered_siliceous_crust/textures/picker_state.json'
BATCH_PATHS  = [
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch01_mask_2x2_1024.png',
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch02_mask_2x2_1024.png',
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch03_mask_2x2_1024.png',
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch04_mask_2x2_1024.png',
]

# ── constants ─────────────────────────────────────────────────────────────────

UNIT        = 64
LOW         = int(0.20 * 255)
HIGH        = int(0.80 * 255)
GEN_N       = 16
GEN_COLS    = 4
THUMB       = 140
PAD         = 16
MASK_CELL   = 48
ATLAS_W     = 2048
CANVAS_SIZE = 4096   # virtual preview canvas — 64×64 tiles at 64 px/tile
PANEL_W     = 620    # right panel width

PROBE_SIZES = [(1,1),(2,2),(2,4),(4,2),(4,4),(2,6),(6,2),(8,4),(4,8),(8,8)]

# Per-size defaults: min_sep in tile units (0 = none), probability per tile (0–1)
DEFAULT_SIZE_PARAMS = {
    (8, 8): {'min_sep': 14.0, 'probability': 0.001},
    (4, 4): {'min_sep':  7.0, 'probability': 0.003},
    (2, 2): {'min_sep':  3.5, 'probability': 0.030},
    (2, 1): {'min_sep':  2.0, 'probability': 0.012},
    (1, 1): {'min_sep':  0.0, 'probability': 0.060},
}

# ── global stylesheet ─────────────────────────────────────────────────────────

GLOBAL_STYLE = """
QPushButton {
    background: #2d2d2d; border: 1px solid #555; border-radius: 3px;
    color: #ccc; padding: 2px 8px;
}
QPushButton:hover  { background: #3c3c3c; border-color: #888; color: #fff; }
QPushButton:pressed { background: #1a1a1a; }
QPushButton:checked {
    background: #1f4a2a; border-color: #4a9a6a; color: #9dca9d; font-weight: bold;
}
QPushButton:checked:hover { background: #2a6035; border-color: #6aba8a; }

QCheckBox { color: #aaa; spacing: 6px; }
QCheckBox:hover { color: #eee; }
QCheckBox::indicator {
    width: 15px; height: 15px;
    border: 2px solid #555; border-radius: 3px; background: #252525;
}
QCheckBox::indicator:hover { border-color: #7ab; background: #2d3a3d; }
QCheckBox::indicator:checked {
    background: #1f4a2a; border-color: #4a9a6a;
}
QCheckBox::indicator:checked:hover { background: #2a6035; border-color: #6aba8a; }

QSlider::groove:horizontal {
    height: 4px; background: #333; border: 1px solid #444; border-radius: 2px;
}
QSlider::handle:horizontal {
    background: #5a8a6a; border: 1px solid #4a7a5a;
    width: 14px; height: 14px; margin: -5px 0; border-radius: 7px;
}
QSlider::handle:horizontal:hover { background: #7aaa8a; border-color: #6aca9a; }
QSlider::sub-page:horizontal { background: #2a5a3a; border-radius: 2px; }

QDoubleSpinBox, QSpinBox {
    background: #252525; border: 1px solid #555; border-radius: 3px;
    color: #ccc; padding: 1px 3px; min-height: 20px;
}
QDoubleSpinBox:hover, QSpinBox:hover { border-color: #888; }
QDoubleSpinBox:focus, QSpinBox:focus { border-color: #4a9a6a; }
QDoubleSpinBox::up-button, QDoubleSpinBox::down-button,
QSpinBox::up-button,       QSpinBox::down-button {
    background: #333; border: none; width: 16px;
}
QDoubleSpinBox::up-button:hover,   QDoubleSpinBox::down-button:hover,
QSpinBox::up-button:hover,         QSpinBox::down-button:hover { background: #444; }

QScrollBar:vertical   { background: #1e1e1e; width: 10px; border: none; }
QScrollBar:horizontal { background: #1e1e1e; height: 10px; border: none; }
QScrollBar::handle:vertical, QScrollBar::handle:horizontal {
    background: #444; border-radius: 5px; min-width: 20px; min-height: 20px;
}
QScrollBar::handle:vertical:hover, QScrollBar::handle:horizontal:hover { background: #666; }
QScrollBar::add-line, QScrollBar::sub-line { width: 0; height: 0; }

QGroupBox {
    border: 1px solid #3a3a3a; border-radius: 4px;
    margin-top: 10px; color: #888; font-size: 11px;
}
QGroupBox::title { subcontrol-origin: margin; left: 8px; padding: 0 4px; }
"""


# ── Guillotine rect packer ────────────────────────────────────────────────────

class Guillotine:
    def __init__(self, width, canvas_h):
        self.w = width; self.h = 0
        self.free = [[0, 0, width, canvas_h]]

    @staticmethod
    def _split(free, bi, pw, ph):
        rx, ry, rw, rh = free.pop(bi)
        if rw - pw > 0: free.append([rx+pw, ry, rw-pw, ph])
        if rh - ph > 0: free.append([rx, ry+ph, rw, rh-ph])
        return rx, ry

    @staticmethod
    def _best(free, pw, ph):
        bi, ba = None, float('inf')
        for i, r in enumerate(free):
            if r[2] >= pw and r[3] >= ph and r[2]*r[3] < ba:
                ba = r[2]*r[3]; bi = i
        return bi

    def insert(self, pw, ph):
        i = self._best(self.free, pw, ph)
        if i is None: raise RuntimeError(f'No space for {pw}×{ph}')
        x, y = self._split(self.free, i, pw, ph)
        self.h = max(self.h, y+ph); return x, y

    def count_fitting(self, pw, ph):
        free = deepcopy(self.free); count = 0
        while True:
            i = self._best(free, pw, ph)
            if i is None: break
            self._split(free, i, pw, ph); count += 1
        return count


def pack_sprites(sprites):
    ordered = sorted(sprites, key=lambda s: -(s['pw']*s['ph']))
    if not ordered: return Guillotine(ATLAS_W, 64), []
    total   = sum(s['pw']*s['ph'] for s in ordered)
    tallest = max(s['ph'] for s in ordered)
    packer  = Guillotine(ATLAS_W, total//ATLAS_W + tallest*2)
    return packer, [(s, *packer.insert(s['pw'], s['ph'])) for s in ordered]


# ── mask loading ──────────────────────────────────────────────────────────────

def extract_quadrants(path):
    img = Image.open(path).convert('L')
    w, h = img.size; hw, hh = w//2, h//2
    return [img.crop((0,0,hw,hh)), img.crop((hw,0,w,hh)),
            img.crop((0,hh,hw,h)), img.crop((hw,hh,w,h))]


def load_mask_groups():
    groups = []
    batch = []
    for p in BATCH_PATHS: batch.extend(extract_quadrants(p))
    groups.append(('Batch', batch))
    for prefix, label in [('slag16','Slag16'), ('step1','Step1')]:
        imgs = [Image.open(f).convert('L')
                for f in sorted(INDIVIDUAL.glob(f'{prefix}_*.png'))]
        if imgs: groups.append((label, imgs))
    return groups


# ── image helpers ─────────────────────────────────────────────────────────────

def build_mask(mask_pil, px_w, px_h, angle, flip_h, flip_v, scale=1.0):
    m = mask_pil
    if flip_h: m = m.transpose(Image.FLIP_LEFT_RIGHT)
    if flip_v: m = m.transpose(Image.FLIP_TOP_BOTTOM)
    m = m.rotate(angle, resample=Image.BILINEAR, expand=True)
    sw = max(1, int(px_w * scale));  sh = max(1, int(px_h * scale))
    m = m.resize((sw, sh), Image.LANCZOS)
    if scale > 1.0:
        l = (sw - px_w) // 2;  t = (sh - px_h) // 2
        m = m.crop((l, t, l + px_w, t + px_h))
    elif scale < 1.0:
        canvas = Image.new('L', (px_w, px_h), 0)
        canvas.paste(m, ((px_w - sw) // 2, (px_h - sh) // 2))
        m = canvas
    arr = np.array(m, dtype=float)
    arr[0,:] = arr[-1,:] = arr[:,0] = arr[:,-1] = 0
    return Image.fromarray(
        np.clip((arr-LOW)/(HIGH-LOW)*255.0, 0, 255).astype(np.uint8), 'L')


def tile_fill(tile, w, h):
    tw, th = tile.size; bg = Image.new('RGB', (w, h))
    for y in range(0, h, th):
        for x in range(0, w, tw): bg.paste(tile, (x, y))
    return bg


def make_decal(mask_pil, px_w, px_h, angle, flip_h, flip_v,
               tex_arr, bg_tile, cx, cy,
               alpha_pct=100, blend_pct=0, tile_mean=None, scale=1.0, mx=0, my=0):
    """
    Returns (rgba, preview):
      rgba    — px_w × px_h RGBA sprite
      preview — (px_w+2·PAD) × (ph+2·PAD) RGB composite on tiled bg
    alpha_pct may exceed 100 (clips to 255) to boost faint masks.
    scale: mask zoom factor (1.0 = fills decal area, 2.0 = zoomed in, 0.5 = centred+padded).
    """
    mask = build_mask(mask_pil, px_w, px_h, angle, flip_h, flip_v, scale)
    if mx != 0 or my != 0:
        shifted = Image.new('L', (px_w, px_h), 0); shifted.paste(mask, (mx, my)); mask = shifted

    rgb_arr = tex_arr[cy:cy+px_h, cx:cx+px_w].astype(float)
    if blend_pct > 0 and tile_mean is not None:
        factor = blend_pct / 100.0
        mean   = np.asarray(tile_mean, dtype=float)
        above  = rgb_arr > mean[np.newaxis, np.newaxis, :]
        rgb_arr = np.where(above, rgb_arr + (mean-rgb_arr)*factor, rgb_arr)
        rgb_arr = np.clip(rgb_arr, 0, 255)
    rgb_img = Image.fromarray(rgb_arr.astype(np.uint8), 'RGB')

    mask_arr = np.array(mask)
    if alpha_pct != 100:
        mask_arr = np.clip(mask_arr * (alpha_pct/100.0), 0, 255).astype(np.uint8)
    mask_img = Image.fromarray(mask_arr, 'L')

    r, g, b = rgb_img.split()
    rgba = Image.merge('RGBA', (r, g, b, mask_img))
    pw, ph = px_w+2*PAD, px_h+2*PAD
    bg = tile_fill(bg_tile, pw, ph).convert('RGBA')
    bg.paste(rgba, (PAD, PAD), rgba)
    return rgba, bg.convert('RGB')


def pil_to_qpixmap(img):
    img = img.convert('RGB')
    data = img.tobytes('raw', 'RGB')
    qi = QImage(data, img.width, img.height, img.width*3, QImage.Format_RGB888)
    return QPixmap.fromImage(qi)


def fit(pw, ph, max_w, max_h):
    s = min(max_w/pw, max_h/ph, 1.0)
    return max(1, int(pw*s)), max(1, int(ph*s))


# ── ZoomPreview widget ────────────────────────────────────────────────────────

class ZoomPreview(QScrollArea):
    """Scrollable, zoomable preview. Ctrl+wheel or +/− buttons to zoom."""
    ZOOM_STEPS = [0.125, 0.25, 0.33, 0.5, 0.67, 1.0, 1.5, 2.0, 3.0, 4.0]

    def __init__(self, zoom_label: QLabel, parent=None):
        super().__init__(parent)
        self._pil    = None
        self._zidx   = 3           # default: 0.5×
        self._zlabel = zoom_label
        self._inner  = QLabel()
        self._inner.setAlignment(Qt.AlignTop | Qt.AlignLeft)
        self._inner.setStyleSheet('background:#111;')
        self.setWidget(self._inner)
        self.setWidgetResizable(False)
        self.setStyleSheet('QScrollArea{background:#111; border:none;}')
        self._update_label()

    @property
    def zoom(self): return self.ZOOM_STEPS[self._zidx]

    def zoom_in(self):
        if self._zidx < len(self.ZOOM_STEPS)-1:
            self._zidx += 1; self._redraw()

    def zoom_out(self):
        if self._zidx > 0:
            self._zidx -= 1; self._redraw()

    def _update_label(self):
        self._zlabel.setText(f'{int(self.zoom*100)}%')

    def set_image(self, pil_img):
        self._pil = pil_img; self._redraw()

    def show_loading(self):
        self._inner.setPixmap(QPixmap())
        self._inner.resize(300, 60)
        self._inner.setText('Генерация…')
        self._inner.setStyleSheet('background:#111; color:#888; font-size:14px;')
        self._inner.setAlignment(Qt.AlignCenter)

    def clear(self):
        self._pil = None
        self._inner.setPixmap(QPixmap())
        self._inner.resize(300, 60)
        self._inner.setText('Нет декалей')
        self._inner.setStyleSheet('background:#111; color:#555; font-size:14px;')
        self._inner.setAlignment(Qt.AlignCenter)

    def _redraw(self):
        if self._pil is None: return
        z = self.zoom
        w = max(1, int(self._pil.width*z))
        h = max(1, int(self._pil.height*z))
        rsmp = Image.NEAREST if z >= 1.0 else Image.LANCZOS
        scaled = self._pil.resize((w, h), rsmp)
        self._inner.setStyleSheet('background:#111;')
        self._inner.setText('')
        self._inner.setPixmap(pil_to_qpixmap(scaled))
        self._inner.resize(w, h)
        self._update_label()

    def wheelEvent(self, event):
        if event.modifiers() & Qt.ControlModifier:
            if event.angleDelta().y() > 0: self.zoom_in()
            else: self.zoom_out()
            event.accept()
        else:
            super().wheelEvent(event)


# ── widgets ───────────────────────────────────────────────────────────────────

class MaskButton(QPushButton):
    ON  = 'border:2px solid #6c9; background:transparent;'
    OFF = 'border:2px solid #333; background:transparent; color:#444;'

    def __init__(self, mask_pil, on_toggle):
        super().__init__()
        self.setCheckable(True); self.setChecked(True)
        self.setFixedSize(MASK_CELL+4, MASK_CELL+4)
        arr = np.array(mask_pil.resize((MASK_CELL, MASK_CELL), Image.LANCZOS), dtype=float)
        arr = np.clip((arr-LOW)/(HIGH-LOW)*255, 0, 255).astype(np.uint8)
        pm  = pil_to_qpixmap(Image.fromarray(arr,'L').convert('RGB'))
        self.setIcon(QIcon(pm)); self.setIconSize(QSize(MASK_CELL, MASK_CELL))
        self._update_style()
        self.toggled.connect(lambda: (self._update_style(), on_toggle()))

    def _update_style(self):
        self.setStyleSheet(self.ON if self.isChecked() else self.OFF)


class DecalThumb(QLabel):
    def __init__(self, decal, number, on_click):
        super().__init__()
        self._on_click = on_click; self.decal = decal
        pw = decal['pw']+2*PAD; ph = decal['ph']+2*PAD
        tw, th = fit(pw, ph, THUMB, THUMB)
        pm = pil_to_qpixmap(decal['preview'].resize((tw, th), Image.LANCZOS))
        p = QPainter(pm)
        p.setFont(QFont('DejaVu Sans', 11, QFont.Bold))
        for dx, dy in [(-1,-1),(1,-1),(-1,1),(1,1),(-2,0),(2,0),(0,-2),(0,2)]:
            p.setPen(QColor(0,0,0)); p.drawText(4+dx, 16+dy, str(number))
        p.setPen(QColor(255,255,255)); p.drawText(4, 16, str(number))
        p.end()
        self.setPixmap(pm); self.setFixedSize(THUMB, THUMB)
        self.setAlignment(Qt.AlignCenter); self.setCursor(Qt.PointingHandCursor)
        self.setStyleSheet('border:1px solid #444; background:#1a1a1a;')

    def mousePressEvent(self, e):
        if e.button() == Qt.LeftButton: self._on_click(self.decal)


class SelectedDecalThumb(QWidget):
    MAX = 180

    def __init__(self, decal, tex_arr, bg_tile, tile_mean, mask_groups,
                 on_delete, on_change):
        super().__init__()
        self._d      = decal
        self._tex    = tex_arr
        self._tile   = bg_tile
        self._mean   = tile_mean
        self._on_chg = on_change
        self._masks  = mask_groups

        pw = decal['pw']+2*PAD; ph = decal['ph']+2*PAD
        self._dw, self._dh = fit(pw, ph, self.MAX, self.MAX)

        lay = QVBoxLayout(self); lay.setContentsMargins(3,3,3,3); lay.setSpacing(3)

        self._lbl = QLabel()
        self._lbl.setFixedSize(self._dw, self._dh)
        self._lbl.setAlignment(Qt.AlignCenter)
        self._lbl.setStyleSheet('border:1px solid #555;')
        self._lbl.setCursor(Qt.PointingHandCursor)
        self._lbl.setToolTip('Двойной клик — редактировать')
        self._lbl.mouseDoubleClickEvent = lambda _e: self._open_editor()
        lay.addWidget(self._lbl, alignment=Qt.AlignHCenter)
        self._regen_thumb()

        btn = QPushButton('✕'); btn.setFixedSize(22, 18)
        btn.setStyleSheet('color:#f66;font-size:9px;border:1px solid #533;')
        btn.clicked.connect(on_delete)
        lay.addWidget(btn, alignment=Qt.AlignHCenter)

    def _regen_thumb(self):
        d = self._d
        _, preview = make_decal(
            d['mask'], d['pw'], d['ph'],
            d['angle'], d['flip_h'], d['flip_v'],
            self._tex, self._tile, d['cx'], d['cy'],
            d.get('ov_alpha', 100), d.get('ov_blend', 0), self._mean, d.get('scale', 1.0),
            mx=d.get('mx', 0), my=d.get('my', 0))
        self._lbl.setPixmap(
            pil_to_qpixmap(preview.resize((self._dw, self._dh), Image.LANCZOS)))

    def _open_editor(self):
        dlg = DecalEditDialog(
            self._d, self._tex, self._tile, self._mean, self._masks, parent=self)
        if dlg.exec_() == QDialog.Accepted:
            self._d.update(dlg.result())
            rgba, _ = make_decal(
                self._d['mask'], self._d['pw'], self._d['ph'],
                self._d['angle'], self._d['flip_h'], self._d['flip_v'],
                self._tex, self._tile, self._d['cx'], self._d['cy'],
                self._d.get('ov_alpha', 100), self._d.get('ov_blend', 0),
                self._mean, self._d.get('scale', 1.0),
                mx=self._d.get('mx', 0), my=self._d.get('my', 0))
            self._d['rgba'] = rgba
            self._regen_thumb()
            self._on_chg()


# ── Texture crop widget ───────────────────────────────────────────────────────

class TextureCropWidget(QWidget):
    """Shows source texture at scale; mouse-drag moves the crop rectangle (cx, cy)."""
    posChanged = pyqtSignal(int, int)

    def __init__(self, tex_pil, dpw, dph, cx, cy, parent=None):
        super().__init__(parent)
        self._tex_pil  = tex_pil
        self._dpw = dpw; self._dph = dph
        self._cx  = cx;  self._cy  = cy
        self._tex_w, self._tex_h = tex_pil.size
        self._dragging   = False
        self._drag_start = None
        self._qpix       = None
        self.setCursor(Qt.OpenHandCursor)
        self.setMinimumSize(200, 100)

    def _make_qpix(self):
        if self._qpix is None:
            self._qpix = pil_to_qpixmap(self._tex_pil)
        return self._qpix

    def _sf_ofs(self):
        sf = min(self.width() / self._tex_w, self.height() / self._tex_h)
        ox = (self.width()  - self._tex_w * sf) / 2
        oy = (self.height() - self._tex_h * sf) / 2
        return sf, ox, oy

    def paintEvent(self, event):
        from PyQt5.QtCore import QRectF
        from PyQt5.QtGui  import QPen
        p = QPainter(self)
        p.setRenderHint(QPainter.SmoothPixmapTransform)
        sf, ox, oy = self._sf_ofs()
        p.drawPixmap(QRectF(ox, oy, self._tex_w*sf, self._tex_h*sf).toRect(),
                     self._make_qpix())
        rx = ox + self._cx * sf; ry = oy + self._cy * sf
        rw = self._dpw * sf;     rh = self._dph * sf
        tw = self._tex_w * sf;   th = self._tex_h * sf
        # Dark overlay outside selection
        p.setBrush(QColor(0, 0, 0, 120)); p.setPen(Qt.NoPen)
        def fill(x, y, w, h):
            if w > 0 and h > 0:
                p.drawRect(int(x), int(y), int(w + 0.5) + 1, int(h + 0.5) + 1)
        fill(ox,    oy,    tw,            ry - oy)
        fill(ox,    ry+rh, tw,            oy + th - ry - rh)
        fill(ox,    ry,    rx - ox,       rh)
        fill(rx+rw, ry,    ox+tw - rx-rw, rh)
        # Selection border
        p.setBrush(Qt.NoBrush)
        p.setPen(QPen(QColor(100, 200, 130), 2))
        p.drawRect(int(rx), int(ry), int(rw), int(rh))
        p.end()

    def mousePressEvent(self, e):
        if e.button() == Qt.LeftButton:
            self._dragging   = True
            self._drag_start = (e.x(), e.y(), self._cx, self._cy)
            self.setCursor(Qt.ClosedHandCursor)

    def mouseReleaseEvent(self, e):
        if e.button() == Qt.LeftButton:
            self._dragging = False
            self.setCursor(Qt.OpenHandCursor)

    def mouseMoveEvent(self, e):
        if not self._dragging: return
        sf, _, _ = self._sf_ofs()
        mx0, my0, cx0, cy0 = self._drag_start
        cx = max(0, min(int(round(cx0 + (e.x()-mx0)/sf)), self._tex_w - self._dpw))
        cy = max(0, min(int(round(cy0 + (e.y()-my0)/sf)), self._tex_h - self._dph))
        if cx != self._cx or cy != self._cy:
            self._cx = cx; self._cy = cy
            self.posChanged.emit(cx, cy)
            self.update()

    def set_pos(self, cx, cy):
        self._cx = max(0, min(cx, self._tex_w - self._dpw))
        self._cy = max(0, min(cy, self._tex_h - self._dph))
        self.update()


class DraggablePreview(QLabel):
    """Preview label; drag moves the mask offset (emits delta in canvas pixels)."""
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


# ── Decal edit dialog ────────────────────────────────────────────────────────

class DecalEditDialog(QDialog):
    PREV_SZ  = 300
    MASK_BTN = 40    # mask thumbnail size in selector

    def __init__(self, decal, tex_arr, bg_tile, tile_mean, mask_groups, parent=None):
        super().__init__(parent)
        self.setWindowTitle('Редактирование декали')
        self.setModal(True)
        self._w  = dict(decal)   # working copy — applied on Accept
        self._tex = tex_arr;  self._tile = bg_tile;  self._mean = tile_mean

        self._deb = QTimer(self); self._deb.setSingleShot(True)
        self._deb.timeout.connect(self._regen)

        self._build_ui(mask_groups)
        self._regen()

    # ── UI construction ───────────────────────────────────────────────────────

    def _build_ui(self, mask_groups):
        self.setMinimumSize(720, 680)
        root = QVBoxLayout(self); root.setSpacing(8)

        # ── top: [render preview + texture drag] | [mask selector] ───────────
        top = QWidget(); tl = QHBoxLayout(top)
        tl.setContentsMargins(0,0,0,0); tl.setSpacing(8)

        # Left column: render preview (top) + draggable texture crop (bottom)
        left_col = QWidget(); lcl = QVBoxLayout(left_col)
        lcl.setContentsMargins(0,0,0,0); lcl.setSpacing(4)
        left_col.setFixedWidth(self.PREV_SZ)

        self._prev_lbl = DraggablePreview()
        self._prev_lbl.setFixedSize(self.PREV_SZ, self.PREV_SZ)
        self._prev_lbl.setAlignment(Qt.AlignCenter)
        self._prev_lbl.setStyleSheet('background:#111;')
        self._prev_lbl.deltaDragged.connect(self._on_prev_drag)
        lcl.addWidget(self._prev_lbl)

        lbl_prev_hint = QLabel('⠿ Тащи превью — двигает маску')
        lbl_prev_hint.setStyleSheet('color:#555; font-size:9px;')
        lcl.addWidget(lbl_prev_hint)

        tex_pil = Image.fromarray(self._tex.astype(np.uint8))
        lbl_drag = QLabel('⠿ Тащи текстуру — позиция кропа')
        lbl_drag.setStyleSheet('color:#555; font-size:9px;')
        lcl.addWidget(lbl_drag)
        self._tex_drag = TextureCropWidget(
            tex_pil, self._w['pw'], self._w['ph'],
            self._w.get('cx', 0), self._w.get('cy', 0))
        self._tex_drag.posChanged.connect(self._on_tex_drag)
        lcl.addWidget(self._tex_drag, stretch=1)
        tl.addWidget(left_col)

        # Right: mask selector
        mbox = QGroupBox('Маска'); ml = QVBoxLayout(mbox); ml.setContentsMargins(4,4,4,4)
        mscroll = QScrollArea(); mscroll.setWidgetResizable(True)
        mscroll.setFixedWidth(320)
        minner = QWidget(); mgrid = QVBoxLayout(minner)
        mgrid.setContentsMargins(2,2,2,2); mgrid.setSpacing(2)

        MCOLS = 6
        self._mask_btns_group = QButtonGroup(self); self._mask_btns_group.setExclusive(True)
        self._all_masks = []
        cur = self._w.get('mask')
        idx = 0

        for grp_name, masks in mask_groups:
            hdr = QLabel(f'── {grp_name} ──')
            hdr.setStyleSheet('color:#555; font-size:9px; margin-top:3px;')
            mgrid.addWidget(hdr)
            row_w = QWidget(); row_l = QHBoxLayout(row_w)
            row_l.setContentsMargins(0,0,0,0); row_l.setSpacing(2)
            col = 0
            for m in masks:
                arr = np.array(m.resize((self.MASK_BTN-4, self.MASK_BTN-4), Image.LANCZOS), dtype=float)
                arr = np.clip((arr-LOW)/(HIGH-LOW)*255, 0, 255).astype(np.uint8)
                pm  = pil_to_qpixmap(Image.fromarray(arr,'L').convert('RGB'))
                btn = QPushButton(); btn.setCheckable(True); btn.setChecked(m is cur)
                btn.setFixedSize(self.MASK_BTN, self.MASK_BTN)
                btn.setIcon(QIcon(pm)); btn.setIconSize(QSize(self.MASK_BTN-4, self.MASK_BTN-4))
                self._mask_btns_group.addButton(btn, idx)
                row_l.addWidget(btn)
                self._all_masks.append(m)
                idx += 1; col += 1
                if col == MCOLS:
                    mgrid.addWidget(row_w)
                    row_w = QWidget(); row_l = QHBoxLayout(row_w)
                    row_l.setContentsMargins(0,0,0,0); row_l.setSpacing(2)
                    col = 0
            if col > 0:
                row_l.addStretch(); mgrid.addWidget(row_w)

        mgrid.addStretch()
        self._mask_btns_group.buttonClicked.connect(
            lambda b: self._on_mask(self._mask_btns_group.id(b)))
        mscroll.setWidget(minner); ml.addWidget(mscroll)
        tl.addWidget(mbox, stretch=1)
        root.addWidget(top, stretch=1)

        # ── parameters ────────────────────────────────────────────────────────
        pg = QWidget(); pgl = QGridLayout(pg)
        pgl.setColumnStretch(1, 1); pgl.setSpacing(4)

        tex_h, tex_w = self._tex.shape[:2]
        dpw, dph = self._w['pw'], self._w['ph']
        w = self._w

        def param_row(r, label, lo, hi, val, suffix, key, scale=1):
            pgl.addWidget(QLabel(label), r, 0)
            sl = QSlider(Qt.Horizontal)
            sl.blockSignals(True); sl.setRange(lo, hi); sl.blockSignals(False); sl.setValue(val)
            vl = QLabel(f'{val}{suffix}')
            vl.setFixedWidth(54); vl.setAlignment(Qt.AlignRight | Qt.AlignVCenter)
            def _cb(v, l=vl, s=suffix, k=key, sc=scale):
                l.setText(f'{v}{s}')
                w[k] = v / sc if sc != 1 else v
                self._deb.start(60)
            sl.valueChanged.connect(_cb)
            cw = QWidget(); cl = QHBoxLayout(cw); cl.setContentsMargins(0,0,0,0); cl.setSpacing(0)
            cl.addWidget(sl); cl.addWidget(vl)
            pgl.addWidget(cw, r, 1)
            return sl, vl

        self._sl_ang,            _  = param_row(0, 'Угол:',    0, 359, int(w.get('angle',0)) % 360, '°',  'angle')
        self._sl_cx,  self._vl_cx   = param_row(1, 'Поз X:',   0, max(0,tex_w-dpw), w.get('cx',0),   '',   'cx')
        self._sl_cy,  self._vl_cy   = param_row(2, 'Поз Y:',   0, max(0,tex_h-dph), w.get('cy',0),   '',   'cy')
        self._sl_mx,  self._vl_mx   = param_row(3, 'Маска X:', -(dpw-1), dpw-1, w.get('mx', 0), '', 'mx')
        self._sl_my,  self._vl_my   = param_row(4, 'Маска Y:', -(dph-1), dph-1, w.get('my', 0), '', 'my')
        self._sl_scale,          _  = param_row(5, 'Масштаб:', 10, 300, int(w.get('scale',1.0)*100),  '%', 'scale', scale=100)

        # Sync position sliders → texture drag widget
        self._sl_cx.valueChanged.connect(
            lambda v: self._tex_drag.set_pos(v, self._w.get('cy', 0)))
        self._sl_cy.valueChanged.connect(
            lambda v: self._tex_drag.set_pos(self._w.get('cx', 0), v))

        # Flip toggles
        frow = QWidget(); fl = QHBoxLayout(frow); fl.setContentsMargins(0,0,0,0); fl.setSpacing(4)
        self._fh = QPushButton('↔ Flip H'); self._fh.setCheckable(True); self._fh.setChecked(w.get('flip_h', False))
        self._fv = QPushButton('↕ Flip V'); self._fv.setCheckable(True); self._fv.setChecked(w.get('flip_v', False))
        self._fh.toggled.connect(lambda v: (w.__setitem__('flip_h', v), self._deb.start(60)))
        self._fv.toggled.connect(lambda v: (w.__setitem__('flip_v', v), self._deb.start(60)))
        fl.addWidget(self._fh); fl.addWidget(self._fv); fl.addStretch()
        pgl.addWidget(QLabel('Отражение:'), 6, 0)
        pgl.addWidget(frow, 6, 1)

        self._sl_alpha, _ = param_row(7, 'Alpha:', 0, 1000, w.get('ov_alpha', 100), '%', 'ov_alpha')
        self._sl_blend, _ = param_row(8, 'Blend:', 0,  100, w.get('ov_blend',  25), '%', 'ov_blend')

        root.addWidget(pg)

        bb = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        bb.accepted.connect(self.accept); bb.rejected.connect(self.reject)
        root.addWidget(bb)

    # ── internal ──────────────────────────────────────────────────────────────

    _PREV_PAD = 22

    def _on_prev_drag(self, dcx, dcy):
        w = self._w; px_w = w['pw']; px_h = w['ph']
        mx = max(-(px_w-1), min(w.get('mx', 0) + dcx, px_w-1))
        my = max(-(px_h-1), min(w.get('my', 0) + dcy, px_h-1))
        if mx == w.get('mx', 0) and my == w.get('my', 0): return
        w['mx'] = mx; w['my'] = my
        self._sl_mx.blockSignals(True); self._sl_mx.setValue(mx); self._sl_mx.blockSignals(False)
        self._sl_my.blockSignals(True); self._sl_my.setValue(my); self._sl_my.blockSignals(False)
        self._vl_mx.setText(str(mx)); self._vl_my.setText(str(my))
        self._deb.start(30)

    def _on_mask(self, idx):
        self._w['mask'] = self._all_masks[idx]; self._deb.start(60)

    def _on_tex_drag(self, cx, cy):
        self._w['cx'] = cx; self._w['cy'] = cy
        self._sl_cx.blockSignals(True); self._sl_cx.setValue(cx); self._sl_cx.blockSignals(False)
        self._sl_cy.blockSignals(True); self._sl_cy.setValue(cy); self._sl_cy.blockSignals(False)
        self._vl_cx.setText(str(cx)); self._vl_cy.setText(str(cy))
        self._deb.start(60)

    def _regen(self):
        d = self._w
        mx = d.get('mx', 0); my = d.get('my', 0)
        rgba, _ = make_decal(
            d['mask'], d['pw'], d['ph'],
            d.get('angle', 0), d.get('flip_h', False), d.get('flip_v', False),
            self._tex, self._tile, d.get('cx', 0), d.get('cy', 0),
            d.get('ov_alpha', 100), d.get('ov_blend', 25), self._mean, d.get('scale', 1.0),
            mx=mx, my=my)
        px_w, px_h = d['pw'], d['ph']
        INNER = self.PREV_SZ - 2*self._PREV_PAD
        s = min(INNER/px_w, INNER/px_h)
        sw = max(1, int(px_w*s)); sh = max(1, int(px_h*s))
        ox = (self.PREV_SZ - sw)//2; oy = (self.PREV_SZ - sh)//2

        ext = np.full((self.PREV_SZ, self.PREV_SZ, 3), 28, dtype=np.uint8)
        bg = tile_fill(self._tile, sw, sh)
        rgba_sc = rgba.resize((sw, sh), Image.LANCZOS)
        bg_rgba = bg.convert('RGBA'); bg_rgba.paste(rgba_sc, (0, 0), rgba_sc)
        ext[oy:oy+sh, ox:ox+sw] = np.array(bg_rgba.convert('RGB'))

        for bx, by, bw2, bh2 in [(ox-1,oy-1,sw+2,1),(ox-1,oy+sh,sw+2,1),
                                   (ox-1,oy-1,1,sh+2),(ox+sw,oy-1,1,sh+2)]:
            bx2 = max(0, bx); by2 = max(0, by)
            bw3 = min(bw2, self.PREV_SZ-bx2); bh3 = min(bh2, self.PREV_SZ-by2)
            if bw3>0 and bh3>0: ext[by2:by2+bh3, bx2:bx2+bw3] = [140,140,140]

        if mx != 0 or my != 0:
            raw = build_mask(d['mask'], px_w, px_h, d.get('angle',0), d.get('flip_h',False),
                             d.get('flip_v',False), d.get('scale',1.0))
            raw_sc = np.array(raw.resize((sw, sh), Image.LANCZOS), dtype=float) / 255.0
            mx_sc = int(round(mx*s)); my_sc = int(round(my*s))
            m_y0 = oy+my_sc; m_x0 = ox+mx_sc
            m_full = np.zeros((self.PREV_SZ, self.PREV_SZ), dtype=float)
            sy0=max(0,-m_y0); sx0=max(0,-m_x0)
            dy0=max(0,m_y0);  dx0=max(0,m_x0)
            dy1=min(self.PREV_SZ,m_y0+sh); dx1=min(self.PREV_SZ,m_x0+sw)
            sy1=sy0+(dy1-dy0); sx1=sx0+(dx1-dx0)
            if dy0<dy1 and dx0<dx1: m_full[dy0:dy1,dx0:dx1] = raw_sc[sy0:sy1,sx0:sx1]
            sp = np.zeros((self.PREV_SZ, self.PREV_SZ),dtype=bool)
            sp[oy:oy+sh,ox:ox+sw] = True
            oob = m_full * (~sp).astype(float)
            a = (oob * 0.85)[:,:,np.newaxis]
            blue = np.array([0,80,255],dtype=float)
            ext = np.clip(ext.astype(float)*(1-a) + blue*a, 0, 255).astype(np.uint8)

        self._prev_lbl.set_scale(s)
        self._prev_lbl.setPixmap(pil_to_qpixmap(Image.fromarray(ext)))

    def result(self):
        return self._w


# ── background preview worker ────────────────────────────────────────────────

class _PreviewThread(QThread):
    """Runs _make_preview_image in a worker thread; emits result via Qt signal."""
    result = pyqtSignal(object)   # carries the PIL Image
    error  = pyqtSignal(str)

    def __init__(self, fn, parent=None):
        super().__init__(parent)
        self._fn = fn

    def run(self):
        try:
            self.result.emit(self._fn())
        except Exception:
            import traceback
            self.error.emit(traceback.format_exc())


# ── slider helper ─────────────────────────────────────────────────────────────

def _make_slider_row(parent, label, min_v, max_v, default, suffix, on_change):
    """Returns (container_widget, slider, value_label)."""
    w = QWidget(parent); l = QHBoxLayout(w); l.setContentsMargins(0,0,0,0); l.setSpacing(0)
    l.addWidget(QLabel(label))
    sl = QSlider(Qt.Horizontal); sl.setRange(min_v, max_v); sl.setValue(default)
    sl.setFixedWidth(100)
    vl = QLabel(f'{default}{suffix}'); vl.setFixedWidth(50)
    sl.valueChanged.connect(lambda v: (vl.setText(f'{v}{suffix}'), on_change(v)))
    l.addWidget(sl); l.addWidget(vl)
    return w, sl, vl


# ── Main window ───────────────────────────────────────────────────────────────

class DecalPicker(QMainWindow):

    def __init__(self):
        super().__init__()
        self.setWindowTitle('Decal Picker v5 — Weathered Siliceous Crust')
        self.resize(1860, 980)

        self.tex_arr     = np.array(Image.open(TEX_PATH).convert('RGB'))
        self.bg_tile     = Image.open(TILE_PATH).convert('RGB')
        self.tile_mean   = np.array(self.bg_tile).mean(axis=(0,1))
        self.mask_groups = load_mask_groups()

        self.w_tiles = 4; self.h_tiles = 4
        self._seed        = 0
        self._generated   = []
        self._selected    = []
        self._mask_btns   = []
        self._preview_gen = 0
        self._size_params = {}

        self._prev_timer = QTimer(self); self._prev_timer.setSingleShot(True)
        self._prev_timer.timeout.connect(self._refresh_preview)

        self._build_ui()
        self._generate()
        self._load_state()

    # ── build UI ───────────────────────────────────────────────────────────────

    def _build_ui(self):
        root = QWidget(); self.setCentralWidget(root)
        root.setStyleSheet('background:#1e1e1e; color:#ddd;')
        ml = QVBoxLayout(root); ml.setContentsMargins(8,8,8,4); ml.setSpacing(6)

        # ── top bar ───────────────────────────────────────────────────────────
        top = QWidget()
        tl  = QHBoxLayout(top); tl.setContentsMargins(0,0,0,0); tl.setSpacing(4)

        tl.addWidget(QLabel('W:'))
        self._w_grp = QButtonGroup(self)
        for v in range(1,9):
            b = QPushButton(str(v)); b.setCheckable(True); b.setFixedSize(32,26)
            b.setChecked(v == self.w_tiles)
            b.clicked.connect(lambda _,v=v: self._set_size(v, None))
            self._w_grp.addButton(b, v); tl.addWidget(b)
        tl.addWidget(_vline())
        tl.addWidget(QLabel('H:'))
        self._h_grp = QButtonGroup(self)
        for v in range(1,9):
            b = QPushButton(str(v)); b.setCheckable(True); b.setFixedSize(32,26)
            b.setChecked(v == self.h_tiles)
            b.clicked.connect(lambda _,v=v: self._set_size(None, v))
            self._h_grp.addButton(b, v); tl.addWidget(b)
        tl.addWidget(_vline())
        rb = QPushButton('↺ Regen'); rb.setFixedHeight(26); rb.clicked.connect(self._generate)
        tl.addWidget(rb)

        tl.addStretch()
        self._refresh_size_btns()
        ml.addWidget(top)

        # ── middle ─────────────────────────────────────────────────────────────
        mid = QWidget(); midl = QHBoxLayout(mid)
        midl.setContentsMargins(0,0,0,0); midl.setSpacing(8)
        ml.addWidget(mid, stretch=1)

        # LEFT: masks + generated
        left = QWidget(); left.setFixedWidth(GEN_COLS*THUMB+24)
        ll = QVBoxLayout(left); ll.setContentsMargins(0,0,0,0); ll.setSpacing(6)

        mask_box = QGroupBox('Маски')
        mbl = QVBoxLayout(mask_box); mbl.setContentsMargins(4,4,4,4); mbl.setSpacing(4)
        glob_row = QWidget(); grl = QHBoxLayout(glob_row); grl.setContentsMargins(0,0,0,0)
        for label, val in [('✓ Все',True),('✗ Все',False)]:
            b = QPushButton(label); b.setFixedHeight(22)
            b.clicked.connect(lambda _, v=val: self._select_all_masks(v))
            grl.addWidget(b)
        grl.addStretch(); mbl.addWidget(glob_row)

        mask_scroll = QScrollArea(); mask_scroll.setWidgetResizable(True)
        mask_scroll.setFixedHeight(280)
        mask_scroll.setStyleSheet('QScrollArea{border:none;}')
        mask_inner = QWidget(); mask_vl = QVBoxLayout(mask_inner)
        mask_vl.setContentsMargins(2,2,2,2); mask_vl.setSpacing(6)
        MASK_COLS = 8
        for grp_name, masks in self.mask_groups:
            hdr = QWidget(); hdrl = QHBoxLayout(hdr); hdrl.setContentsMargins(0,0,0,0)
            lbl = QLabel(f'── {grp_name} ({len(masks)}) ──')
            lbl.setStyleSheet('color:#888; font-size:10px;'); hdrl.addWidget(lbl)
            for label, val in [('✓',True),('✗',False)]:
                b = QPushButton(label); b.setFixedSize(20,18)
                b.clicked.connect(lambda _, gn=grp_name, v=val: self._select_group(gn,v))
                hdrl.addWidget(b)
            hdrl.addStretch(); mask_vl.addWidget(hdr)
            grid_w = QWidget(); grid = QGridLayout(grid_w)
            grid.setSpacing(2); grid.setContentsMargins(0,0,0,0)
            for i, m in enumerate(masks):
                btn = MaskButton(m, self._on_mask_toggle)
                btn._group = grp_name; self._mask_btns.append(btn)
                grid.addWidget(btn, i//MASK_COLS, i%MASK_COLS)
            mask_vl.addWidget(grid_w)
        mask_vl.addStretch()
        mask_scroll.setWidget(mask_inner); mbl.addWidget(mask_scroll)
        ll.addWidget(mask_box)

        gen_box = QGroupBox('Сгенерированные  (клик → добавить)')
        genl = QVBoxLayout(gen_box); genl.setContentsMargins(4,4,4,4)
        self._gen_grid_w = QWidget()
        self._gen_grid   = QGridLayout(self._gen_grid_w)
        self._gen_grid.setSpacing(2); self._gen_grid.setContentsMargins(0,0,0,0)
        genl.addWidget(self._gen_grid_w); genl.addStretch()
        ll.addWidget(gen_box, stretch=1)
        midl.addWidget(left)

        # CENTER: selected
        cbox = QGroupBox('Выбранные декали')
        cl = QVBoxLayout(cbox); cl.setContentsMargins(4,4,4,4)
        csc = QScrollArea(); csc.setWidgetResizable(True)
        csc.setStyleSheet('QScrollArea{border:none;}')
        self._right_w = QWidget(); self._right_l = QVBoxLayout(self._right_w)
        self._right_l.setContentsMargins(4,4,4,4); self._right_l.setSpacing(4)
        self._right_l.addStretch()
        csc.setWidget(self._right_w); cl.addWidget(csc)
        midl.addWidget(cbox, stretch=1)

        # RIGHT: preview
        prev_box = QGroupBox('Предпросмотр')
        prev_box.setFixedWidth(PANEL_W)
        pvl = QVBoxLayout(prev_box); pvl.setContentsMargins(4,4,4,4); pvl.setSpacing(4)

        # Toolbar
        tb = QWidget(); tbl = QHBoxLayout(tb)
        tbl.setContentsMargins(0,0,0,0); tbl.setSpacing(4)
        rb2 = QPushButton('↺'); rb2.setFixedSize(28,24)
        rb2.setToolTip('Обновить предпросмотр')
        rb2.clicked.connect(self._refresh_preview)
        tbl.addWidget(rb2); tbl.addWidget(_vline())
        zm = QPushButton('−'); zm.setFixedSize(24,24)
        zp = QPushButton('+'); zp.setFixedSize(24,24)
        self._zoom_lbl = QLabel('50%'); self._zoom_lbl.setFixedWidth(40)
        self._zoom_lbl.setAlignment(Qt.AlignCenter)
        zm.clicked.connect(lambda: self._preview.zoom_out())
        zp.clicked.connect(lambda: self._preview.zoom_in())
        tbl.addWidget(zm); tbl.addWidget(self._zoom_lbl); tbl.addWidget(zp)
        tbl.addStretch()
        pvl.addWidget(tb)

        self._preview = ZoomPreview(self._zoom_lbl)
        pvl.addWidget(self._preview, stretch=1)
        self._preview.clear()
        midl.addWidget(prev_box)

        # ── bottom ─────────────────────────────────────────────────────────────
        bot = QWidget(); bl = QHBoxLayout(bot); bl.setContentsMargins(0,2,0,2)
        self._status = QLabel(''); self._status.setStyleSheet('color:#8d8;font-size:11px;')
        self._status.setWordWrap(True)
        bl.addWidget(self._status, stretch=1)
        gb = QPushButton('⚡  Generate sprite sheet'); gb.setFixedHeight(30)
        gb.setStyleSheet('font-weight:bold;padding:0 16px;'); gb.clicked.connect(self._do_generate)
        bl.addWidget(gb); ml.addWidget(bot)

    def _refresh_size_btns(self):
        # Rely on global stylesheet :checked/:hover states — just clear any leftover inline style.
        for g in (self._w_grp, self._h_grp):
            for b in g.buttons(): b.setStyleSheet('')

    # ── per-size params ────────────────────────────────────────────────────────

    def _get_size_params(self, w, h):
        key = (w, h)
        if key in self._size_params:
            return self._size_params[key]
        if key in DEFAULT_SIZE_PARAMS:
            return dict(DEFAULT_SIZE_PARAMS[key])
        tile = max(w, h)
        return {'min_sep': round(tile * 1.8, 1), 'probability': 0.01}

    def _on_size_param(self, key, param, value):
        if key not in self._size_params:
            self._size_params[key] = dict(self._get_size_params(*key))
        self._size_params[key][param] = value

    def _schedule_preview(self):
        self._prev_timer.start(200)

    # ── mask controls ──────────────────────────────────────────────────────────

    def _set_mask_btns(self, buttons, val):
        for b in buttons:
            b.blockSignals(True); b.setChecked(val); b._update_style(); b.blockSignals(False)
        self._generate()

    def _select_all_masks(self, val): self._set_mask_btns(self._mask_btns, val)
    def _select_group(self, grp_name, val):
        self._set_mask_btns([b for b in self._mask_btns if b._group == grp_name], val)

    def _on_mask_toggle(self):
        if self._active_masks(): self._generate()
        else: self._status.setText('Выберите хотя бы одну маску.')

    def _active_masks(self):
        flat = [m for _, ms in self.mask_groups for m in ms]
        return [m for m, btn in zip(flat, self._mask_btns) if btn.isChecked()]

    # ── size controls ──────────────────────────────────────────────────────────

    def _set_size(self, w, h):
        if w:
            self.w_tiles = w
            for b in self._w_grp.buttons(): b.setChecked(self._w_grp.id(b)==w)
        if h:
            self.h_tiles = h
            for b in self._h_grp.buttons(): b.setChecked(self._h_grp.id(b)==h)
        self._refresh_size_btns(); self._generate()

    # ── generation ─────────────────────────────────────────────────────────────

    def _generate(self):
        active = self._active_masks()
        if not active: self._status.setText('Выберите хотя бы одну маску.'); return
        self._seed += 1; rng = random.Random(self._seed*99991)
        w, h = self.w_tiles, self.h_tiles; px_w, px_h = w*UNIT, h*UNIT
        th, tw = self.tex_arr.shape[:2]
        self._generated = []
        for _ in range(GEN_N):
            m      = rng.choice(active)
            angle  = rng.uniform(0,360)
            flip_h = rng.choice([True,False]); flip_v = rng.choice([True,False])
            cx = rng.randint(0, max(0,tw-px_w)); cy = rng.randint(0, max(0,th-px_h))
            rgba, preview = make_decal(m, px_w, px_h, angle, flip_h, flip_v,
                                       self.tex_arr, self.bg_tile, cx, cy,
                                       100, 0, self.tile_mean)
            self._generated.append(dict(
                rgba=rgba, preview=preview, w=w, h=h, pw=px_w, ph=px_h,
                mask=m, angle=angle, flip_h=flip_h, flip_v=flip_v, cx=cx, cy=cy,
                scale=1.0, mx=0, my=0))
        self._refresh_left(); self._update_status()

    def _refresh_left(self):
        while self._gen_grid.count():
            item = self._gen_grid.takeAt(0)
            if item.widget(): item.widget().deleteLater()
        for i, d in enumerate(self._generated):
            self._gen_grid.addWidget(DecalThumb(d, i, self._add_decal), i//GEN_COLS, i%GEN_COLS)

    # ── selection ──────────────────────────────────────────────────────────────

    def _add_decal(self, decal):
        entry = dict(decal)   # independent copy so override fields are per-selection
        entry.setdefault('scale', 1.0)
        entry.setdefault('mx', 0)
        entry.setdefault('my', 0)
        entry.update(ov_alpha=100, ov_blend=0)
        self._selected.append(entry)
        self._refresh_right(); self._schedule_preview(); self._update_status()

    def _remove_decal(self, idx):
        if QMessageBox.question(self,'Удалить?',f'Удалить декаль #{idx+1}?',
                                QMessageBox.Yes|QMessageBox.No) == QMessageBox.Yes:
            self._selected.pop(idx)
            self._refresh_right(); self._schedule_preview(); self._update_status()

    def _refresh_right(self):
        lay = self._right_l
        while lay.count() > 1:
            item = lay.takeAt(0)
            if item.widget(): item.widget().deleteLater()
        if not self._selected:
            lbl = QLabel('Нет выбранных декалей.')
            lbl.setStyleSheet('color:#555; padding:10px;')
            lay.insertWidget(0, lbl); return
        groups = defaultdict(list)
        for i, d in enumerate(self._selected): groups[(d['w'],d['h'])].append((i,d))
        pos = 0
        for (w, h), items in sorted(groups.items()):
            p = self._get_size_params(w, h)

            hdr = QWidget()
            hdr.setStyleSheet('background:#252525; border-radius:3px;')
            hl = QHBoxLayout(hdr); hl.setContentsMargins(6,4,6,4); hl.setSpacing(8)

            lbl = QLabel(f'{w}×{h}  ({len(items)} шт.)')
            lbl.setStyleSheet('color:#aaa; font-weight:bold;')
            hl.addWidget(lbl)

            hl.addWidget(_sep_label('sep:'))
            sep_sb = QDoubleSpinBox()
            sep_sb.setRange(0.0, 200.0); sep_sb.setDecimals(1); sep_sb.setSingleStep(0.5)
            sep_sb.setValue(p['min_sep']); sep_sb.setFixedWidth(72)
            sep_sb.setSpecialValueText('—')
            sep_sb.setToolTip('Минимальное расстояние между декалями (тайлов). 0 = не задано')
            sep_sb.valueChanged.connect(lambda v, k=(w,h): self._on_size_param(k, 'min_sep', v))
            hl.addWidget(sep_sb)

            hl.addWidget(_sep_label('prob:'))
            prob_sb = QDoubleSpinBox()
            prob_sb.setRange(0.0, 1.0); prob_sb.setDecimals(4); prob_sb.setSingleStep(0.001)
            prob_sb.setValue(p['probability']); prob_sb.setFixedWidth(78)
            prob_sb.setToolTip('Вероятность появления на тайл (probability_expression)')
            prob_sb.valueChanged.connect(lambda v, k=(w,h): self._on_size_param(k, 'probability', v))
            hl.addWidget(prob_sb)
            hl.addStretch()

            lay.insertWidget(pos, hdr); pos += 1

            row = QWidget(); rl = QHBoxLayout(row)
            rl.setContentsMargins(4,0,4,0); rl.setSpacing(6)
            for orig_i, d in items:
                rl.addWidget(SelectedDecalThumb(d,
                    self.tex_arr, self.bg_tile, self.tile_mean,
                    self.mask_groups,
                    on_delete=lambda _,i=orig_i: self._remove_decal(i),
                    on_change=self._schedule_preview))
            rl.addStretch(); lay.insertWidget(pos, row); pos += 1

    # ── in-game preview (background thread) ───────────────────────────────────

    def _refresh_preview(self):
        if not self._selected:
            self._preview.clear(); return

        self._preview_gen += 1
        gen = self._preview_gen
        self._preview.show_loading()

        # Snapshot everything the worker thread needs (no shared mutable state)
        decal_params = [
            (d['mask'], d['pw'], d['ph'], d['w'], d['h'],
             d['angle'], d['flip_h'], d['flip_v'], d['cx'], d['cy'],
             d.get('ov_alpha', 100),
             d.get('ov_blend', 0),
             self._get_size_params(d['w'], d['h'])['min_sep'],
             self._get_size_params(d['w'], d['h'])['probability'],
             d.get('scale', 1.0),
             d.get('mx', 0), d.get('my', 0))
            for d in self._selected
        ]
        tex_arr   = self.tex_arr
        bg_tile   = self.bg_tile
        tile_mean = self.tile_mean

        fn = lambda: _make_preview_image(decal_params, tex_arr, bg_tile, tile_mean)
        thread = _PreviewThread(fn, parent=self)
        # Qt queued connection: result slot runs in the main thread automatically
        thread.result.connect(lambda img, g=gen: self._apply_preview(img, g))
        thread.error.connect(lambda msg: print(f'[preview error]\n{msg}', flush=True))
        thread.finished.connect(thread.deleteLater)
        # Keep a reference so the thread isn't GC'd before it finishes
        self._preview_thread = thread
        thread.start()

    def _apply_preview(self, img, gen):
        if gen == self._preview_gen:
            self._preview.set_image(img)

    # ── status ─────────────────────────────────────────────────────────────────

    def _update_status(self):
        if not self._selected: self._status.setText('Нет выбранных декалей.'); return
        packer, _ = pack_sprites(self._selected)
        used = sum(d['pw']*d['ph'] for d in self._selected)
        tot  = ATLAS_W*packer.h; fill = 100*used/tot if tot else 0
        rem  = [f'{wt}×{ht}×{packer.count_fitting(wt*UNIT,ht*UNIT)}'
                for wt,ht in PROBE_SIZES if packer.count_fitting(wt*UNIT,ht*UNIT) > 0]
        self._status.setText(
            f'{len(self._selected)} декалей  |  Атлас: {ATLAS_W}×{packer.h}  |  '
            f'Заполнение: {fill:.1f}%'
            + (f'  |  ещё: {", ".join(rem)}' if rem else ''))

    # ── state persistence ──────────────────────────────────────────────────────

    def _flat_masks(self):
        return [m for _, ms in self.mask_groups for m in ms]

    def _save_state(self):
        flat = self._flat_masks()
        mask_to_idx = {id(m): i for i, m in enumerate(flat)}
        selected_out = []
        for d in self._selected:
            selected_out.append({
                'mask_idx':   mask_to_idx.get(id(d['mask']), 0),
                'w': d['w'], 'h': d['h'],
                'angle':      d['angle'],
                'flip_h':     d['flip_h'],
                'flip_v':     d['flip_v'],
                'cx':         d['cx'],
                'cy':         d['cy'],
                'scale':      d.get('scale', 1.0),
                'mx':         d.get('mx', 0),
                'my':         d.get('my', 0),
                'use_override': d.get('use_override', False),
                'ov_alpha':   d.get('ov_alpha', 100),
                'ov_blend':   d.get('ov_blend', 25),
            })
        size_params_out = {f'{w}x{h}': p for (w, h), p in self._size_params.items()}
        state = {
            'w_tiles':    self.w_tiles,
            'h_tiles':    self.h_tiles,
            'size_params': size_params_out,
            'selected':   selected_out,
        }
        try:
            STATE_PATH.write_text(json.dumps(state, indent=2))
        except Exception as e:
            print(f'[save_state] {e}', flush=True)

    def _load_state(self):
        if not STATE_PATH.exists(): return
        try:
            state = json.loads(STATE_PATH.read_text())
        except Exception:
            return

        flat = self._flat_masks()

        # Restore per-size params before _refresh_right reads them
        for key_str, p in state.get('size_params', {}).items():
            parts = key_str.split('x')
            if len(parts) == 2:
                try: self._size_params[(int(parts[0]), int(parts[1]))] = dict(p)
                except (ValueError, TypeError): pass

        # Restore selected decals
        self._selected = []
        for sd in state.get('selected', []):
            idx = sd.get('mask_idx', 0)
            if not (0 <= idx < len(flat)): continue
            mask = flat[idx]
            w, h   = sd.get('w', 2), sd.get('h', 2)
            px_w, px_h = w * UNIT, h * UNIT
            angle  = sd.get('angle', 0)
            flip_h = sd.get('flip_h', False)
            flip_v = sd.get('flip_v', False)
            cx     = max(0, sd.get('cx', 0))
            cy     = max(0, sd.get('cy', 0))
            scale  = sd.get('scale', 1.0)
            mx     = sd.get('mx', 0)
            my     = sd.get('my', 0)
            ov_alpha = sd.get('ov_alpha', 100)
            ov_blend = sd.get('ov_blend', 0)
            rgba, preview = make_decal(
                mask, px_w, px_h, angle, flip_h, flip_v,
                self.tex_arr, self.bg_tile, cx, cy,
                ov_alpha, ov_blend, self.tile_mean, scale, mx=mx, my=my)
            self._selected.append(dict(
                rgba=rgba, preview=preview, w=w, h=h, pw=px_w, ph=px_h,
                mask=mask, angle=angle, flip_h=flip_h, flip_v=flip_v, cx=cx, cy=cy,
                scale=scale, mx=mx, my=my, ov_alpha=ov_alpha, ov_blend=ov_blend,
            ))

        # Restore size buttons
        w = state.get('w_tiles', self.w_tiles)
        h = state.get('h_tiles', self.h_tiles)
        if w != self.w_tiles or h != self.h_tiles:
            self._set_size(w, h)

        self._refresh_right()
        self._update_status()
        if self._selected:
            self._schedule_preview()

    def closeEvent(self, event):
        self._save_state()
        super().closeEvent(event)

    # ── generate atlas ─────────────────────────────────────────────────────────

    def _do_generate(self):
        if not self._selected: QMessageBox.warning(self,'Пусто','Нет выбранных декалей.'); return
        packer, placements = pack_sprites(self._selected)
        atlas = Image.new('RGBA', (ATLAS_W, packer.h), (0,0,0,0))
        entries = []
        for s, x, y in placements:
            atlas.paste(s['rgba'], (x,y))
            entries.append({'w_tiles':s['w'],'h_tiles':s['h'],'x':x,'y':y,
                            'width':s['pw'],'height':s['ph']})

        # Collect per-size params for all sizes present in the selection
        size_keys = {(d['w'], d['h']) for d in self._selected}
        sizes_out = {}
        for (w, h) in sorted(size_keys):
            p = self._get_size_params(w, h)
            sep = p['min_sep'] if p['min_sep'] > 0 else None
            sizes_out[f'{w}x{h}'] = {
                'w_tiles':     w, 'h_tiles': h,
                'min_sep':     sep,
                'probability': p['probability'],
            }

        out_png  = ROOT/'heliara/graphics/terrain/heliara_weathered_siliceous_crust_decals.png'
        out_json = ROOT/'art_sources/weathered_siliceous_crust/textures/decals_layout.json'
        atlas.save(out_png)
        out_json.write_text(json.dumps(
            {'sheet': str(out_png), 'sizes': sizes_out, 'decals': entries}, indent=2))

        # Regenerate Lua from the saved JSON
        lua_script = ROOT/'art_sources/weathered_siliceous_crust/scripts/generate_decal_lua.py'
        import subprocess, sys
        result = subprocess.run([sys.executable, str(lua_script)], capture_output=True, text=True)
        lua_ok = result.returncode == 0
        lua_msg = result.stdout.strip() if lua_ok else f'Ошибка Lua:\n{result.stderr.strip()}'

        self._save_state()
        used = sum(s['pw']*s['ph'] for s,*_ in placements); tot = ATLAS_W*packer.h
        QMessageBox.information(self,'Готово',
            f'Сохранено:\n{out_png}\n{out_json}\n\n'
            f'{len(entries)} декалей, {ATLAS_W}×{packer.h} px, {100*used/tot:.1f}% заполнения\n\n'
            + (lua_msg if lua_ok else lua_msg))


# ── preview image builder (runs in background thread) ────────────────────────

def _make_preview_image(decal_params, tex_arr, bg_tile, tile_mean):
    W = H = CANVAS_SIZE
    rng = random.Random()

    # Tiled source with room for random chunk offsets
    tile_src = tile_fill(bg_tile, W+256, H+256)
    bg = Image.new('RGB', (W, H))

    # Layer 1: 1×1 (64 px) base — no gaps
    for ty in range(0, H, 64):
        for tx in range(0, W, 64):
            sx = rng.randint(0,255); sy = rng.randint(0,255)
            pw = min(64, W-tx); ph = min(64, H-ty)
            bg.paste(tile_src.crop((sx, sy, sx+pw, sy+ph)), (tx, ty))

    # Layer 2: random 2×2 (128 px) overlays
    n_128 = (W//128) * (H//128)   # one per 128×128 cell on average
    for _ in range(n_128):
        px = rng.randint(0, max(0, W-128))
        py = rng.randint(0, max(0, H-128))
        sx = rng.randint(0,255); sy = rng.randint(0,255)
        bg.paste(tile_src.crop((sx, sy, sx+128, sy+128)), (px, py))

    bg = bg.convert('RGBA')

    # Scatter decals to simulate game density + minimal_separation.
    #
    # minimal_separation is the minimum CENTRE-TO-CENTRE distance (in tile units)
    # between any two instances of the same decorative type.  We enforce this
    # per-type with a vectorised numpy distance check, so there is no O(n²)
    # pure-Python loop.
    #
    # count ≈ canvas_tiles × probability  (same logic the game engine uses:
    # probability_expression is evaluated once per tile candidate).
    canvas_tiles = (W // UNIT) * (H // UNIT)   # 4096 for a 4096 px canvas

    params_list = list(decal_params); rng.shuffle(params_list)
    for mask_pil, dpw, dph, w_tiles, h_tiles, angle, flip_h, flip_v, tex_cx, tex_cy, \
            ov_a, ov_b, min_sep, probability, scale, mx, my in params_list:

        count  = max(1, round(canvas_tiles * probability))
        pa, pb = ov_a, ov_b
        rgba, _ = make_decal(mask_pil, dpw, dph, angle, flip_h, flip_v,
                              tex_arr, bg_tile, tex_cx, tex_cy, pa, pb, tile_mean, scale,
                              mx=mx, my=my)

        sep_px = float((min_sep or 0.0) * UNIT)
        sep_sq = sep_px * sep_px
        hw     = dpw // 2
        hh     = dph // 2

        # Pre-generate 10× candidate positions; filter by min_sep.
        n_cand = count * 10
        cand_x = [rng.randint(0, max(0, W - dpw)) for _ in range(n_cand)]
        cand_y = [rng.randint(0, max(0, H - dph)) for _ in range(n_cand)]

        placed = []   # accepted (centre_x, centre_y) pairs for this type

        for dx, dy in zip(cand_x, cand_y):
            if len(placed) >= count:
                break
            pcx = dx + hw
            pcy = dy + hh
            if sep_sq > 0 and placed:
                arr  = np.array(placed, dtype=np.float32)
                diff = arr - np.array([pcx, pcy], dtype=np.float32)
                if not np.all((diff * diff).sum(axis=1) >= sep_sq):
                    continue
            placed.append((pcx, pcy))
            bg.paste(rgba, (dx, dy), rgba)

    return bg.convert('RGB')


# ── helpers ───────────────────────────────────────────────────────────────────

def _vline():
    f = QFrame(); f.setFrameShape(QFrame.VLine); f.setFixedWidth(2); return f

def _bold_label(text):
    l = QLabel(text); l.setStyleSheet('font-weight:bold; color:#aaa;'); return l

def _sep_label(text):
    l = QLabel(text); l.setStyleSheet('color:#666; font-size:10px;'); return l


# ── entry point ───────────────────────────────────────────────────────────────

if __name__ == '__main__':
    app = QApplication(sys.argv)
    app.setStyle('Fusion')
    app.setStyleSheet(GLOBAL_STYLE)
    w = DecalPicker(); w.show()
    sys.exit(app.exec_())
