# Art Source Asset Rules

This directory is for reusable art-generation source assets and documentation.
It is not a general scratch directory.

## What Belongs Here

Store only files that are useful as long-term sources for rebuilding game art:

- direct image-generator outputs that may be reused later;
- hand-approved source masks;
- hand-approved source textures;
- English prompt notes with intention and implementation details;
- debug previews that explain a specific visual/packing decision.

## What Does Not Belong Here

Do not store routine pipeline intermediates in `art_sources`:

- resized working copies;
- tiled 2048 versions;
- color-matched variants;
- temporary crops;
- individual generated decal pieces;
- packed atlas working files;
- montage/contact sheets unless they are explicitly useful debug evidence;
- failed experiments unless they explain an important decision.

Those files belong in `tmp`, or in the actual mod graphics directory if they are
the active in-game asset.

## Directory Pattern

Use this structure for each material or terrain family:

```text
art_sources/<asset_family>/
  textures/   direct generator texture outputs and approved source textures
  masks/      direct generator mask outputs and approved source masks
  docs/       prompt, intention, implementation notes
  debug/      selected previews, comparisons, packing diagnostics
```

Examples:

```text
art_sources/carbon_slag_decals/
art_sources/ferocalcite_crust/
```

## Naming

Use names that explain asset role and origin:

```text
<material>_<role>_generated.png
<material>_<role>_source.png
<material>_<role>_mask_grid_v1.png
<material>_<role>_debug_<purpose>.png
```

Prefer stable semantic names over random generator IDs. Keep the original
generator output image content unchanged when copying it here.

## Prompt Documentation

Every generated source group should have an English `.md` file in `docs/` with:

- `Intention`: why the asset exists and where it is meant to be used;
- `Generation Prompt`: the prompt or a faithful summary of it;
- `Implementation Notes`: how the source is consumed by the pipeline;
- important constants, for example trim thresholds, scale rules, or packing
  assumptions.

If a rule is discovered during iteration, write it down immediately. Example:
carbon slag decal masks are trimmed using an 8% grayscale threshold so
near-transparent pixels do not create square bounds.

## Debug Folder

`debug/` may contain derived images, but only when they are useful for later
reasoning. Good examples:

- trim-threshold previews;
- marked atlas packing previews;
- before/after comparisons for accepted decisions;
- contact sheets showing why a generated source was rejected or kept.

Debug files should be named by the question they answer, not by command history.

## Relationship To Other Directories

- `tmp/`: disposable working files, intermediate crops, generated Lua tables,
  repeated experiments, and scripts used during iteration.
- `heliara/graphics/`: active in-game assets consumed by the mod.
- `art_sources/`: reusable source inputs and decision records needed to rebuild
  or continue work in a future session.
