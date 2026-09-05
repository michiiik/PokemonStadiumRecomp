#!/usr/bin/env bash
# Verify the shared Pokemon Stadium workspace layout.

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
WORKSPACE_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
DECOMP_DIR="$WORKSPACE_ROOT/decomp/pokestadium"
N64RECOMP_DIR="$WORKSPACE_ROOT/toolchain/N64Recomp"
RUNTIME_DIR="$WORKSPACE_ROOT/toolchain/N64ModernRuntime"
RT64_DIR="$WORKSPACE_ROOT/toolchain/rt64"
UI_DIR="$WORKSPACE_ROOT/toolchain/recomp-ui"
ARES_DIR="$WORKSPACE_ROOT/toolchain/ares"

require_repo() {
    if [ ! -e "$1/.git" ]; then
        echo "Error: required workspace repository is missing: $1" >&2
        echo "Run 'git submodule update --init --recursive' from $WORKSPACE_ROOT." >&2
        exit 1
    fi
}

for dependency in "$DECOMP_DIR" "$N64RECOMP_DIR" "$RUNTIME_DIR" "$RT64_DIR" "$UI_DIR"; do
    require_repo "$dependency"
done

SHA=$(sed -n 's/^[[:space:]]*sha[[:space:]]*=[[:space:]]*//p' "$SCRIPT_DIR/n64recomp.pin" | tr -d '[:space:]')
if [ -z "$SHA" ]; then
    echo "Error: no sha found in n64recomp.pin" >&2
    exit 1
fi

ACTUAL=$(git -C "$N64RECOMP_DIR" rev-parse HEAD)
if [ "$ACTUAL" != "$SHA" ]; then
    echo "Note: N64Recomp HEAD ($ACTUAL) differs from the game pin ($SHA)."
fi

ROM_PATH="$DECOMP_DIR/baseroms/us/baserom.z64"
EXPECTED_MD5="ed1378bc12115f71209a77844965ba50"
if [ -f "$ROM_PATH" ]; then
    if command -v md5sum >/dev/null 2>&1; then
        ACTUAL_MD5=$(md5sum "$ROM_PATH" | awk '{print $1}')
    else
        ACTUAL_MD5=$(md5 -q "$ROM_PATH")
    fi
    if [ "$ACTUAL_MD5" != "$EXPECTED_MD5" ]; then
        echo "Warning: Stadium 1 baserom MD5 is $ACTUAL_MD5; expected $EXPECTED_MD5." >&2
    else
        echo "Stadium 1 baserom MD5 OK."
    fi
else
    echo "Note: place your legal Stadium 1 US v1.0 ROM at $ROM_PATH"
fi

if [ "${WITH_ARES:-0}" = "1" ]; then
    require_repo "$ARES_DIR"
fi

echo
echo "Workspace dependencies are available."
echo "  pokestadium: $(git -C "$DECOMP_DIR" rev-parse --short HEAD)"
echo "  N64Recomp:   $(git -C "$N64RECOMP_DIR" rev-parse --short HEAD)"
echo
echo "Build the disassembly from: $DECOMP_DIR"
echo "Configure the game from the workspace root:"
echo "  cmake -S games/PokemonStadiumRecomp -B build/games/stadium1"
