#!/usr/bin/env python3
"""
Build a single combined atlas containing Atlas 1 + Atlas 2 content:

  Atlas-1 sprites (16): large masks, trim → fit within LARGE_FIT_SIZE×LARGE_FIT_SIZE
                         preserving aspect ratio → apply texture
  Atlas-2 large (16):   same masks, trim → random rotation → 80% natural size → apply texture
  Atlas-2 small (64):   8×8 small masks, trim → 80% natural size → apply texture

Total: 96 sprites packed into one 2048×2048 RGBA atlas.

Output (in art_sources/carbon_slag_decals/debug/):
  combined_atlas.png        — final atlas
  combined_atlas_marked.png — marked with red=atlas1, orange=atlas2-large, blue=atlas2-small
"""

import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

# ── config ───────────────────────────────────────────────────────────────────
ATLAS_SIZE      = 2048
LARGE_FIT_SIZE  = 448    # Atlas-1 sprites fitted into this square (preserving aspect)
ATLAS2_SCALE    = 0.80   # Atlas-2 sprites: 80% of natural trimmed size
THRESHOLD       = int(255 * 0.08)   # 8% gray trim threshold
PADDING         = 4
SEED            = 42

BASE        = Path(__file__).parent.parent / 'art_sources/carbon_slag_decals'
LARGE_MASKS = BASE / 'masks/iron_carbon_slag_16_masks_grid_v1.png'
SMALL_MASKS = BASE / 'masks/carbon_slag_small_masks_8x8_generated_original.png'
TEXTURE     = BASE / 'textures/carbon_slag_material_texture_generated.png'
OUT_DIR     = BASE / 'debug'

REPO        = Path(__file__).parent.parent
GAME_ATLAS  = REPO / 'heliara/graphics/decal/slag/carbon_slag_combined_atlas.png'
LUA_OUT     = REPO / 'heliara/decal/iron_carbon_slag.lua'

random.seed(SEED)
np.random.seed(SEED)


# ── helpers ──────────────────────────────────────────────────────────────────

def slice_grid(arr: np.ndarray, rows: int, cols: int) -> list[np.ndarray]:
    h, w = arr.shape
    cells = []
    for r in range(rows):
        for c in range(cols):
            y0 = int(round(r * h / rows))
            y1 = int(round((r + 1) * h / rows))
            x0 = int(round(c * w / cols))
            x1 = int(round((c + 1) * w / cols))
            cells.append(arr[y0:y1, x0:x1])
    return cells


def trim_mask(arr: np.ndarray, pad: int = 6) -> np.ndarray | None:
    mask = arr > THRESHOLD
    rows_any = np.any(mask, axis=1)
    cols_any = np.any(mask, axis=0)
    if not rows_any.any():
        return None
    r0, r1 = np.where(rows_any)[0][[0, -1]]
    c0, c1 = np.where(cols_any)[0][[0, -1]]
    r0 = max(0, r0 - pad)
    r1 = min(arr.shape[0] - 1, r1 + pad)
    c0 = max(0, c0 - pad)
    c1 = min(arr.shape[1] - 1, c1 + pad)
    return arr[r0:r1 + 1, c0:c1 + 1]


def sample_texture(tex: np.ndarray, w: int, h: int) -> np.ndarray:
    """Random tiling crop of size w×h from tex."""
    th, tw = tex.shape[:2]
    rx = random.randint(0, tw - 1)
    ry = random.randint(0, th - 1)
    xs = (np.arange(w) + rx) % tw
    ys = (np.arange(h) + ry) % th
    return tex[np.ix_(ys, xs)]


def apply_mask_texture(mask_pil: Image.Image, tex: np.ndarray) -> Image.Image | None:
    """Sample texture at the same size as mask, apply mask as alpha."""
    w, h = mask_pil.size
    if w < 1 or h < 1:
        return None
    mask_arr = np.array(mask_pil)
    if mask_arr.max() == 0:
        return None
    rgb = sample_texture(tex, w, h)
    rgba = np.dstack([rgb, mask_arr]).astype(np.uint8)
    return Image.fromarray(rgba, 'RGBA')


def pil_trim(pil: Image.Image) -> Image.Image:
    """Trim black padding from a grayscale PIL image using the 8% threshold."""
    arr = np.array(pil)
    result = trim_mask(arr)
    return Image.fromarray(result, 'L') if result is not None else pil


def fit_mask(arr: np.ndarray, fit_size: int, angle_deg: float = 0.0) -> Image.Image:
    """Trim → rotate → trim again → fit into fit_size×fit_size preserving aspect."""
    pil = Image.fromarray(arr, 'L')
    if angle_deg != 0.0:
        pil = pil.rotate(angle_deg, expand=True, resample=Image.BICUBIC)
        pil = pil_trim(pil)
    scale = min(fit_size / pil.width, fit_size / pil.height)
    new_w = max(1, int(pil.width  * scale))
    new_h = max(1, int(pil.height * scale))
    return pil.resize((new_w, new_h), Image.LANCZOS)


def scale_mask(arr: np.ndarray, scale: float, angle_deg: float = 0.0) -> Image.Image:
    """Trim → rotate → trim again → scale to fraction of natural size."""
    pil = Image.fromarray(arr, 'L')
    if angle_deg != 0.0:
        pil = pil.rotate(angle_deg, expand=True, resample=Image.BICUBIC)
        pil = pil_trim(pil)
    new_w = max(1, int(pil.width  * scale))
    new_h = max(1, int(pil.height * scale))
    return pil.resize((new_w, new_h), Image.LANCZOS)


# ── MaxRects bin packer ───────────────────────────────────────────────────────

class MaxRects:
    def __init__(self, width: int, height: int):
        self.W, self.H = width, height
        self.free: list[tuple[int,int,int,int]] = [(0, 0, width, height)]

    def place(self, w: int, h: int) -> tuple[int,int] | None:
        best_x, best_y, best_score = -1, -1, float('inf')
        for (fx, fy, fw, fh) in self.free:
            if fw >= w and fh >= h:
                score = min(fw - w, fh - h)
                if score < best_score:
                    best_score, best_x, best_y = score, fx, fy
        if best_x < 0:
            return None
        self._split(best_x, best_y, w, h)
        return best_x, best_y

    def _split(self, px: int, py: int, pw: int, ph: int):
        new_free: list[tuple[int,int,int,int]] = []
        for (fx, fy, fw, fh) in self.free:
            if not (px < fx + fw and px + pw > fx and py < fy + fh and py + ph > fy):
                new_free.append((fx, fy, fw, fh))
                continue
            if px > fx:
                new_free.append((fx, fy, px - fx, fh))
            if px + pw < fx + fw:
                new_free.append((px + pw, fy, fx + fw - (px + pw), fh))
            if py > fy:
                new_free.append((fx, fy, fw, py - fy))
            if py + ph < fy + fh:
                new_free.append((fx, py + ph, fw, fy + fh - (py + ph)))
        pruned: list[tuple[int,int,int,int]] = []
        for r in new_free:
            if not any(
                r2 != r
                and r2[0] <= r[0] and r2[1] <= r[1]
                and r2[0]+r2[2] >= r[0]+r[2]
                and r2[1]+r2[3] >= r[1]+r[3]
                for r2 in new_free
            ):
                pruned.append(r)
        self.free = pruned


# ── main ─────────────────────────────────────────────────────────────────────

def main():
    tex = np.array(Image.open(TEXTURE).convert('RGB'))

    large_src = np.array(Image.open(LARGE_MASKS).convert('L'))
    large_cells = slice_grid(large_src, 4, 4)

    small_src = np.array(Image.open(SMALL_MASKS).convert('L'))
    small_cells = slice_grid(small_src, 8, 8)

    large_angles = [random.uniform(0, 360) for _ in large_cells]

    sprites: list[tuple[Image.Image, str]] = []  # (RGBA sprite, type label)

    # Atlas-1: 16 large, fitted into LARGE_FIT_SIZE, no rotation
    print(f'Atlas-1 large (fit into {LARGE_FIT_SIZE}px):')
    for i, cell in enumerate(large_cells):
        trimmed = trim_mask(cell)
        if trimmed is None:
            print(f'  #{i}: empty')
            continue
        mask_pil = fit_mask(trimmed, LARGE_FIT_SIZE)
        sprite = apply_mask_texture(mask_pil, tex)
        if sprite is None:
            continue
        sprites.append((sprite, 'atlas1'))
    print(f'  → {sum(1 for _, t in sprites if t == "atlas1")} sprites')

    # Atlas-2 large: 16 large, natural trimmed size × 80%, random rotation
    print(f'Atlas-2 large (×{ATLAS2_SCALE}, rotated):')
    count_before = len(sprites)
    for i, (cell, angle) in enumerate(zip(large_cells, large_angles)):
        trimmed = trim_mask(cell)
        if trimmed is None:
            continue
        mask_pil = scale_mask(trimmed, ATLAS2_SCALE, angle)
        sprite = apply_mask_texture(mask_pil, tex)
        if sprite is None:
            continue
        sprites.append((sprite, 'atlas2_large'))
    print(f'  → {len(sprites) - count_before} sprites')

    # Atlas-2 small: 64 small, natural trimmed size × 80%
    print(f'Atlas-2 small (×{ATLAS2_SCALE}):')
    count_before = len(sprites)
    for i, cell in enumerate(small_cells):
        trimmed = trim_mask(cell)
        if trimmed is None:
            print(f'  small #{i}: empty')
            continue
        mask_pil = scale_mask(trimmed, ATLAS2_SCALE)
        sprite = apply_mask_texture(mask_pil, tex)
        if sprite is None:
            continue
        sprites.append((sprite, 'atlas2_small'))
    print(f'  → {len(sprites) - count_before} sprites')

    print(f'\nTotal: {len(sprites)} sprites to pack into {ATLAS_SIZE}×{ATLAS_SIZE}')

    # Sort largest first for better packing
    sprites.sort(key=lambda t: (-t[0].height, -t[0].width))

    packer = MaxRects(ATLAS_SIZE, ATLAS_SIZE)
    atlas  = Image.new('RGBA', (ATLAS_SIZE, ATLAS_SIZE), (0, 0, 0, 0))
    marked = Image.new('RGBA', (ATLAS_SIZE, ATLAS_SIZE), (20, 20, 20, 255))
    draw   = ImageDraw.Draw(marked)

    color_map = {
        'atlas1':       (255, 60,  60,  200),
        'atlas2_large': (255, 180, 40,  200),
        'atlas2_small': (60,  140, 255, 200),
        'filler':       (120, 255, 120, 200),
    }

    placed, unplaced = 0, 0
    used_area = 0
    placements = []

    for sprite, label in sprites:
        sw, sh = sprite.size
        pos = packer.place(sw + PADDING, sh + PADDING)
        if pos is None:
            unplaced += 1
            continue
        x, y = pos
        atlas.paste(sprite, (x, y), sprite)
        marked.paste(sprite, (x, y), sprite)
        draw.rectangle([x, y, x + sw - 1, y + sh - 1],
                       outline=color_map[label], width=2)
        used_area += sw * sh
        placements.append({'label': label, 'x': x, 'y': y, 'w': sw, 'h': sh})
        placed += 1

    # ── filler: pack small masks into remaining free space ────────────────────
    # Pre-trim all small cells once, reuse with fresh texture crops each time
    small_trimmed = [trim_mask(c) for c in small_cells]
    small_trimmed = [t for t in small_trimmed if t is not None]

    filler_count = 0
    consecutive_fails = 0
    MAX_FAILS = 200  # stop after this many misses in a row

    while consecutive_fails < MAX_FAILS:
        t = random.choice(small_trimmed)
        mask_pil = scale_mask(t, ATLAS2_SCALE)
        sprite = apply_mask_texture(mask_pil, tex)
        if sprite is None:
            consecutive_fails += 1
            continue
        sw, sh = sprite.size
        pos = packer.place(sw + PADDING, sh + PADDING)
        if pos is None:
            consecutive_fails += 1
            continue
        consecutive_fails = 0
        x, y = pos
        atlas.paste(sprite, (x, y), sprite)
        marked.paste(sprite, (x, y), sprite)
        draw.rectangle([x, y, x + sw - 1, y + sh - 1],
                       outline=color_map['filler'], width=1)
        used_area += sw * sh
        placements.append({'label': 'filler', 'x': x, 'y': y, 'w': sw, 'h': sh})
        filler_count += 1

    print(f'Filler sprites added: {filler_count}')

    OUT_DIR.mkdir(exist_ok=True)
    atlas.save(OUT_DIR / 'combined_atlas.png')
    marked.save(OUT_DIR / 'combined_atlas_marked.png')
    GAME_ATLAS.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(GAME_ATLAS)

    total_area = ATLAS_SIZE ** 2
    print(f'\nPlaced:   {placed} / {len(sprites)}  +  {filler_count} fillers')
    if unplaced:
        print(f'Unplaced: {unplaced}')
    else:
        print('All sprites placed!')
    print(f'Fill:     {used_area / total_area * 100:.1f}%')
    print(f'\nOutput: {OUT_DIR}/combined_atlas*.png')

    # Per-type breakdown
    from collections import Counter
    counts = Counter(p['label'] for p in placements)
    for k, v in counts.items():
        sizes = [(p['w'], p['h']) for p in placements if p['label'] == k]
        print(f'  {k}: {v} sprites, sizes {min(sizes)}–{max(sizes)}')

    generate_lua(placements)


def generate_lua(placements: list[dict]):
    """Write heliara/decal/iron_carbon_slag.lua from placement data."""
    ATLAS_REF = "__heliara__/graphics/decal/slag/carbon_slag_combined_atlas.png"
    TILES = 32.0  # pixels per tile at scale=1

    groups = {
        'atlas1':       [p for p in placements if p['label'] == 'atlas1'],
        'atlas2_large': [p for p in placements if p['label'] == 'atlas2_large'],
        'small':        [p for p in placements if p['label'] in ('atlas2_small', 'filler')],
    }

    def bbox_str(sprites: list[dict]) -> str:
        # half-size of the largest sprite in each dimension, rounded up to 0.5 tile
        hw = max(p['w'] for p in sprites) / 2 / TILES
        hh = max(p['h'] for p in sprites) / 2 / TILES
        hw = math.ceil(hw * 2) / 2
        hh = math.ceil(hh * 2) / 2
        return f"{{{{-{hw}, -{hh}}}, {{{hw}, {hh}}}}}"

    def pictures_lua(sprites: list[dict], indent: int = 8) -> str:
        pad = ' ' * indent
        lines = []
        for p in sprites:
            # shift = 0 for both axes: sprite center == entity position == bbox center
            lines.append(
                f"{pad}{{ filename = ATLAS,"
                f" x = {p['x']:4d}, y = {p['y']:4d},"
                f" width = {p['w']:3d}, height = {p['h']:3d},"
                f" scale = 1, shift = {{0, 0}} }},"
            )
        return '\n'.join(lines)

    def decal_block(name: str, order: str, sprites: list[dict],
                    noise_expr: str) -> str:
        bb = bbox_str(sprites)
        pics = pictures_lua(sprites)
        return f"""\
    {{
        type = "optimized-decorative",
        name = "{name}",
        order = "d[{order}]",
        collision_box = {bb},
        collision_mask = {{layers = {{water_tile = true}}, colliding_with_tiles_only = true}},
        render_layer = "decals",
        tile_layer = 255,
        pictures = {{
{pics}
        }},
        autoplace = {{
            order = "d[{order}]",
            probability_expression = "{noise_expr}",
        }},
    }},"""

    blocks = '\n'.join([
        decal_block(
            'heliara_carbon_slag_scab',
            'heliara-carbon-slag-scab',
            groups['atlas1'],
            'heliara_carbon_slag_scab',
        ),
        decal_block(
            'heliara_carbon_slag_scab_medium',
            'heliara-carbon-slag-scab-medium',
            groups['atlas2_large'],
            'heliara_carbon_slag_scab',   # same interior expression
        ),
        decal_block(
            'heliara_carbon_slag_small_scab',
            'heliara-carbon-slag-small-scab',
            groups['small'],
            'heliara_carbon_slag_small_scab',
        ),
    ])

    lua = f"""\
-- Generated by scripts/pack_slag_atlas_combined.py — do not edit manually.

local ATLAS = "{ATLAS_REF}"

data:extend({{
{blocks}
}})
"""
    LUA_OUT.parent.mkdir(exist_ok=True)
    LUA_OUT.write_text(lua)
    print(f'Lua → {LUA_OUT}')
    for name, sprites in groups.items():
        print(f'  {name}: {len(sprites)} sprites, bbox {bbox_str(sprites)}')


if __name__ == '__main__':
    main()
