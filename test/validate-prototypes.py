#!/usr/bin/env python3
"""
Validate Heliara mod prototypes from a Factorio --dump-data output.

Usage:
    python3 test/validate-prototypes.py <path/to/data-raw-dump.json>
"""

from __future__ import annotations
import json
import sys
from pathlib import Path

# Known entity prototype types for entities we want to verify.
# "resource" entities (shungite, carbon_coal, etc.) are under the "resource" key.
ENTITY_TYPES: dict[str, str] = {
    "fullerene_solar_panel":     "solar-panel",
    "fullerene_extraction_bath": "assembling-machine",
    "heliara_assembling_machine":"assembling-machine",
    "dryer":                     "furnace",
    "osmosis_pipejack":          "mining-drill",
    "wireless_pole":             "electric-pole",
    "effective_wireless_pole":   "electric-pole",
    "fullerene_lab":             "lab",
    "solar_refractor_silo":      "rocket-silo",
    "dyson_reflector":           "simple-entity",
    "huge_fullerene_rock":       "simple-entity",
    "shungite":                  "resource",
    "carbon_coal":               "resource",
    "silcrete":                  "resource",
    "brackish_vent":             "resource",
}

COPPER: frozenset[str] = frozenset({
    "copper-ore", "copper-plate", "copper-cable", "copper",
})

# Heliara recipes that must contain zero copper ingredients.
NO_COPPER_RECIPES: list[str] = [
    "fullerene", "fullerene-from-shungite", "fullerene-from-graphite",
    "graphite", "graphite-from-shungite", "graphite-from-carbon",
    "carbon-from-shungite", "silicon_substrate", "advanced_silicon_substrate",
    "graphite_circuit", "fullerene_extraction_bath", "heliara_assembling_machine",
    "dryer", "osmosis_pipejack", "osmosis_filter", "wireless_pole",
    "effective_wireless_pole", "fullerene_solar_panel", "fullerene_lab",
    "fast_burner_inserter", "long_burner_inserter", "brick_dust",
    "shungite_from_brick_dust", "silcrete",
    "fullerene_rocket_fuel", "fullerene_solid_fuel",  # recipe names (produce vanilla items)
    "graphite-automation-science-pack", "graphite-logistic-science-pack",
    "graphite-chemical-science-pack", "graphite-production-science-pack",
]

# Heliara recipes that should NOT be craftable by hand (enabled = false).
GATED_RECIPES: list[str] = [
    "fullerene", "graphite", "silicon_substrate", "graphite_circuit",
    "fullerene_solar_panel", "fullerene_extraction_bath",
    "heliara_assembling_machine", "dryer", "osmosis_pipejack", "fullerene_lab",
    "wireless_pole", "fast_burner_inserter", "long_burner_inserter",
    "osmosis_filter",
]


class Validator:
    def __init__(self, data: dict):
        self.data = data
        self.failures: list[str] = []
        self.passes = 0

    # ── helpers ──────────────────────────────────────────────────────────────

    def _check(self, name: str, ok: bool, detail: str = "") -> bool:
        if ok:
            print(f"  \033[32mPASS\033[0m  {name}")
            self.passes += 1
        else:
            suffix = f"  [{detail}]" if detail else ""
            print(f"  \033[31mFAIL\033[0m  {name}{suffix}")
            self.failures.append(f"{name}{suffix}")
        return ok

    def _get(self, type_name: str, name: str) -> dict | None:
        return self.data.get(type_name, {}).get(name)

    def _find_entity(self, name: str) -> str | None:
        """Return the prototype type name for an entity, or None if not found."""
        known = ENTITY_TYPES.get(name)
        if known and self._get(known, name) is not None:
            return known
        # Fallback: search all types (slower, but handles unknowns)
        for type_name, bucket in self.data.items():
            if isinstance(bucket, dict) and name in bucket:
                return type_name
        return None

    # ── sections ─────────────────────────────────────────────────────────────

    def check_items(self):
        for name in [
            "fullerene", "shungite", "graphite", "graphite_circuit",
            "silicon_substrate", "brick_dust", "osmosis_filter",
            "fast_burner_inserter", "long_burner_inserter",
            "silcrete", "fullerene_solar_panel",
            "fullerene_extraction_bath", "heliara_assembling_machine",
            "dryer", "osmosis_pipejack", "wireless_pole",
        ]:
            self._check(f"item/{name}", self._get("item", name) is not None)
        # Science packs are type "tool" in Factorio 2.0
        self._check("tool/fullerene-science-pack",
                    self._get("tool", "fullerene-science-pack") is not None)

    def check_entities(self):
        for name in ENTITY_TYPES:
            found_type = self._find_entity(name)
            self._check(
                f"entity/{name}",
                found_type is not None,
                f"expected type={ENTITY_TYPES[name]}" if found_type is None else "",
            )

    def check_technologies(self):
        for name in [
            "planet-discovery-heliara",
            "fullerene_extraction_bath",
            "fullerene_solar_panel",
            "carbon-electrolitic-processing",
            "fullerene_lab",
            "silicon_substrate",
            "graphite_circuit",
            "heliara_assembling_machine",
            "steam_cargo",
            "osmosis_pipejack",
            "solar_refractor",
        ]:
            self._check(f"technology/{name}", self._get("technology", name) is not None)

    def check_recipes(self):
        for name in [
            "fullerene", "graphite", "silicon_substrate", "graphite_circuit",
            "carbon-from-shungite", "graphite-from-shungite", "fullerene-from-shungite",
            "fullerene_extraction_bath", "heliara_assembling_machine", "dryer",
            "osmosis_pipejack", "osmosis_filter", "fullerene_solar_panel",
            "fullerene_lab", "fast_burner_inserter", "long_burner_inserter",
            "graphite-automation-science-pack", "graphite-logistic-science-pack",
            "graphite-chemical-science-pack", "graphite-production-science-pack",
            "steam_cargo", "wireless_pole", "brick_dust",
        ]:
            self._check(f"recipe/{name}", self._get("recipe", name) is not None)

    def check_fuel_system(self):
        self._check("fuel-category/solar_fuel",
                    self._get("fuel-category", "solar_fuel") is not None)

        self._check("burner-usage/fullerene",
                    self._get("burner-usage", "fullerene") is not None)

        item = self._get("item", "fullerene")
        if item:
            got_cat = item.get("fuel_category")
            self._check("fullerene.fuel_category == solar_fuel",
                        got_cat == "solar_fuel",
                        f"got {got_cat!r}")

            fv = item.get("fuel_value", "0")
            # fuel_value is a string like "1MJ" in the data dump
            fv_positive = fv != "0" and fv != "" and fv is not None
            self._check("fullerene.fuel_value > 0", fv_positive, f"fuel_value={fv}")
        else:
            self._check("fullerene item (prereq for fuel checks)", False)

    def check_no_copper(self):
        for recipe_name in NO_COPPER_RECIPES:
            recipe = self._get("recipe", recipe_name)
            if recipe is None:
                continue  # absence already caught in check_recipes
            found = [
                i["name"]
                for i in recipe.get("ingredients", [])
                if i.get("name") in COPPER
            ]
            self._check(
                f"recipe/{recipe_name} — no copper",
                len(found) == 0,
                f"contains: {found}" if found else "",
            )

    def check_gated_recipes(self):
        for recipe_name in GATED_RECIPES:
            recipe = self._get("recipe", recipe_name)
            if recipe is None:
                continue
            enabled = recipe.get("enabled", True)
            self._check(
                f"recipe/{recipe_name} — enabled=false (tech-gated)",
                not enabled,
                f"enabled={enabled}",
            )

    # ── main ─────────────────────────────────────────────────────────────────

    def run(self) -> bool:
        sections = [
            ("Required items",           self.check_items),
            ("Required entities",        self.check_entities),
            ("Required technologies",    self.check_technologies),
            ("Required recipes",         self.check_recipes),
            ("Fuel system",              self.check_fuel_system),
            ("No copper in recipes",     self.check_no_copper),
            ("Recipes gated by tech",    self.check_gated_recipes),
        ]
        for title, fn in sections:
            bar = "─" * max(1, 46 - len(title))
            print(f"\n── {title} {bar}")
            fn()

        total = self.passes + len(self.failures)
        print(f"\n{'═' * 50}")
        if self.failures:
            print(f"\033[31m[VALIDATE_FAIL]\033[0m {len(self.failures)}/{total} checks failed:")
            for f in self.failures:
                print(f"  • {f}")
            return False

        print(f"\033[32m[VALIDATE_PASS]\033[0m All {self.passes} prototype checks passed")
        return True


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <data-raw-dump.json>")
        sys.exit(1)

    path = Path(sys.argv[1])
    if not path.exists():
        print(f"Error: {path} does not exist", file=sys.stderr)
        sys.exit(1)

    size_mb = path.stat().st_size // (1024 * 1024)
    print(f"Loading {path} ({size_mb} MB)…")
    with path.open(encoding="utf-8") as f:
        data = json.load(f)

    sys.exit(0 if Validator(data).run() else 1)


if __name__ == "__main__":
    main()
