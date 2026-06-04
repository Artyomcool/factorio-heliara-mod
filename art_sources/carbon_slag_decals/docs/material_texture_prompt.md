# Carbon Slag Material Texture

## Intention

Create reusable source textures for carbon slag terrain decals. These textures
are used as RGB material sources behind separately generated alpha masks, so
decal shapes can be cut from different random regions without repeating the
same visible patch.

The target look is dark iron-carbon slag: nearly black, charcoal gray, muted
oxidized brown, and occasional subdued mineral highlights. Details should be
large enough to read in-game, not fine visual noise.

## Generation Prompt Summary

Generate a high-quality terrain material texture for dark iron-carbon slag.
Use large, interesting geological structures: fractured black slag plates,
charcoal crust, oxidized seams, vitrified mineral patches, soot stains, and
subtle rusty inclusions. Avoid tiny speckle noise, obvious tiling, text, labels,
objects, lighting direction, perspective, or scene composition. The result
should be a flat texture usable as a source for game decals.

## Implementation Notes

The source images in `../textures` are direct generator outputs kept for reuse:

- `carbon_slag_material_texture_generated.png`
- `carbon_slag_material_large_shapes_generated.png`
- `carbon_slag_material_from_reference_generated.png`

The source image in `../masks`:

- `carbon_slag_material_masks_generated.png`

Derived files, including 2048x2048 tiled versions, color-matched variants,
packed atlases, and individual decal crops, should stay in `tmp` or in the game
graphics directory if they are actively used by the mod.
