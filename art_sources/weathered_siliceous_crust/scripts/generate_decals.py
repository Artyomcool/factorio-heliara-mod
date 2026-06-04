"""
Generate heliara_weathered_siliceous_crust_decals.png — 1024×1024 decal sprite sheet.

Output layout (all decals 256×256, 4 columns × 4 rows):
  y=0..511   (rows 0-1): 8 alpha decals     — batch01 + batch02 masks, smooth transparency
  y=512..1023 (rows 2-3): 8 dithered decals — batch03 + batch04 masks, Floyd-Steinberg binary alpha

Inputs:
  art_sources/weathered_siliceous_crust/textures/decal_source_texture.png
  art_sources/weathered_siliceous_crust/masks/batch01..04_mask_2x2_1024.png

Output:
  heliara/graphics/terrain/heliara_weathered_siliceous_crust_decals.png
"""

import numpy as np
from PIL import Image
import pathlib, random

ROOT = pathlib.Path(__file__).resolve().parents[3]
random.seed(42)

TEX_PATH = ROOT / 'art_sources/weathered_siliceous_crust/textures/decal_source_texture.png'
MASK_PATHS = [
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch01_mask_2x2_1024.png',
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch02_mask_2x2_1024.png',
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch03_mask_2x2_1024.png',
    ROOT / 'art_sources/weathered_siliceous_crust/masks/batch04_mask_2x2_1024.png',
]

DECAL_SIZE = 256
LOW  = int(0.20 * 255)   # 51  — below this → fully transparent
HIGH = int(0.80 * 255)   # 204 — above this → fully opaque


def extract_quadrants(path):
    """Split a 2×2 mask sheet into 4 individual mask arrays (top-left, top-right, …)."""
    img = Image.open(path).convert('L')
    w, h = img.size
    hw, hh = w // 2, h // 2
    return [
        np.array(img.crop((0,  0,  hw, hh)), dtype=float),   # top-left
        np.array(img.crop((hw, 0,  w,  hh)), dtype=float),   # top-right
        np.array(img.crop((0,  hh, hw, h)),  dtype=float),   # bottom-left
        np.array(img.crop((hw, hh, w,  h)),  dtype=float),   # bottom-right
    ]


def build_alpha_mask(raw_quad, dither=False):
    """Scale quadrant to DECAL_SIZE, normalise, apply border fade; optionally dither."""
    h, w = raw_quad.shape
    pil = Image.fromarray(raw_quad.astype(np.uint8)).resize(
        (DECAL_SIZE, DECAL_SIZE), Image.LANCZOS
    )
    m = np.array(pil, dtype=float)
    m = np.clip((m - LOW) / (HIGH - LOW) * 255.0, 0.0, 255.0)
    m_img = Image.fromarray(m.astype(np.uint8), 'L')
    if dither:
        m_img = m_img.convert('1', dither=Image.FLOYDSTEINBERG).convert('L')
    return m_img


def make_decal(tex_arr, mask_img, angle):
    """Random crop from texture, rotate mask, compose RGBA decal."""
    th, tw = tex_arr.shape[:2]
    cx = random.randint(0, max(0, tw - DECAL_SIZE))
    cy = random.randint(0, max(0, th - DECAL_SIZE))
    crop = Image.fromarray(tex_arr[cy:cy + DECAL_SIZE, cx:cx + DECAL_SIZE]).convert('RGBA')

    # rotate mask slightly for variety
    rotated = mask_img.rotate(angle, resample=Image.BILINEAR, expand=False)
    r, g, b, _ = crop.split()
    return Image.merge('RGBA', (r, g, b, rotated))


# ── load assets ───────────────────────────────────────────────────────────────

tex_arr = np.array(Image.open(TEX_PATH).convert('RGB'))

alpha_quads   = extract_quadrants(MASK_PATHS[0]) + extract_quadrants(MASK_PATHS[1])   # 8 masks
dither_quads  = extract_quadrants(MASK_PATHS[2]) + extract_quadrants(MASK_PATHS[3])   # 8 masks


# ── assemble sheet ────────────────────────────────────────────────────────────

sheet = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))

# rows 0-1: smooth alpha decals
for i, quad in enumerate(alpha_quads):
    mask = build_alpha_mask(quad, dither=False)
    angle = random.uniform(-15, 15)
    decal = make_decal(tex_arr, mask, angle)
    x = (i % 4) * DECAL_SIZE
    y = (i // 4) * DECAL_SIZE
    sheet.paste(decal, (x, y), decal)

# rows 2-3: dithered decals
for i, quad in enumerate(dither_quads):
    mask = build_alpha_mask(quad, dither=True)
    angle = random.uniform(-15, 15)
    decal = make_decal(tex_arr, mask, angle)
    x = (i % 4) * DECAL_SIZE
    y = 512 + (i // 4) * DECAL_SIZE
    sheet.paste(decal, (x, y), decal)


# ── save ──────────────────────────────────────────────────────────────────────

out = ROOT / 'heliara/graphics/terrain/heliara_weathered_siliceous_crust_decals.png'
sheet.save(out)
print(f"Saved {out}  ({sheet.size[0]}×{sheet.size[1]})")
