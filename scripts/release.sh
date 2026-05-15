#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${OUT_DIR:-$REPO_ROOT}"

usage() {
    echo "Usage: $0 [mod-dir...]"
    echo "  Packs each mod into a Factorio-compatible zip under release/."
    echo "  If no arguments given, packs all mods (heliara, heliashade, packed-roboport)."
    exit 1
}

pack_mod() {
    local mod_dir="$1"
    local mod_path="$REPO_ROOT/$mod_dir"

    if [[ ! -f "$mod_path/info.json" ]]; then
        echo "ERROR: $mod_path/info.json not found" >&2
        exit 1
    fi

    local name version
    name=$(python3 -c "import json; d=json.load(open('$mod_path/info.json')); print(d['name'])")
    version=$(python3 -c "import json; d=json.load(open('$mod_path/info.json')); print(d['version'])")
    local zip_name="${name}_${version}.zip"
    local pkg_name="${name}_${version}"

    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap "rm -rf '$tmp_dir'" EXIT

    # Copy with symlink resolution (-L follows symlinks)
    cp -rL "$mod_path" "$tmp_dir/$pkg_name"

    local out_zip="$OUT_DIR/$zip_name"
    rm -f "$out_zip"
    (cd "$tmp_dir" && zip -qr "$out_zip" "$pkg_name")

    echo "Packed: $out_zip"
    rm -rf "$tmp_dir"
    trap - EXIT
}

MODS=("$@")
if [[ ${#MODS[@]} -eq 0 ]]; then
    MODS=(heliara heliashade packed-roboport)
fi

for mod in "${MODS[@]}"; do
    pack_mod "$mod"
done
