# Ferocalcite Crust Large Detail Texture

## Intention

Create a high-quality ferocalcite crust detail texture that can be blended over
the existing Factorio tile carpet through hand-authored/procedural masks.

The texture is meant to provide larger, more natural mineral variation than the
base repeated 64x64 tile, while keeping the final average color close enough to
the in-game ferocalcite tile set.

## Generation Prompt Summary

Generate a 512x512 high-quality texture based on the ferocalcite reference:
cracked mineral crust, pale gray and muted rust-red calcite/iron staining,
large readable geological structures, not tiny noisy speckles. The texture
should be suitable as terrain material detail, with no objects, no labels, no
lighting direction, and no perspective scene.

## Implementation Notes

The generated texture is kept as the source asset. Later pipeline steps adjusted
mean color, contrast, masking, and seam visibility. Those processed results are
not stored here as source images; they live in `tmp` or in the game graphics
directory when applied.

Important mask assets used for the blend are stored in `../masks`:

- `ferocalcite_mask_blackrange_dark_core.png`
- `ferocalcite_mask_sparse_black_fill_01.png` through `10.png`
- `ferocalcite_mask_sparse_black_fill_selected_07.png`
