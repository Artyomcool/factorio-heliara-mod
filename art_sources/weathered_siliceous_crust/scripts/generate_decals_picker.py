"""
Generate a 4096×4096 decal picker — 8 sizes × 8 variants, each cell 512×512.

Layout: row = size, column = variant. Each cell shows decal centred on tiled background.
Sizes (in Factorio tile units, 1 tile = 64 px):
  row 0: 1×1   (64×64)
  row 1: 2×2   (128×128)
  row 2: 2×4   (128×256)
  row 3: 4×2   (256×128)
  row 4: 4×4   (256×256)
  row 5: 2×6   (128×384)
  row 6: 6×2   (384×128)
  row 7: 8×8   (512×512)

Output:
  art_sources/weathered_siliceous_crust/textures/decals_picker.png
"""

import numpy as np
from PIL import Image, ImageDraw, ImageFont
import pathlib, random

FONT_BIG   = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 36)
FONT_SMALL = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 22)

ROOT = pathlib.Path(__file__).resolve().parents[3]

TEX_PATH  = ROOT / 'art_sources/weathered_siliceous_crust/textures/decal_source_texture.png'
TILE_PATH = ROOT / 'art_sources/weathered_siliceous_crust/tiles/base_128.png'
MASK_PATHS = [
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch01_mask_2x2_1024.png',
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch02_mask_2x2_1024.png',
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch03_mask_2x2_1024.png',
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch04_mask_2x2_1024.png',
]

UNIT     = 64     # pixels per Factorio tile
CELL     = 512    # picker cell size
VARIANTS = 8      # variants per size
LOW      = int(0.20 * 255)
HIGH     = int(0.80 * 255)

# (tiles_wide, tiles_tall) → pixel size
SIZES = [
    (1, 1),
    (2, 2),
    (2, 4),
    (4, 2),
    (4, 4),
    (2, 6),
    (6, 2),
    (8, 8),
]


def extract_quadrants(path):
    img = Image.open(path).convert('L')
    w, h = img.size
    hw, hh = w // 2, h // 2
    return [
        img.crop((0,  0,  hw, hh)),
        img.crop((hw, 0,  w,  hh)),
        img.crop((0,  hh, hw, h)),
        img.crop((hw, hh, w,  h)),
    ]


def build_mask(mask_pil, px_w, px_h, angle):
    """Rotate at source resolution, then resize to target pixel size."""
    m = mask_pil.rotate(angle, resample=Image.BILINEAR, expand=False)
    m = m.resize((px_w, px_h), Image.LANCZOS)
    arr = np.array(m, dtype=float)
    arr = np.clip((arr - LOW) / (HIGH - LOW) * 255.0, 0.0, 255.0)
    return Image.fromarray(arr.astype(np.uint8), 'L')


def tile_fill(tile, w, h):
    tw, th = tile.size
    bg = Image.new('RGB', (w, h))
    for y in range(0, h, th):
        for x in range(0, w, tw):
            bg.paste(tile, (x, y))
    return bg


def make_decal(mask_pil, px_w, px_h, angle, tex_arr, rng):
    th, tw = tex_arr.shape[:2]
    cx = rng.randint(0, max(0, tw - px_w))
    cy = rng.randint(0, max(0, th - px_h))
    crop = Image.fromarray(tex_arr[cy:cy + px_h, cx:cx + px_w]).convert('RGBA')
    mask = build_mask(mask_pil, px_w, px_h, angle)
    r, g, b, _ = crop.split()
    return Image.merge('RGBA', (r, g, b, mask))


def make_cell(decal, bg_tile, cell=CELL):
    """Decal centred on a tiled background, returned as RGB cell."""
    pw, ph = decal.size
    bg = tile_fill(bg_tile, cell, cell).convert('RGBA')
    x = (cell - pw) // 2
    y = (cell - ph) // 2
    bg.paste(decal, (x, y), decal)
    return bg.convert('RGB')


def draw_label(cell_img, number, size_label):
    draw = ImageDraw.Draw(cell_img)

    def outlined(text, x, y, font, fg=(255, 255, 255, 255), bg=(0, 0, 0, 255)):
        for dx in range(-2, 3):
            for dy in range(-2, 3):
                if dx or dy:
                    draw.text((x + dx, y + dy), text, font=font, fill=bg)
        draw.text((x, y), text, font=font, fill=fg)

    outlined(str(number),  6, 5,  FONT_BIG)
    outlined(size_label,   6, 46, FONT_SMALL)


# ── load assets ───────────────────────────────────────────────────────────────

tex_arr = np.array(Image.open(TEX_PATH).convert('RGB'))
bg_tile = Image.open(TILE_PATH).convert('RGB')

all_masks = []
for path in MASK_PATHS:
    all_masks.extend(extract_quadrants(path))   # 16 masks total


# ── build picker sheet ────────────────────────────────────────────────────────

COLS = VARIANTS
ROWS = len(SIZES)
sheet = Image.new('RGB', (COLS * CELL, ROWS * CELL), (20, 20, 20))

n = 0
for row, (tw_tiles, th_tiles) in enumerate(SIZES):
    px_w, px_h = tw_tiles * UNIT, th_tiles * UNIT
    size_label = f"{tw_tiles}×{th_tiles}"
    rng = random.Random(row * 9999)

    for col in range(VARIANTS):
        mask_pil = all_masks[(row * VARIANTS + col) % len(all_masks)]
        angle    = rng.uniform(-180, 180)

        decal    = make_decal(mask_pil, px_w, px_h, angle, tex_arr, rng)
        cell_img = make_cell(decal, bg_tile)
        draw_label(cell_img, n, size_label)

        sheet.paste(cell_img, (col * CELL, row * CELL))
        n += 1

# grid lines
draw = ImageDraw.Draw(sheet)
for i in range(COLS + 1):
    draw.line([(i * CELL, 0), (i * CELL, ROWS * CELL)], fill=(70, 70, 70), width=2)
for j in range(ROWS + 1):
    draw.line([(0, j * CELL), (COLS * CELL, j * CELL)], fill=(70, 70, 70), width=2)


# ── save ──────────────────────────────────────────────────────────────────────

out = ROOT / 'art_sources/weathered_siliceous_crust/textures/decals_picker.png'
sheet.save(out)
print(f"Saved {out}  ({sheet.size[0]}×{sheet.size[1]}, {n} decals)")
