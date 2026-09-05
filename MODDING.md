# Modding Pokemon Stadium Recompiled

Pokemon Stadium Recompiled supports N64Recomp code mods packaged as `.nrm`
files. This is the first modding milestone: package discovery, manifest and
compatibility validation, dependency handling, persistent enable state, and
entry/return hooks are provided by the pinned N64ModernRuntime.

The public API is intentionally small while the base game and its overlay
behavior stabilize. Species, rental, model, animation, and icon registration
APIs are future work. Mods must not add one-off hooks to `game.toml`.

## Installing a mod

1. Start the game once. It creates a `mods` directory beside the executable.
2. Copy the mod's `.nrm` file into that directory.
3. Restart the game. Code mods are loaded before the game starts and cannot be
   toggled safely while the game is running.

New mods are enabled by default. To return to unmodified behavior, close the
game and remove the `.nrm` file. The runtime stores the enabled list and load
order in `mods.json` beside the executable and per-mod settings under
`mod_config/`.

The startup log prints the absolute mods directory. Invalid archives, a wrong
`game_id`, an unmet `minimum_recomp_version`, missing dependencies,
conflicting patches, and unsupported code are reported as explicit mod-open or
mod-load errors rather than being silently ignored.

## Building the example

[`examples/hello_stadium_mod`](examples/hello_stadium_mod) is a standalone
template that can be moved to its own repository without changing its layout.
It installs one entry hook on `Util_InitMainPools`; the hook prints a single
message and does not replace the function or alter game state.

Prerequisites:

- CMake 3.20 or newer;
- LLVM/Clang with the MIPS target and `ld.lld` (LLVM 18.1.8 is the tested
  version; Apple Clang does not include the required target);
- a `RecompModTool` built from the N64Recomp revision used by this project.

Build the matching `RecompModTool` from the runtime's pinned N64Recomp without
recursively fetching the optional Ares checkout:

```sh
git submodule update --init lib/N64ModernRuntime
git -C lib/N64ModernRuntime submodule update --init N64Recomp
git -C lib/N64ModernRuntime/N64Recomp submodule update --init lib/ELFIO lib/fmt lib/rabbitizer lib/sljit lib/tomlplusplus
cmake -S tools/recomp_mod_tool -B build/mod-tool -DWITH_ARES_BRIDGE=OFF
cmake --build build/mod-tool --target RecompModTool --config Release
```

Then configure the example with explicit tool paths:

```sh
cmake -S examples/hello_stadium_mod -B examples/hello_stadium_mod/build \
  -DRECOMP_MOD_TOOL=/path/to/RecompModTool \
  -DPSR_MOD_CLANG=/path/to/clang \
  -DPSR_MOD_LLD=/path/to/ld.lld
cmake --build examples/hello_stadium_mod/build --target package
```

The result is `build/hello_stadium.nrm`. Verify its package metadata with:

```sh
python tools/verify_nrm.py examples/hello_stadium_mod/build/hello_stadium.nrm \
  --game-id pokestadium --mod-id hello_stadium
```

## Compatibility contract

- `game_id = "pokestadium"` targets this recomp family. Other game IDs are
  rejected during discovery.
- `minimum_recomp_version` is compared with the runner version before code is
  loaded. The first supported runner version is `0.1.0`.
- Mod IDs must be globally unique and stable across releases.
- Required and optional dependencies use `id:minimum-version` entries.
- Code mods are restart-only in this milestone. Removing or disabling a mod and
  restarting restores the base implementation.
- The reference symbol file is tied to Pokemon Stadium US v1.0. A future SDK
  release must version symbol changes and document compatibility.

## Repository and asset policy

The core repository owns the loader integration, generic hooks, and runtime
correctness fixes. Substantial mods should use independent repositories and
release cycles; a future catalog should contain metadata and checksums rather
than every mod's source.

Do not commit or publish ROMs, saves, or copyrighted extracted game assets.
Where a mod needs data from another game, derive it from a user-provided,
supported game image during the build or install process unless redistribution
rights are clear. Published packages should be reproducible and accompanied by
checksums.

## Current limitations

- There is no in-game mod-management screen yet.
- Code-mod enable/disable changes require a restart.
- Stadium-specific content registration APIs have not been stabilized.
- Overlay lifetime and multi-instance fixes must land in the core runtime before
  content mods such as the experimental Celebi integration rely on them.
