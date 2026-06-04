#!/usr/bin/env python3
"""
Pack Atlas 2 for carbon slag decals.

Atlas 2 contains:
  - 16 large masks (4x4 grid from iron_carbon_slag_16_masks_grid_v1.png)
    trimmed, randomly rotated, scaled to SCALE
  - 64 small masks (8x8 grid from carbon_slag_small_masks_8x8_generated_original.png)
    trimmed, scaled to SCALE

Each sprite gets RGB sampled from a random region of the carbon slag texture,
with the mask applied as alpha.

Output: debug/atlas2_pack_result.png   — final atlas
        debug/atlas2_pack_marked.png   — atlas with colored rects per sprite type
"""

import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

# ── config ──────────────────────────────────────────────────────────────────
ATLAS_SIZE   = 2048
SCALE        = 0.80
THRESHOLD    = int(255 * 0.08)   # 8% gray trim threshold
PADDING      = 4                  # gap between sprites in atlas
SEED         = 42

BASE        = Path(__file__).parent.parent / 'art_sources/carbon_slag_decals'
LARGE_MASKS = BASE / 'masks/iron_carbon_slag_16_masks_grid_v1.png'
SMALL_MASKS = BASE / 'masks/carbon_slag_small_masks_8x8_generated_original.png'
TEXTURE     = BASE / 'textures/carbon_slag_material_texture_generated.png'
OUT_DIR     = BASE / 'debug'

OUT_ATLAS   = OUT_DIR / 'atlas2_pack_result.png'
OUT_MARKED  = OUT_DIR / 'atlas2_pack_marked.png'

random.seed(SEED)
np.random.seed(SEED)


# ── helpers ──────────────────────────────────────────────────────────────────

def slice_grid(img_gray: np.ndarray, rows: int, cols: int) -> list[np.ndarray]:
    h, w = img_gray.shape
    cells = []
    for r in range(rows):
        for c in range(cols):
            y0 = int(round(r * h / rows))
            y1 = int(round((r + 1) * h / rows))
            x0 = int(round(c * w / cols))
            x1 = int(round((c + 1) * w / cols))
            cells.append(img_gray[y0:y1, x0:x1])
    return cells


def trim_mask(arr: np.ndarray, pad: int = 6) -> np.ndarray | None:
    """Trim to non-black content with safety padding. Returns None if empty."""
    mask = arr > THRESHOLD
    rows = np.any(mask, axis=1)
    cols = np.any(mask, axis=0)
    if not rows.any():
        return None
    r0, r1 = np.where(rows)[0][[0, -1]]
    c0, c1 = np.where(cols)[0][[0, -1]]
    r0 = max(0, r0 - pad)
    r1 = min(arr.shape[0] - 1, r1 + pad)
    c0 = max(0, c0 - pad)
    c1 = min(arr.shape[1] - 1, c1 + pad)
    return arr[r0:r1 + 1, c0:c1 + 1]


def sample_texture(tex: np.ndarray, w: int, h: int) -> np.ndarray:
    """Crop w×h pixels from a random position in tex, tiling if necessary."""
    th, tw = tex.shape[:2]
    rx = random.randint(0, tw - 1)
    ry = random.randint(0, th - 1)
    xs = (np.arange(w) + rx) % tw
    ys = (np.arange(h) + ry) % th
    return tex[np.ix_(ys, xs)]


def make_sprite(mask_arr: np.ndarray, tex: np.ndarray,
                scale: float, angle_deg: float = 0.0) -> Image.Image | None:
    """
    1. Rotate mask (if angle != 0).
    2. Scale to SCALE.
    3. Sample random texture region.
    4. Apply mask as alpha.
    Returns RGBA PIL image or None if degenerate.
    """
    pil_mask = Image.fromarray(mask_arr, mode='L')

    if angle_deg != 0.0:
        pil_mask = pil_mask.rotate(angle_deg, expand=True, resample=Image.BICUBIC)

    new_w = max(1, int(pil_mask.width  * scale))
    new_h = max(1, int(pil_mask.height * scale))
    pil_mask = pil_mask.resize((new_w, new_h), Image.LANCZOS)

    mask_final = np.array(pil_mask)
    if mask_final.max() == 0:
        return None

    rgb = sample_texture(tex, new_w, new_h)
    rgba = np.dstack([rgb, mask_final])
    return Image.fromarray(rgba.astype(np.uint8), 'RGBA')


# ── MaxRects bin packer ───────────────────────────────────────────────────────

class MaxRects:
    def __init__(self, width: int, height: int):
        self.W = width
        self.H = height
        self.free: list[tuple[int,int,int,int]] = [(0, 0, width, height)]

    def place(self, w: int, h: int) -> tuple[int,int] | None:
        """Best Short Side Fit heuristic. Returns (x, y) or None."""
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

        # Remove rects that are fully covered by another
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
    tex_img = np.array(Image.open(TEXTURE).convert('RGB'))

    # ── large masks (4×4, with random rotation) ──
    large_src = np.array(Image.open(LARGE_MASKS).convert('L'))
    large_cells = slice_grid(large_src, 4, 4)
    large_angles = [random.uniform(0, 360) for _ in large_cells]

    large_sprites: list[Image.Image] = []
    for i, (cell, angle) in enumerate(zip(large_cells, large_angles)):
        trimmed = trim_mask(cell)
        if trimmed is None:
            print(f'  large #{i}: empty after trim, skipping')
            continue
        sprite = make_sprite(trimmed, tex_img, SCALE, angle)
        if sprite is None:
            print(f'  large #{i}: degenerate after rotate/scale, skipping')
            continue
        large_sprites.append(sprite)
    print(f'Large sprites ready: {len(large_sprites)} / {len(large_cells)}')

    # ── small masks (8×8, no rotation) ──
    small_src = np.array(Image.open(SMALL_MASKS).convert('L'))
    small_cells = slice_grid(small_src, 8, 8)

    small_sprites: list[Image.Image] = []
    for i, cell in enumerate(small_cells):
        trimmed = trim_mask(cell)
        if trimmed is None:
            print(f'  small #{i}: empty after trim, skipping')
            continue
        sprite = make_sprite(trimmed, tex_img, SCALE)
        if sprite is None:
            print(f'  small #{i}: degenerate after scale, skipping')
            continue
        small_sprites.append(sprite)
    print(f'Small sprites ready: {len(small_sprites)} / {len(small_cells)}')

    all_sprites = large_sprites + small_sprites
    print(f'Total sprites to pack: {len(all_sprites)}')

    # Sort by height desc for better packing
    all_sprites.sort(key=lambda s: (-s.height, -s.width))
    types = ['large'] * len(large_sprites) + ['small'] * len(small_sprites)
    type_map: dict[int, str] = {}

    packer = MaxRects(ATLAS_SIZE, ATLAS_SIZE)
    atlas = Image.new('RGBA', (ATLAS_SIZE, ATLAS_SIZE), (0, 0, 0, 0))
    marked = Image.new('RGBA', (ATLAS_SIZE, ATLAS_SIZE), (20, 20, 20, 255))
    draw = ImageDraw.Draw(marked)

    placed_count = 0
    unplaced: list[int] = []

    # Build a list with original indices so we can track type after sort
    indexed = [(i, s) for i, s in enumerate(all_sprites)]
    indexed.sort(key=lambda t: (-t[1].height, -t[1].width))

    for orig_idx, sprite in indexed:
        sw, sh = sprite.size
        pos = packer.place(sw + PADDING, sh + PADDING)
        if pos is None:
            unplaced.append(orig_idx)
            continue
        x, y = pos
        atlas.paste(sprite, (x, y), sprite)
        marked.paste(sprite, (x, y), sprite)
        color = (255, 80, 80, 180) if orig_idx < len(large_sprites) else (80, 160, 255, 180)
        draw.rectangle([x, y, x + sw - 1, y + sh - 1], outline=color, width=2)
        placed_count += 1

    OUT_DIR.mkdir(exist_ok=True)
    atlas.save(OUT_ATLAS)
    marked.save(OUT_MARKED)

    print(f'\nPlaced: {placed_count} / {len(all_sprites)}')
    if unplaced:
        print(f'Unplaced ({len(unplaced)}): indices {unplaced}')
    else:
        print('All sprites placed successfully!')

    # Size stats
    sizes = [(s.width, s.height) for _, s in indexed]
    areas = [w * h for w, h in sizes]
    used_area = sum(w * h for w, h in [(indexed[i][1].width, indexed[i][1].height)
                                        for i, (orig, _) in enumerate(indexed)
                                        if orig not in unplaced])
    total_area = ATLAS_SIZE * ATLAS_SIZE
    print(f'Atlas fill: {used_area / total_area * 100:.1f}%')
    print(f'Sprite sizes — max: {max(sizes)}, min: {min(sizes)}')
    print(f'\nOutput:\n  {OUT_ATLAS}\n  {OUT_MARKED}')


if __name__ == '__main__':
    main()
