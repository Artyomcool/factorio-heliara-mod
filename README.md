# Heliara mod collection

Factorio 2.0 (Space Age) mod collection. Source for all three mods lives in this repository.

## Mods

### Heliara
A planet without copper, built around a carbon-based tech tree. Mine shungite, refine fullerene and graphite, research your way through a parallel science pack tree, and ultimately deploy Dyson Reflectors to control Heliara's solar output.

**Dependencies:** Space Age, PlanetsLib

### Heliashade
The far side of Heliara's orbital path — a cold, distant world with near-zero solar power. Home to the Big Space Platform Hub, Platform Replicator, and Dyson Reflectors.

**Dependencies:** Space Age, PlanetsLib, Heliara (optional)

### Packed Roboport
A personal roboport bundled with construction robots into a single armor slot for compact transport.

**Dependencies:** Space Age

## Development

Each mod directory (`heliara/`, `heliashade/`, `packed-roboport/`) symlinks to a shared `common/` directory for code shared between mods.

Symlink the mod directories into your Factorio mods folder:

```bash
ln -s /path/to/repo/heliara ~/.factorio/mods/heliara_0.0.1
ln -s /path/to/repo/heliashade ~/.factorio/mods/heliashade_0.0.1
ln -s /path/to/repo/packed-roboport ~/.factorio/mods/packed-roboport_0.1.0
```

To build release zips:

```bash
./scripts/release.sh                        # all mods
./scripts/release.sh heliara heliashade     # specific mods
```

Zips are written to the repo root.
