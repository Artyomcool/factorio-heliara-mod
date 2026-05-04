#!/usr/bin/env bash
# Heliara mod test runner
#
# Required env vars:
#   FACTORIO_BIN      Path to the Factorio executable
#
# Optional env vars:
#   FACTORIO_MOD_DIR  Directory that contains PlanetsLib (default: ~/.factorio/mods)
#
# Usage:
#   FACTORIO_BIN=/opt/factorio/bin/x64/factorio ./scripts/test-factorio.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

: "${FACTORIO_BIN:?Please set FACTORIO_BIN to the Factorio executable path}"
FACTORIO_MOD_DIR="${FACTORIO_MOD_DIR:-$HOME/.factorio/mods}"

# Derive installation root: bin/x64/factorio → ../../..
FACTORIO_INSTALL_DIR="$(cd "$(dirname "$FACTORIO_BIN")/../.." && pwd)"

# ─── Helpers ─────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[test]${NC} $*"; }
pass()  { echo -e "${GREEN}[PASS]${NC} $*"; }
error() { echo -e "${RED}[FAIL]${NC} $*" >&2; FAILED=1; }

FAILED=0

cleanup() {
    if [[ "$FAILED" -ne 0 ]]; then
        echo ""
        echo -e "${RED}Tests failed.${NC} Logs kept in: $WORK_DIR"
    else
        rm -rf "$WORK_DIR"
    fi
}

WORK_DIR="$(mktemp -d)"
trap cleanup EXIT

# ─── Test environment setup ───────────────────────────────────────────────────

MODS_DIR="$WORK_DIR/mods"
mkdir -p "$MODS_DIR"

info "Setting up test environment in $WORK_DIR"

# Our mod (src/ IS the mod directory, named heliara_<version>)
MOD_VERSION="$(python3 -c "import json; print(json.load(open('$ROOT_DIR/src/info.json'))['version'])")"
ln -s "$ROOT_DIR/src" "$MODS_DIR/heliara_${MOD_VERSION}"

# Test mod
ln -s "$ROOT_DIR/test/mods/heliara-test" "$MODS_DIR/heliara-test_0.0.1"

# PlanetsLib — find the latest version in FACTORIO_MOD_DIR
link_mod() {
    local name="$1"
    local found
    found=$(find "$FACTORIO_MOD_DIR" -maxdepth 1 \
        \( -name "${name}_*.zip" -o \( -name "${name}_*" -type d \) \) \
        2>/dev/null | sort -V | tail -1)
    if [[ -z "$found" ]]; then
        echo -e "${RED}ERROR:${NC} Dependency '$name' not found in $FACTORIO_MOD_DIR" >&2
        echo "  Install it via the Factorio mod portal or set FACTORIO_MOD_DIR." >&2
        exit 1
    fi
    ln -s "$found" "$MODS_DIR/$(basename "$found")"
    info "  Linked: $(basename "$found")"
}

link_mod "PlanetsLib"

# Factorio 2.0 uses -c <config> for isolation; no --headless or --user-data-path
CONFIG_FILE="$WORK_DIR/config.ini"
cat > "$CONFIG_FILE" << EOF
[path]
read-data=$FACTORIO_INSTALL_DIR/data
write-data=$WORK_DIR
EOF

# mod-list.json — space-age is a built-in DLC, still needs to be listed
cat > "$MODS_DIR/mod-list.json" << 'EOF'
{
  "mods": [
    {"name": "base",         "enabled": true},
    {"name": "space-age",    "enabled": true},
    {"name": "PlanetsLib",   "enabled": true},
    {"name": "heliara",      "enabled": true},
    {"name": "heliara-test", "enabled": true}
  ]
}
EOF

# Common Factorio args
FACTORIO=(
    "$FACTORIO_BIN"
    "--config"          "$CONFIG_FILE"
    "--mod-directory"   "$MODS_DIR"
    "--no-log-rotation"
)

LOG="$WORK_DIR/factorio-current.log"

# Check Factorio log for error-level lines
check_log_for_errors() {
    local label="$1"
    local log="$2"
    if grep -qE "^\s*Error\b|failed to load|Script .* error" "$log" 2>/dev/null; then
        error "$label: errors found in Factorio log:"
        grep -E "^\s*Error\b|failed to load|Script .* error" "$log" | head -30 >&2
        return 1
    fi
    return 0
}

# ─── Step 1: on_init tests (--create) ────────────────────────────────────────

info ""
info "Step 1 — Runtime tests via --create (on_init phase)"

SAVE="$WORK_DIR/saves/heliara-test.zip"
mkdir -p "$WORK_DIR/saves"

> "$LOG" 2>/dev/null || true

if ! "${FACTORIO[@]}" --create "$SAVE" 2>&1 | tee "$WORK_DIR/create.stdout"; then
    error "--create exited non-zero"
fi

cp "$LOG" "$WORK_DIR/create.log" 2>/dev/null || true

check_log_for_errors "create phase" "$WORK_DIR/create.log" || true

if grep -q "\[TEST_FAIL\]" "$WORK_DIR/create.log" 2>/dev/null; then
    error "on_init tests FAILED:"
    grep "\[TEST\]" "$WORK_DIR/create.log" | sed 's/^/  /' >&2
elif grep -q "\[TEST_PASS\]" "$WORK_DIR/create.log" 2>/dev/null; then
    grep "\[TEST_PASS\]" "$WORK_DIR/create.log" | while read -r line; do pass "$line"; done
else
    error "No [TEST_PASS/FAIL] markers in create.log — did heliara-test on_init run?"
    info "  Last 20 lines of create.log:"
    tail -20 "$WORK_DIR/create.log" | sed 's/^/  /' >&2
fi

# ─── Step 2: on_tick tests (--benchmark) ─────────────────────────────────────

info ""
info "Step 2 — Runtime tests via --benchmark (on_tick phase, 60 ticks)"

> "$LOG" 2>/dev/null || true

if ! "${FACTORIO[@]}" --benchmark "$SAVE" --benchmark-ticks 60 2>&1 \
        | tee "$WORK_DIR/bench.stdout"; then
    error "--benchmark exited non-zero"
fi

cp "$LOG" "$WORK_DIR/bench.log" 2>/dev/null || true

check_log_for_errors "benchmark phase" "$WORK_DIR/bench.log" || true

if grep -q "\[TEST_FAIL\]" "$WORK_DIR/bench.log" 2>/dev/null; then
    error "on_tick tests FAILED:"
    grep "\[TEST\]" "$WORK_DIR/bench.log" | sed 's/^/  /' >&2
elif grep -q "\[TEST_PASS\]" "$WORK_DIR/bench.log" 2>/dev/null; then
    grep "\[TEST_PASS\]" "$WORK_DIR/bench.log" | while read -r line; do pass "$line"; done
else
    info "  (no on_tick test output — tick tests may not have reached tick 5)"
fi

# ─── Summary ─────────────────────────────────────────────────────────────────

echo ""
if [[ "$FAILED" -eq 0 ]]; then
    echo -e "${GREEN}✓ All tests passed${NC}"
    exit 0
else
    echo -e "${RED}✗ Tests failed${NC}"
    exit 1
fi
