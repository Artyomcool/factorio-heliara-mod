# Weathered Siliceous Crust Repaired Base Tile

## Intention

This source tile is the current approved 512x512 base for continuing weathered
siliceous crust variation work.

## Source

The tile was extracted from a 1024x1024 four-tile batch workflow:

- base: original weathered siliceous crust material downscaled to 512 and tiled 2x2;
- generator pass: batch02 raw image generated from four mask cells;
- composition: 50% generated detail blended over the tiled base inside the mask;
- seam handling: 8px stochastic dither along internal 512 seams;
- offset: cyclic shift by 40% width and 30% height;
- crop: top-left 512x512 after offset.

## Implementation Notes

Use `textures/weathered_siliceous_crust_repaired_base_tile_512_source.png` as the
new base tile for later generation batches instead of downscaling the original
1024 material texture again.
