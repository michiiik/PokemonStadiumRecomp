#!/usr/bin/env bash
# PokemonStadiumRecomp setup — Linux / macOS / Git-Bash
#
# What this does:
#   1. Clones N64Recomp into n64recomp/ at the SHA pinned in
#      n64recomp.pin (or junctions to a sister checkout if present).
#   2. Initializes the disasm submodule (pret/pokestadium).
#   3. Stages the verified baserom.z64 into disasm/baseroms/us/.
#   4. (Optional) Clones Ares emulator for oracle integration.
#
# Prereqs: git, python3, cmake, a working C/C++ toolchain.

set -euo pipefail

ARES_REPO="https://github.com/ares-emulator/ares.git"

# ---- Framework and disassembly submodules ----
git submodule update --init --recursive engine/N64Recomp disasm

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
    if [ ! -d "ares-emulator/.git" ]; then
        echo "Cloning Ares (this is a large repo)..."
        git clone "$ARES_REPO" ares-emulator
    fi
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
