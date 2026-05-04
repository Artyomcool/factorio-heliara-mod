# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**Heliara** is a Factorio 2.0 mod (requires Space Age DLC). It adds two new space locations:
- **Heliara** — a planet with no copper ore but a full carbon-based tech tree, culminating in Dyson Swarm and Dyson Reflectors
- **Heliashade** — a second location at distance 65, near-zero solar power, frozen daytime

Dependencies: `space-age >= 2.0.40`, `PlanetsLib >= 1.4.1`

## Development workflow

The mod is developed live in Factorio:
- Symlink or copy the `src/` directory into Factorio's `mods/` folder as `heliara_<version>/`
- In-game, run `/re` (custom command defined in `control.lua`) to reload all mods and reset the Heliara surface

### Automated tests

```bash
FACTORIO_BIN=/path/to/factorio ./scripts/test-factorio.sh
```

`FACTORIO_MOD_DIR` defaults to `~/.factorio/mods` — it must contain `PlanetsLib`. `space-age` is a built-in DLC and is found automatically from the Factorio installation.

The script runs three steps:
1. `--dump-data` → `test/validate-prototypes.py` checks all key prototypes, fuel system, and absence of copper in Heliara recipes
2. `--create` → `test/mods/heliara-test/control.lua` `on_init` runs prototype + placement tests
3. `--benchmark 60` → same mod's `on_tick` runs save/load persistence and storage cleanup tests

On failure, logs are preserved in the temp directory printed to stderr.

## Architecture

### Dual-phase Lua

Factorio mods run Lua in two separate phases with different global state:
- **Data phase** (`data.lua`, `data-updates.lua`): prototype registration; `data` global exists
- **Control phase** (`control.lua`): runtime scripting; `script`, `game`, `storage` globals exist

`src/entity/common.lua` bridges both phases. It provides:
- `wrap_for_data(for_data_fn)` — returns `for_data_fn()` during data phase, nil during control
- `wrap(func)` — returns `func` only during control phase, nil during data phase
- `req(module)` — requires a module only during control phase
- Stubs for data-phase globals (`hit_effects`, `item_sounds`, `sounds`, etc.) that return no-ops in control phase

Every entity file starts with `require("common")`.

### Entity declaration system

Entity files in `src/entity/` return a list of declaration tables. Each table may have:
```lua
{
    common = { name, icon, icon_size, ... },  -- shared metadata
    entity = { type, ..., on_build, on_destroy, on_tick, on_gui_opened, on_gui_destroy, bound_entities },
    item   = { stack_size, place_result, ... },
    recipe = { ingredients, energy_required, ... },
    resource = { mining_time, autoplace, ... },
    raw    = { ... },  -- arbitrary prototypes passed directly to data:extend()
}
```

`src/data.lua` iterates `src/entities.lua` (the registry) and calls `declare_recipe / declare_item / declare_entity / declare_resource` for each. `common` fields are inherited as fallbacks.

`src/control.lua` iterates the same registry to wire up event handlers. Entity event hooks (`on_build`, `on_destroy`, etc.) are read from the declaration and registered centrally — entities never call `script.on_event` themselves.

### bound_entities

An entity can declare `bound_entities` — a list of hidden child entity prototypes. The control infrastructure automatically spawns them at the same position on build and destroys them on removal. Their own `on_*` hooks are also registered. Used by `fullerene_solar_panel` to attach a hidden `burner-generator`.

### Storage

`src/script/storage.lua` exposes typed wrappers over Factorio's global `storage`:
- `entity_storage(entity)` — per-entity table, keyed by `unit_number`
- `surface_storage(surface)` — per-surface table, holds `reflectors_count`, `cached_solar_multiplier`
- `force_storage(force)` — per-force table, holds `swarm_size`
- `ticking()` — the set of entities with an `on_tick` handler

### Key game mechanics

**Dyson Reflectors** (`src/script/reflectors.lua`): Placeable only in zero-gravity/zero-pressure (orbit). Each reflector built on Heliara's surface increases `solar_power_multiplier` by `count^0.5 * 0.10`. At 100 reflectors night vanishes; at 500 it is always day.

**Dyson Swarm** (`src/script/dyson_swarm.lua`): Rocket silo on Heliara launches swarm elements. Each launch calls `increase_swarm(force, 1)`. The swarm increases solar power on all space platforms: `1 + count^0.25 * 0.10`.

**Solar Refractor** is the intermediate step — a satellite-style launcher on Heliara.

### Technology tree (progression)

Mine shungite → Fullerene Extraction Bath → Fullerene/Graphite/Carbon → Fullerene Science Pack → Graphite Circuit → graphite variants of all vanilla science packs → Steam Cargo (escape vehicle) → cargo drops navigation → Dyson Swarm / advanced techs.

### Assets

- `src/graphics/` — production PNGs loaded by the game
- `xcf/` — source art files (Krita `.kra`, GIMP `.xcf`), not loaded by Factorio
- `src/sound/` — ambient tracks (`1.ogg`–`9.ogg`) for Heliara

### Known placeholders / fixmes

Several items still use placeholder icons (`default.png`, vanilla icons). References in code are marked `-- fixme`. `big_space_platform_hub.lua` currently references `tmp.png` in production — needs final art.
