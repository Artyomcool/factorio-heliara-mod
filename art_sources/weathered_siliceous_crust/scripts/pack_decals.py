#!/usr/bin/env python3
"""
Pack decals_layout.json into a tight atlas using Guillotine rect packing.

Items are sorted by area descending; each item is placed in the smallest
free rectangle that fits (best-area-fit). When a rectangle is used, it is
split into two smaller free rectangles (longer-axis split heuristic).
The canvas grows downward as needed.

Output:
  heliara/graphics/terrain/heliara_weathered_siliceous_crust_decals.png
  art_sources/weathered_siliceous_crust/textures/decals_layout.json
"""

import json, pathlib
from PIL import Image
from collections import defaultdict

ROOT     = pathlib.Path(__file__).resolve().parents[3]
JSON_IN  = ROOT / 'art_sources/weathered_siliceous_crust/textures/decals_layout.json'
OUT_PNG  = ROOT / 'heliara/graphics/terrain/heliara_weathered_siliceous_crust_decals.png'
OUT_JSON = ROOT / 'art_sources/weathered_siliceous_crust/textures/decals_layout.json'

ATLAS_W  = 2048


# ── Guillotine packer ─────────────────────────────────────────────────────────

class Guillotine:
    """
    Best-area-fit Guillotine packer on a fixed-width, growing-height canvas.
    Free space starts as one tall rectangle; items are placed and the canvas
    height is extended if nothing fits.
    """

    GROW = 64   # height added each time canvas needs to grow

    def __init__(self, width):
        self.w    = width
        self.h    = 0
        self.free = []   # list of [x, y, w, h]

    def _grow(self):
        """Extend canvas down by GROW pixels, adding a new free strip."""
        self.free.append([0, self.h, self.w, self.GROW])
        self.h += self.GROW
        self._merge()

    def _merge(self):
        """Merge adjacent free rectangles that share a full horizontal edge."""
        changed = True
        while changed:
            changed = False
            for i in range(len(self.free)):
                for j in range(i + 1, len(self.free)):
                    a, b = self.free[i], self.free[j]
                    if a is None or b is None:
                        continue
                    # Same y, same height, horizontally adjacent
                    if a[1] == b[1] and a[3] == b[3]:
                        if a[0] + a[2] == b[0]:
                            self.free[i] = [a[0], a[1], a[2] + b[2], a[3]]
                            self.free[j] = None
                            changed = True
                        elif b[0] + b[2] == a[0]:
                            self.free[i] = [b[0], b[1], a[2] + b[2], b[3]]
                            self.free[j] = None
                            changed = True
            self.free = [r for r in self.free if r is not None]

    def insert(self, pw, ph):
        """Place item pw×ph; return (x, y). Grows canvas if needed."""
        while True:
            best_i    = None
            best_area = float('inf')
            for i, (rx, ry, rw, rh) in enumerate(self.free):
                if rw >= pw and rh >= ph:
                    area = rw * rh
                    if area < best_area:
                        best_area = area
                        best_i    = i
            if best_i is not None:
                break
            self._grow()

        rx, ry, rw, rh = self.free.pop(best_i)
        x, y = rx, ry

        # Split remaining space (longer-axis split)
        right_w  = rw - pw
        bottom_h = rh - ph
        if right_w >= bottom_h:       # wider remainder → keep full-height right strip
            if right_w > 0:
                self.free.append([rx + pw, ry, right_w, ph])
            if bottom_h > 0:
                self.free.append([rx, ry + ph, rw, bottom_h])
        else:                          # taller remainder → keep full-width bottom strip
            if bottom_h > 0:
                self.free.append([rx, ry + ph, pw, bottom_h])
            if right_w > 0:
                self.free.append([rx + pw, ry, right_w, rh])

        return x, y


# ── main ──────────────────────────────────────────────────────────────────────

def main():
    data   = json.loads(JSON_IN.read_text())
    sheet  = Image.open(data['sheet']).convert('RGBA')
    decals = data['decals']

    # Extract sprites
    sprites = []
    for d in decals:
        crop = sheet.crop((d['x'], d['y'], d['x'] + d['width'], d['y'] + d['height']))
        sprites.append({'img': crop, 'w_tiles': d['w_tiles'], 'h_tiles': d['h_tiles'],
                        'pw': d['width'], 'ph': d['height']})

    # Sort by area descending (largest first → best packing)
    sprites.sort(key=lambda s: -(s['pw'] * s['ph']))

    packer     = Guillotine(ATLAS_W)
    placements = []
    for s in sprites:
        x, y = packer.insert(s['pw'], s['ph'])
        placements.append((s, x, y))

    total_h = packer.h

    # Render
    atlas = Image.new('RGBA', (ATLAS_W, total_h), (0, 0, 0, 0))
    entries = []
    for s, x, y in placements:
        atlas.paste(s['img'], (x, y))
        entries.append({'w_tiles': s['w_tiles'], 'h_tiles': s['h_tiles'],
                        'x': x, 'y': y, 'width': s['pw'], 'height': s['ph']})

    atlas.save(OUT_PNG)
    OUT_JSON.write_text(json.dumps({'sheet': str(OUT_PNG), 'decals': entries}, indent=2))

    area_used  = sum(s['pw'] * s['ph'] for s, *_ in placements)
    area_total = ATLAS_W * total_h
    print(f"Atlas:      {ATLAS_W}×{total_h} px")
    print(f"Efficiency: {area_used:,} / {area_total:,} px²  ({100*area_used/area_total:.1f}%)")
    print(f"Decals:     {len(entries)}")
    print(f"Saved:      {OUT_PNG}")

    from collections import Counter
    for (w, h), n in sorted(Counter((e['w_tiles'], e['h_tiles']) for e in entries).items(),
                             key=lambda x: -(x[0][0]*x[0][1])):
        print(f"  {w}×{h} tiles  → {n} шт")


if __name__ == '__main__':
    main()
