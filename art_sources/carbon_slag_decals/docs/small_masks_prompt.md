# Carbon Slag Small Decal Masks

## Intention

Create a reusable grayscale alpha-mask atlas for small carbon-slag terrain decals.
The masks are intended to add fine detail around slag patch borders and sparse
secondary detail between larger slag scab decals.

The asset should support many small, irregular, natural-looking decal shapes:
chipped carbon scabs, soot islands, mineral flakes, eroded stains, cracked
residue, torn fragments, and ash clusters.

## Generation Prompt

Use case: stylized-concept

Asset type: grayscale decal mask atlas for a Factorio terrain mod

Primary request: Create one 2048x2048 image containing an 8x8 grid of 64 unique
small decal alpha masks, one mask per square cell. Each cell should contain a
smaller irregular natural shape, suitable for tiny scattered terrain details on
dark carbon slag: chipped scabs, soot islands, mineral flakes, eroded stains,
cracked residue, torn fragments, ash clusters.

Composition: exact 8 by 8 grid, every cell equal size, each mask centered with
generous padding. The background of the whole image must be pure black. Mask
shapes must be grayscale only, mostly white to light gray inside with rough
feathered/dithered edges, no color.

Style: high quality procedural-looking organic masks, sharp enough for game
decals, varied silhouettes and sizes, no repeated obvious shapes, no text, no
numbers, no labels, no borders between cells, no drop shadows.

Important constraints: grayscale mask atlas only; black means transparent
background, white means opaque decal. Keep the shapes smaller than the cell,
approximately 35% to 70% of each cell width, so they are clearly smaller
details than the current large masks.

## Implementation Notes

The generator returned a 1254x1254 image. The original generator output is kept
in `../masks`. Derived 2048x2048 grayscale working copies belong in `tmp`, not
in this source directory.

The intended small-decal pipeline is:

1. Slice the 8x8 mask atlas into 64 mask cells.
2. Trim each cell by non-black alpha content, preserving a small transparent
   safety padding.
3. Crop RGB content from random regions of the carbon slag material texture.
4. Apply each mask as alpha to the cropped RGB region.
5. Pack the resulting variable-size decal sprites into a shared 2048x2048 atlas.
6. Store per-sprite `x`, `y`, `width`, `height`, and `shift` in the Factorio
   decorative prototype.

Large decals should use a stricter interior-only slag noise expression. Small
decals should use a separate expression that is strongest near slag borders,
with a weaker fallback probability inside slag patches.

## Large Mask Pipeline Reminder

The large slag masks are stored in `iron_carbon_slag_16_masks_grid_v1.png`.
That source is a generated 4x4 mask grid.

Atlas 1 should be built from those masks as follows:

1. Normalize the generated 4x4 source to a 4x4 grid of 256x256 cells.
2. Slice each cell.
3. Compute trim bounds using an 8% grayscale threshold, so almost-transparent
   edge pixels do not make every mask look like a full square.
4. Crop the original grayscale mask by those bounds with small safety padding.
5. Fit the cropped mask into a 512x512 square while preserving aspect ratio.
6. Crop RGB material from random regions of the carbon slag texture.
7. Apply the fitted mask as alpha.
8. Pack the 16 resulting 512x512 decals into `carbon_slag_scab_atlas_1.png`
   using the regular 4x4 grid.

Atlas 2 should also use the same 4x4 source masks, but differently:

1. Slice and threshold-trim the masks using the same 8% rule.
2. Keep the masks at their natural trimmed size instead of fitting them to
   512x512.
3. Rotate each mask by a random angle.
4. Crop RGB material from random regions of the carbon slag texture.
5. Apply the rotated natural-size mask as alpha.
6. Pack these rotated large decals together with the 8x8 small decals into
   `carbon_slag_scab_atlas_2.png`.
