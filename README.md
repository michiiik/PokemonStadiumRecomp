# Pokémon Stadium Recompilation — SS Anne

This fork uses [mstan's PokemonStadiumRecomp](https://github.com/mstan/PokemonStadiumRecomp)
as its base. Many thanks to mstan for his great work.

This project statically recompiles Pokémon Stadium (US v1.0) into a native
application using pinned public forks of N64Recomp, N64ModernRuntime, RT64,
the pokestadium disassembly, and the launcher UI.

## ROM policy

You must provide your own legally obtained Pokémon Stadium ROM. ROMs, saves,
ELFs, extracted data, generated sources, logs, and build products must not be
committed.

| Field | Required value |
|---|---|
| Release | Pokémon Stadium, US v1.0 (not Rev A) |
| MD5 | `ed1378bc12115f71209a77844965ba50` |
| Size | 33,554,432 bytes (32 MiB) |
| Format | Big-endian `.z64`, magic `80 37 12 40` |

Place the verified ROM at `baserom.z64` in the repository root and copy it
to the ignored disassembly input at `disasm/baseroms/us/baserom.z64`.

## Build from source

### Prerequisites

All desktop platforms need Git, Python 3, CMake, Ninja, Make, SDL2,
`pkg-config`, and MIPS binutils.

- Windows: Visual Studio 2022 C++ tools, LLVM (`clang-cl` and `llvm-rc`),
  and WSL for the disassembly stage.
- macOS: Xcode Command Line Tools and Homebrew packages for the common tools,
  SDL2, and MIPS binutils. Set `MIPS_BINUTILS_PREFIX` if the installed
  tools use a non-default prefix.
- Linux: Clang, SDL2 development files, `pkg-config`, and MIPS binutils
  (normally prefixed `mips-linux-gnu-`).

### 1. Clone and initialize dependencies

The committed `.gitmodules` uses public HTTPS URLs. Local sibling paths such
as `../../` are intentionally not part of repository metadata.

Do not start with `--recursive`: the optional Ares bridge currently pins a
commit unavailable from its public remote. The normal build does not need it.

```bash
git clone https://github.com/michiiik/PokemonStadiumRecomp.git
cd PokemonStadiumRecomp
git submodule update --init
git -C lib/N64ModernRuntime submodule update --init -- N64Recomp
git -C n64recomp config submodule.ares-bridge/third_party/ares.update none
git -C lib/N64ModernRuntime/N64Recomp config submodule.ares-bridge/third_party/ares.update none
git submodule update --init --recursive
```

Those two `update none` settings are local Git configuration; they do not
modify tracked files.

### 2. Build the disassembly

On Windows, run this stage in WSL. Linux uses the same commands:

```bash
mkdir -p disasm/baseroms/us
cp baserom.z64 disasm/baseroms/us/baserom.z64
make -C disasm RUN_CC_CHECK=0 init
test -f disasm/build/pokestadium-us.elf
```

On macOS, use GNU Make:

```bash
mkdir -p disasm/baseroms/us
cp baserom.z64 disasm/baseroms/us/baserom.z64
gmake -C disasm RUN_CC_CHECK=0 init
test -f disasm/build/pokestadium-us.elf
```

A successful build reconstructs
`disasm/build/pokestadium-us.z64` with the MD5 shown above and produces
`disasm/build/pokestadium-us.elf`.

### 3. Build N64RecompCLI

From a Visual Studio 2022 Developer PowerShell:

```powershell
cmake -S n64recomp -B build-n64recomp -G "Visual Studio 17 2022" -A x64 -DWITH_ARES_BRIDGE=OFF
cmake --build build-n64recomp --config Release --target N64RecompCLI
```

Linux:

```bash
cmake -S n64recomp -B build-n64recomp -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
  -DWITH_ARES_BRIDGE=OFF
cmake --build build-n64recomp --target N64RecompCLI
```

macOS:

```bash
cmake -S n64recomp -B build-n64recomp -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="$(xcrun --find clang)" \
  -DCMAKE_CXX_COMPILER="$(xcrun --find clang++)" \
  -DWITH_ARES_BRIDGE=OFF
cmake --build build-n64recomp --target N64RecompCLI
```

The executable is `build-n64recomp/N64Recomp` on Linux/macOS and is under
the selected Visual Studio configuration directory on Windows.

### 4. Generate the recompiled sources

PowerShell:

```powershell
& .\\build-n64recomp\\Release\\N64Recomp.exe game.toml
if ($LASTEXITCODE -ne 0) { throw "N64Recomp generation failed" }
```

Linux and macOS:

```bash
cmake -E chdir . ./build-n64recomp/N64Recomp game.toml
```

This creates the ignored `generated/` directory. Treat any output from a
nonzero generator exit as incomplete.

### 5. Build the native application

Windows, from a shell containing the Visual Studio linker environment:

```powershell
cmake -S . -B build-native -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_C_COMPILER=clang-cl `
  -DCMAKE_CXX_COMPILER=clang-cl `
  -DCMAKE_RC_COMPILER=llvm-rc `
  -DWITH_ARES_BRIDGE=OFF
cmake --build build-native --target PokemonStadiumRecomp --parallel 2
```

Linux:

```bash
cmake -S . -B build-native -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
  -DWITH_ARES_BRIDGE=OFF
cmake --build build-native --target PokemonStadiumRecomp --parallel 2
```

macOS:

```bash
cmake -S . -B build-native -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="$(xcrun --find clang)" \
  -DCMAKE_CXX_COMPILER="$(xcrun --find clang++)" \
  -DWITH_ARES_BRIDGE=OFF
cmake --build build-native --target PokemonStadiumRecomp --parallel 2
```

The result is `build-native/PokemonStadiumRecomp.exe` on Windows and
`build-native/PokemonStadiumRecomp` on Linux/macOS.

## Android

Android remains relevant, but this repository currently has no Android app,
Gradle project, or supported Android CMake target. The desktop build commands
above do not produce an APK. A public Android build still needs dedicated
application packaging and platform glue for the runtime, window/input, audio,
and graphics layers. No mobile-device validation is claimed here.

## Validation status (September 2026)

| Stage | Result |
|---|---|
| Public dependency metadata | Verified public HTTPS submodule URLs; no committed local sibling paths. |
| Disassembly, macOS | Fresh build passed and reconstructed the expected ROM MD5. |
| N64RecompCLI, macOS | Fresh AppleClang 21/Ninja build passed (58/58). |
| Code generation, macOS | Fresh generation passed with exit 0 and 1,006 files; no missing hook/function names. |
| Native build, macOS | Fresh build passed (1758/1758); output verified as an executable arm64 Mach-O. |
| Windows | Earlier CLI and native configuration checks passed; the final dependency stack has not been rebuilt end-to-end in this update. |
| Linux | Commands are source-derived and not yet executed in the available WSL environment. |
| Android | Not buildable from this repository yet; no device validation performed. |

The generator still prints inherited code-analysis diagnostics, including four
external-branch warnings for fragments 30, 51, 74, and 77 that match the
known-good checkout. Generation exits successfully; these are not missing-hook
failures.

## License

Project code is distributed under GPL-3.0; see [`COPYING`](COPYING).
Nested third-party projects retain their own licenses and notices under
[`licenses/`](licenses/). Original game assets are not included.
