#!/usr/bin/env python3
"""
LUT editor for Heliara planet day/night color grading.
Generates 256×16 PNG LUT files for Factorio's day_night_cycle_color_lookup.

Format: 256×16 PNG, 16 blue-slices × 16 wide, each slice 16 tall.
  x = b_slice*16 + r_idx,  y = g_idx.
"""

import sys, json, pathlib
import numpy as np
from PIL import Image
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QHBoxLayout, QVBoxLayout,
    QGridLayout, QPushButton, QLabel, QSlider, QGroupBox,
    QColorDialog, QMessageBox,
)
from PyQt5.QtCore import Qt, QTimer
from PyQt5.QtGui import QPixmap, QImage, QColor

ROOT          = pathlib.Path(__file__).resolve().parents[2]
LUT_OUT_DIR   = ROOT / 'heliara/graphics/lut'
SETTINGS_PATH = pathlib.Path(__file__).parent / 'lut_settings.json'
PLANET_LUA    = ROOT / 'heliara/planet.lua'

LUT_N = 16   # 16³ LUT → 256×16 PNG

STYLE = """
QWidget { background: #1e1e1e; color: #ddd; }
QPushButton {
    background: #2d2d2d; border: 1px solid #555; border-radius: 3px;
    color: #ccc; padding: 3px 10px;
}
QPushButton:hover  { background: #3c3c3c; border-color: #888; }
QPushButton:pressed { background: #1a1a1a; }
QSlider::groove:horizontal {
    height: 4px; background: #333; border: 1px solid #444; border-radius: 2px;
}
QSlider::handle:horizontal {
    background: #5a8a6a; width: 14px; height: 14px; margin: -5px 0; border-radius: 7px;
}
QSlider::sub-page:horizontal { background: #2a5a3a; border-radius: 2px; }
QGroupBox {
    border: 1px solid #3a3a3a; border-radius: 4px;
    margin-top: 10px; color: #888; font-size: 11px;
}
QGroupBox::title { subcontrol-origin: margin; left: 8px; padding: 0 4px; }
"""

# ── LUT math ─────────────────────────────────────────────────────────────────

def make_identity_lut():
    """(N³, 3) float32 identity LUT, values in [0, 1]."""
    N = LUT_N
    idx = np.arange(N**3, dtype=np.int32)
    r = idx % N
    g = (idx // N) % N
    b = idx // (N * N)
    lut = np.stack([r, g, b], axis=1).astype(np.float32) / (N - 1)
    return lut   # order: [b, g, r] flattened


def grade_lut(lut, saturation=1.0, brightness=1.0,
              tint=(0.5, 0.4, 0.6), tint_strength=0.0):
    """Apply colour grading to a (N³, 3) float32 LUT. Returns new array."""
    r, g, b = lut[:, 0].copy(), lut[:, 1].copy(), lut[:, 2].copy()
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    r = lum + (r - lum) * saturation
    g = lum + (g - lum) * saturation
    b = lum + (b - lum) * saturation
    if tint_strength > 0:
        tr, tg, tb = tint
        r = r + (tr - r) * tint_strength
        g = g + (tg - g) * tint_strength
        b = b + (tb - b) * tint_strength
    r *= brightness; g *= brightness; b *= brightness
    return np.clip(np.stack([r, g, b], axis=1), 0, 1).astype(np.float32)


def lut_to_png(lut):
    """Convert (N³, 3) float32 → 256×16 PIL Image (Factorio LUT format)."""
    N = LUT_N
    img = Image.new('RGB', (N * N, N))
    px  = img.load()
    for i in range(N**3):
        b_s = i // (N * N)
        g_s = (i // N) % N
        r_s = i % N
        px[b_s * N + r_s, g_s] = (
            min(255, int(lut[i, 0] * 255 + 0.5)),
            min(255, int(lut[i, 1] * 255 + 0.5)),
            min(255, int(lut[i, 2] * 255 + 0.5)),
        )
    return img


def apply_lut(img_arr, lut):
    """Apply (N³,3) float32 LUT to (H,W,3) uint8 via trilinear interpolation."""
    N = LUT_N
    lut_3d = lut.reshape(N, N, N, 3)   # indexed [b, g, r, channel]
    f  = img_arr.astype(np.float32) / 255.0 * (N - 1)
    i0 = np.clip(f.astype(np.int32), 0, N - 2)
    i1 = i0 + 1
    t  = (f - i0).astype(np.float32)
    ri0, gi0, bi0 = i0[:, :, 0], i0[:, :, 1], i0[:, :, 2]
    ri1, gi1, bi1 = i1[:, :, 0], i1[:, :, 1], i1[:, :, 2]
    tr = t[:, :, 0:1]; tg = t[:, :, 1:2]; tb = t[:, :, 2:3]
    out = (
        lut_3d[bi0, gi0, ri0] * (1-tr)*(1-tg)*(1-tb) +
        lut_3d[bi0, gi0, ri1] *    tr *(1-tg)*(1-tb) +
        lut_3d[bi0, gi1, ri0] * (1-tr)*   tg *(1-tb) +
        lut_3d[bi0, gi1, ri1] *    tr *   tg *(1-tb) +
        lut_3d[bi1, gi0, ri0] * (1-tr)*(1-tg)*   tb  +
        lut_3d[bi1, gi0, ri1] *    tr *(1-tg)*   tb  +
        lut_3d[bi1, gi1, ri0] * (1-tr)*   tg *   tb  +
        lut_3d[bi1, gi1, ri1] *    tr *   tg *   tb
    )
    return np.clip(out * 255, 0, 255).astype(np.uint8)


def make_reference(w=520, h=130):
    """Vectorised HSV hue chart (top ¾) + grayscale ramp (bottom ¼)."""
    arr = np.zeros((h, w, 3), dtype=np.uint8)
    ch  = int(h * 0.75)

    H  = np.linspace(0, 1, w, endpoint=False).astype(np.float32)[np.newaxis, :]  # (1,w)
    Yr = np.arange(ch, dtype=np.float32)[:, np.newaxis] / ch                      # (ch,1)
    S  = np.maximum(0.15, 1.0 - Yr * 0.80).astype(np.float32)
    V  = np.maximum(0.10, 0.90 - Yr * 0.45).astype(np.float32)

    H6 = H * 6.0
    i  = H6.astype(np.int32) % 6
    f  = (H6 - np.floor(H6)).astype(np.float32)
    p  = V * (1 - S)
    q  = V * (1 - S * f)
    t_ = V * (1 - S * (1 - f))

    sel = np.broadcast_to(i, (ch, w))
    R = np.select([sel==0, sel==1, sel==2, sel==3, sel==4, sel==5], [V, q, p, p, t_, V])
    G = np.select([sel==0, sel==1, sel==2, sel==3, sel==4, sel==5], [t_, V, V, q, p, p])
    B = np.select([sel==0, sel==1, sel==2, sel==3, sel==4, sel==5], [p, p, t_, V, V, q])

    arr[:ch, :, 0] = np.clip(R * 255, 0, 255).astype(np.uint8)
    arr[:ch, :, 1] = np.clip(G * 255, 0, 255).astype(np.uint8)
    arr[:ch, :, 2] = np.clip(B * 255, 0, 255).astype(np.uint8)

    ramp = np.linspace(0, 255, w).astype(np.uint8)[np.newaxis, :]
    arr[ch:, :, 0] = arr[ch:, :, 1] = arr[ch:, :, 2] = ramp

    return Image.fromarray(arr)


def pil_to_qpixmap(img):
    data = img.tobytes('raw', 'RGB')
    qi   = QImage(data, img.width, img.height, img.width * 3, QImage.Format_RGB888)
    return QPixmap.fromImage(qi)

# ── planet.lua patching ───────────────────────────────────────────────────────

LUT_BLOCK = [
    'day_night_cycle_color_lookup = {',
    '    { 0.00, "__heliara__/graphics/lut/identity.png" },',  # noon
    '    { 0.25, "__heliara__/graphics/lut/identity.png" },',  # sun starts to set
    '    { 0.35, "__heliara__/graphics/lut/dawn_dusk.png" },', # mid-dusk
    '    { 0.45, "__heliara__/graphics/lut/night.png" },',     # fully dark
    '    { 0.55, "__heliara__/graphics/lut/night.png" },',     # still night
    '    { 0.65, "__heliara__/graphics/lut/dawn_dusk.png" },', # mid-dawn
    '    { 0.75, "__heliara__/graphics/lut/identity.png" },',  # sun fully risen
    '    { 1.00, "__heliara__/graphics/lut/identity.png" },',  # noon
    '},',
]


def patch_planet_lua(lua_text):
    """Replace the day_night_cycle_color_lookup block in planet.lua."""
    lines = lua_text.split('\n')
    start = next((i for i, l in enumerate(lines)
                  if 'day_night_cycle_color_lookup' in l and '=' in l), None)
    if start is None:
        return lua_text

    depth = 0
    end   = start
    for i in range(start, len(lines)):
        depth += lines[i].count('{') - lines[i].count('}')
        if depth <= 0:
            end = i; break

    indent   = len(lines[start]) - len(lines[start].lstrip())
    ind      = ' ' * indent
    new_lines = [ind + l for l in LUT_BLOCK]
    return '\n'.join(lines[:start] + new_lines + lines[end + 1:])

# ── Widgets ───────────────────────────────────────────────────────────────────

class ColorButton(QPushButton):
    def __init__(self, rgb=(0.5, 0.4, 0.8), on_change=None, parent=None):
        super().__init__(parent)
        self._rgb = tuple(rgb); self._cb = on_change
        self.setFixedSize(40, 22); self._refresh()
        self.clicked.connect(self._pick)

    def _refresh(self):
        r, g, b = (int(c * 255) for c in self._rgb)
        self.setStyleSheet(f'background:rgb({r},{g},{b});border:1px solid #777;border-radius:2px;')

    def _pick(self):
        r, g, b = (int(c * 255) for c in self._rgb)
        c = QColorDialog.getColor(QColor(r, g, b), self)
        if c.isValid():
            self._rgb = (c.redF(), c.greenF(), c.blueF())
            self._refresh()
            if self._cb: self._cb()

    def get_rgb(self):   return self._rgb
    def set_rgb(self, v): self._rgb = tuple(v); self._refresh()


class PresetPanel(QGroupBox):
    _ROWS = [
        ('saturation',    'Насыщ.:',    0, 100, 100, '%'),
        ('brightness',    'Яркость:',  50, 130, 100, '%'),
        ('tint_strength', 'Оттенок:',   0,  50, 100, '%'),
    ]

    def __init__(self, title, defaults, on_change, parent=None):
        super().__init__(title, parent)
        self._cb = on_change
        self._p  = dict(defaults)
        self._sl = {}; self._vl = {}

        gl = QGridLayout(self); gl.setSpacing(4); gl.setContentsMargins(8, 14, 8, 8)

        for row, (key, label, lo, hi, sc, suf) in enumerate(self._ROWS):
            gl.addWidget(QLabel(label), row, 0)
            sl = QSlider(Qt.Horizontal); sl.setRange(lo, hi)
            sl.setValue(round(self._p.get(key, 0) * sc))
            vl = QLabel(f'{round(self._p.get(key,0)*sc)}{suf}')
            vl.setFixedWidth(42); vl.setAlignment(Qt.AlignRight | Qt.AlignVCenter)
            sl.valueChanged.connect(
                lambda v, k=key, l=vl, s=sc, u=suf: self._on_sl(k, v, l, s, u))
            cw = QWidget(); cl = QHBoxLayout(cw)
            cl.setContentsMargins(0, 0, 0, 0); cl.setSpacing(0)
            cl.addWidget(sl); cl.addWidget(vl)
            gl.addWidget(cw, row, 1)
            self._sl[key] = sl; self._vl[key] = vl

        r = len(self._ROWS)
        gl.addWidget(QLabel('Цвет:'), r, 0)
        self._color_btn = ColorButton(tuple(defaults.get('tint', (0.5, 0.5, 0.5))), on_change)
        gl.addWidget(self._color_btn, r, 1, alignment=Qt.AlignLeft)

    def _on_sl(self, key, val, vl, sc, suf):
        self._p[key] = val / sc
        vl.setText(f'{val}{suf}')
        self._cb()

    def get_params(self):
        return {**self._p, 'tint': self._color_btn.get_rgb()}

    def set_params(self, p):
        for key, _, lo, hi, sc, suf in self._ROWS:
            if key not in p: continue
            self._p[key] = float(p[key])
            v = round(self._p[key] * sc)
            self._sl[key].blockSignals(True); self._sl[key].setValue(v); self._sl[key].blockSignals(False)
            self._vl[key].setText(f'{v}{suf}')
        if 'tint' in p:
            self._color_btn.set_rgb(tuple(p['tint']))

# ── Main window ───────────────────────────────────────────────────────────────

class LUTEditor(QMainWindow):
    PW, PH = 520, 130

    NIGHT_DEF = {'saturation': 0.15, 'brightness': 0.85,
                 'tint': (0.45, 0.35, 0.65), 'tint_strength': 0.12}
    DAWN_DEF  = {'saturation': 0.60, 'brightness': 0.93,
                 'tint': (0.60, 0.45, 0.30), 'tint_strength': 0.00}

    def __init__(self):
        super().__init__()
        self.setWindowTitle('LUT Editor — Heliara')
        self.resize(930, 500)
        self._ref     = make_reference(self.PW, self.PH)
        self._ref_arr = np.array(self._ref)
        self._lut_id  = make_identity_lut()
        self._deb     = QTimer(self); self._deb.setSingleShot(True)
        self._deb.timeout.connect(self._update_preview)
        self._build_ui()
        self._load_settings()
        self._update_preview()

    # ── UI ────────────────────────────────────────────────────────────────────

    def _build_ui(self):
        root = QWidget(); self.setCentralWidget(root)
        rl = QHBoxLayout(root); rl.setContentsMargins(8, 8, 8, 8); rl.setSpacing(12)

        # Left: presets + save
        left = QWidget(); left.setFixedWidth(300)
        ll = QVBoxLayout(left); ll.setContentsMargins(0, 0, 0, 0); ll.setSpacing(8)

        self._night = PresetPanel('Ночь',              self.NIGHT_DEF, self._schedule)
        self._dawn  = PresetPanel('Рассвет / Закат',   self.DAWN_DEF,  self._schedule)
        ll.addWidget(self._night)
        ll.addWidget(self._dawn)
        ll.addStretch()

        save_btn = QPushButton('💾  Сохранить LUT в игру')
        save_btn.setFixedHeight(34)
        save_btn.setStyleSheet('font-weight:bold; font-size:12px;')
        save_btn.clicked.connect(self._save)
        ll.addWidget(save_btn)
        rl.addWidget(left)

        # Right: preview strips
        right = QWidget(); rv = QVBoxLayout(right)
        rv.setContentsMargins(0, 0, 0, 0); rv.setSpacing(6)

        self._pv = {}
        for key, label in [('day', 'День'), ('dawn', 'Рассвет / Закат'), ('night', 'Ночь')]:
            row = QWidget(); rl2 = QHBoxLayout(row)
            rl2.setContentsMargins(0, 0, 0, 0); rl2.setSpacing(6)
            lbl = QLabel(label); lbl.setFixedWidth(110)
            lbl.setAlignment(Qt.AlignRight | Qt.AlignVCenter)
            lbl.setStyleSheet('color:#888; font-size:10px;')
            img = QLabel(); img.setFixedSize(self.PW, self.PH)
            img.setStyleSheet('border:1px solid #444;')
            rl2.addWidget(lbl); rl2.addWidget(img)
            rv.addWidget(row)
            self._pv[key] = img

        rv.addStretch()
        rl.addWidget(right, stretch=1)

    # ── preview ───────────────────────────────────────────────────────────────

    def _schedule(self): self._deb.start(60)

    def _update_preview(self):
        self._pv['day'].setPixmap(pil_to_qpixmap(self._ref))
        for key, panel in [('dawn', self._dawn), ('night', self._night)]:
            p   = panel.get_params()
            lut = grade_lut(self._lut_id, p['saturation'], p['brightness'],
                            p['tint'], p['tint_strength'])
            self._pv[key].setPixmap(
                pil_to_qpixmap(Image.fromarray(apply_lut(self._ref_arr, lut))))

    # ── persistence ───────────────────────────────────────────────────────────

    def _load_settings(self):
        if not SETTINGS_PATH.exists(): return
        try:
            s = json.loads(SETTINGS_PATH.read_text())
            if 'night' in s: self._night.set_params(s['night'])
            if 'dawn'  in s: self._dawn.set_params(s['dawn'])
        except Exception as e:
            print(f'[load_settings] {e}', flush=True)

    def _save_settings(self):
        def ser(p):
            return {k: (list(v) if isinstance(v, tuple) else v) for k, v in p.items()}
        SETTINGS_PATH.parent.mkdir(parents=True, exist_ok=True)
        SETTINGS_PATH.write_text(json.dumps(
            {'night': ser(self._night.get_params()), 'dawn': ser(self._dawn.get_params())},
            indent=2))

    # ── save ──────────────────────────────────────────────────────────────────

    def _save(self):
        LUT_OUT_DIR.mkdir(parents=True, exist_ok=True)

        lut_to_png(self._lut_id).save(LUT_OUT_DIR / 'identity.png')

        p = self._dawn.get_params()
        lut_to_png(grade_lut(self._lut_id, p['saturation'], p['brightness'],
                             p['tint'], p['tint_strength'])).save(LUT_OUT_DIR / 'dawn_dusk.png')

        p = self._night.get_params()
        lut_to_png(grade_lut(self._lut_id, p['saturation'], p['brightness'],
                             p['tint'], p['tint_strength'])).save(LUT_OUT_DIR / 'night.png')

        self._save_settings()

        lua = PLANET_LUA.read_text()
        PLANET_LUA.write_text(patch_planet_lua(lua))

        QMessageBox.information(self, 'Готово',
            f'Записано в {LUT_OUT_DIR}:\n'
            '  identity.png  (день)\n'
            '  dawn_dusk.png (рассвет/закат)\n'
            '  night.png     (ночь)\n\n'
            'heliara/planet.lua обновлён.')


if __name__ == '__main__':
    app = QApplication(sys.argv)
    app.setStyle('Fusion')
    app.setStyleSheet(STYLE)
    w = LUTEditor(); w.show()
    sys.exit(app.exec_())
