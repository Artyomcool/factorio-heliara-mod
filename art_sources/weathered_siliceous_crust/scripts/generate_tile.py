"""
Generate heliara_weathered_siliceous_crust.png (1024x1024 sprite sheet).

Output layout:
  y=0..767,   x=0..1023  — 11 × 4×4 tile sprites (256px), 4 per row
  y=512..767, x=768..1023 — 16 × 1×1 tile sprites (64px),  4 per row
  y=768..1023, x=0..1023  — 16 × 2×2 tile sprites (128px), 8 per row

Inputs (relative to repo root):
  art_sources/weathered_siliceous_crust/tiles/base_64.png
  art_sources/weathered_siliceous_crust/tiles/base_128.png
  art_sources/weathered_siliceous_crust/masks/small_masks.png
  art_sources/weathered_siliceous_crust/textures/examples2.png

Output:
  heliara/graphics/terrain/heliara_weathered_siliceous_crust.png
  art_sources/weathered_siliceous_crust/textures/base_bg_a2.png  (copy)
"""

import numpy as np
from PIL import Image
import random, shutil, pathlib

ROOT = pathlib.Path(__file__).resolve().parents[3]

random.seed(42)
SPREAD_FACTOR = 0.66   # colour spread compression for both bg tiles and overlay textures


# ── helpers ──────────────────────────────────────────────────────────────────

def find_cell_ranges(sums, thr, min_size=10):
    dark = sums < thr
    in_cell = False; cells = []; start = None
    for i, d in enumerate(dark):
        if not d and not in_cell: in_cell = True; start = i
        elif d and in_cell:       in_cell = False; cells.append((start, i))
    if in_cell: cells.append((start, len(sums)))
    return [(s, e) for s, e in cells if e - s >= min_size]

def find_peaks(sums, distance=300):
    peaks = []
    for i in range(1, len(sums) - 1):
        if sums[i] < sums[i-1] and sums[i] < sums[i+1]:
            if not peaks or i - peaks[-1] > distance: peaks.append(i)
            elif sums[i] < sums[peaks[-1]]:           peaks[-1] = i
    return peaks

def seps_to_ranges(seps, total, min_size=200):
    bounds = [0] + seps + [total]
    return [(bounds[i]+1, bounds[i+1]) for i in range(len(bounds)-1)
            if bounds[i+1] - bounds[i] - 1 >= min_size]

def border_weight(size):
    w = np.zeros((size, size), dtype=float)
    for y in range(size):
        for x in range(size):
            d = min(x, y, size-1-x, size-1-y)
            if d <= 1:   w[y, x] = 0.0
            elif d >= 8: w[y, x] = 1.0
            else:        w[y, x] = (d - 2) / 6.0
    return w

def squeeze(src_path, factor):
    arr = np.array(Image.open(src_path).convert('RGBA'), dtype=float)
    rgb = arr[:, :, :3]
    m = rgb.mean(axis=(0, 1))
    arr[:, :, :3] = np.clip(m + (rgb - m) * factor, 0, 255)
    return Image.fromarray(arr.astype(np.uint8), 'RGBA')

def tile_fill(tile, w, h):
    tw, th = tile.size
    region = Image.new('RGBA', (w, h))
    for y in range(0, h, th):
        for x in range(0, w, tw):
            region.paste(tile, (x, y))
    return region


# ── load assets ──────────────────────────────────────────────────────────────

LOW, HIGH = 30, 160
WEIGHTS = {s: border_weight(s) for s in [64, 128, 256]}

tile64  = squeeze(ROOT / 'art_sources/weathered_siliceous_crust/tiles/base_64.png',  SPREAD_FACTOR)
tile128 = squeeze(ROOT / 'art_sources/weathered_siliceous_crust/tiles/base_128.png', SPREAD_FACTOR)
mean64  = np.array(tile64.convert('RGB'),  dtype=float).mean(axis=(0, 1))
mean128 = np.array(tile128.convert('RGB'), dtype=float).mean(axis=(0, 1))

masks_pil  = Image.open(ROOT / 'art_sources/weathered_siliceous_crust/masks/small_masks.png').convert('L')
masks_arr  = np.array(masks_pil)
thr        = masks_arr.mean(axis=1).mean() * 0.3
row_m      = find_cell_ranges(masks_arr.mean(axis=1), thr)[:8]
col_m      = find_cell_ranges(masks_arr.mean(axis=0), thr)
raw_masks  = [masks_pil.crop((x0, y0, x1, y1)) for _, (y0, y1) in enumerate(row_m)
                                                 for _, (x0, x1) in enumerate(col_m)]

tex_pil   = Image.open(ROOT / 'art_sources/weathered_siliceous_crust/textures/examples2.png').convert('RGB')
tex_arr   = np.array(tex_pil.convert('L'))
row_t     = seps_to_ranges(find_peaks(-tex_arr.mean(axis=1)), tex_arr.shape[0])
col_t     = seps_to_ranges(find_peaks(-tex_arr.mean(axis=0)), tex_arr.shape[1])

def make_textures(target):
    out = []
    for y0, y1 in row_t:
        for x0, x1 in col_t:
            crop = np.array(tex_pil.crop((x0, y0, x1, y1)), dtype=float)
            adj  = np.clip(target + (crop - crop.mean(axis=(0, 1))) * SPREAD_FACTOR, 0, 255).astype(np.uint8)
            out.append(Image.fromarray(adj))
    return out

textures64  = make_textures(mean64)
textures128 = make_textures(mean128)


# ── sprite generation ─────────────────────────────────────────────────────────

def make_mask(raw, size, angle):
    cell = raw.rotate(angle, resample=Image.BILINEAR, expand=False)
    cell = np.array(cell.resize((size, size), Image.LANCZOS), dtype=float)
    cell = np.clip((cell - LOW) / (HIGH - LOW) * 255, 0, 255)
    cell = WEIGHTS[size] * cell
    return Image.fromarray(cell.astype(np.uint8)).convert('1', dither=Image.FLOYDSTEINBERG).convert('L')

def make_sprite(size, bg_tile, textures, mask_idx):
    bg   = tile_fill(bg_tile, size, size)
    mask = make_mask(raw_masks[mask_idx % len(raw_masks)], size, random.uniform(0, 360))
    tex  = random.choice(textures)
    tw, th = tex.size
    cx, cy = random.randint(0, max(0, tw - size)), random.randint(0, max(0, th - size))
    piece  = tex.crop((cx, cy, cx + size, cy + size)).convert('RGBA')
    r, g, b, a = piece.split()
    piece  = Image.merge('RGBA', (r, g, b, mask))
    return Image.alpha_composite(bg, piece)


# ── assemble 1024×1024 sheet ──────────────────────────────────────────────────

sheet = Image.new('RGBA', (1024, 1024))

# 4×4 sprites (256px): 11 sprites — row=i//4, col=i%4 → x=col*256, y=row*256
for i in range(11):
    sheet.paste(make_sprite(256, tile128, textures128, i), ((i % 4) * 256, (i // 4) * 256))

# 1×1 sprites (64px): 16 sprites — x=768+col*64, y=512+row*64
for i in range(16):
    sheet.paste(make_sprite(64, tile64, textures64, i), (768 + (i % 4) * 64, 512 + (i // 4) * 64))

# 2×2 sprites (128px): 16 sprites — x=col*128, y=768+row*128
for i in range(16):
    sheet.paste(make_sprite(128, tile128, textures128, i), ((i % 8) * 128, 768 + (i // 8) * 128))


# ── save ──────────────────────────────────────────────────────────────────────

out_game = ROOT / 'heliara/graphics/terrain/heliara_weathered_siliceous_crust.png'
out_src  = ROOT / 'art_sources/weathered_siliceous_crust/textures/base_bg_a2.png'
sheet.save(out_game)
shutil.copy(out_game, out_src)
print(f"Saved {out_game}")
