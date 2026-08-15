#!/usr/bin/env bash
# PokemonStadiumRecomp setup — Linux / macOS / Git-Bash
#
# What this does:
#   1. Initializes the framework and disasm submodules needed by the build.
#   2. Recreates the local lib/ dependency symlinks CMake expects.
#   3. Stages the verified baserom.z64 into disasm/baseroms/us/.
#   4. (Optional) initializes the Ares oracle dependency if WITH_ARES=1.
#
# Prereqs: git, python3, cmake, a working C/C++ toolchain.

set -euo pipefail

ensure_link() {
    local name="$1"
    shift
    local link="lib/$name"

    [ -e "$link" ] && return 0

    local candidate
    for candidate in "$@"; do
        if [ -e "$candidate" ]; then
            echo "Linking $link -> $candidate"
            ln -s "$candidate" "$link"
            return 0
        fi
    done

    echo "Error: missing dependency for $link." >&2
    echo "  Expected one of: $*" >&2
    return 1
}

write_freetype_module() {
    cat > lib/FindFreetype.cmake <<'EOF'
set(FREETYPE_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/lib/freetype-windows-binaries/include)
set(FREETYPE_LIBRARIES "${CMAKE_SOURCE_DIR}/lib/freetype-windows-binaries/release static/vs2015-2022/win64/freetype.lib")
add_library(Freetype::Freetype STATIC IMPORTED)
set_target_properties(Freetype::Freetype PROPERTIES
    IMPORTED_LOCATION ${FREETYPE_LIBRARIES}
)
target_include_directories(Freetype::Freetype INTERFACE
    ${FREETYPE_INCLUDE_DIRS}
)
EOF
}

mkdir -p lib
ensure_link N64ModernRuntime ../N64ModernRuntime-cosim ../N64ModernRuntime
ensure_link rt64 ../rt64
ensure_link RmlUi ../RmlUi
ensure_link lunasvg ../lunasvg
ensure_link GamepadMotionHelpers ../GamepadMotionHelpers
ensure_link SlotMap ../SlotMap
ensure_link freetype-windows-binaries ../freetype-windows-binaries
ensure_link concurrentqueue lib/N64ModernRuntime/thirdparty/concurrentqueue
write_freetype_module

# ---- Framework and disassembly submodules ----
git submodule update --init engine/N64Recomp disasm
git -C engine/N64Recomp submodule update --init --recursive \
    lib/rabbitizer lib/ELFIO lib/fmt lib/tomlplusplus lib/sljit

# ---- Disasm submodule ----
git submodule update --init --recursive disasm

# ---- Stage ROM into disasm ----
if [ -f "baserom.z64" ] && [ ! -f "disasm/baseroms/us/baserom.z64" ]; then
    mkdir -p disasm/baseroms/us
    cp baserom.z64 disasm/baseroms/us/baserom.z64
    echo "Staged baserom.z64 -> disasm/baseroms/us/"
fi

# Verify against pret's expected hash
EXPECTED_MD5="ed1378bc12115f71209a77844965ba50"
if [ -f "disasm/baseroms/us/baserom.z64" ]; then
    ACTUAL_MD5=$(md5sum "disasm/baseroms/us/baserom.z64" | awk '{print $1}')
    if [ "$ACTUAL_MD5" != "$EXPECTED_MD5" ]; then
        echo "WARNING: baserom MD5 mismatch."
        echo "  expected: $EXPECTED_MD5  (US v1.0)"
        echo "  actual:   $ACTUAL_MD5"
        echo "  This is likely a different revision (Rev A = v1.1 will not work)."
    else
        echo "baserom MD5 OK ($EXPECTED_MD5)"
    fi
fi

# ---- Ares oracle (optional, opt-in) ----
if [ "${WITH_ARES:-0}" = "1" ]; then
    git -C engine/N64Recomp submodule update --init --recursive \
        ares-bridge/third_party/ares
fi

echo
echo "Setup complete."
echo "  N64Recomp/   $(git -C engine/N64Recomp rev-parse --short HEAD 2>/dev/null || echo '?')"
echo "  disasm/      $(git -C disasm rev-parse --short HEAD 2>/dev/null || echo '?')"
echo
echo "Next:"
echo "  1. cd disasm && make init && make"
echo "  2. (back at root) configure CMake: cmake -S . -B build"
echo "  3. See ghidra/instructions.txt for analysis setup."
