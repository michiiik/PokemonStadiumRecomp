# Pokémon Stadium Recompilation — SS Anne

This fork uses [mstan's PokemonStadiumRecomp](https://github.com/mstan/PokemonStadiumRecomp)
as its base. Many thanks to mstan for his great work.

This project statically recompiles Pokémon Stadium (US v1.0) into a native PC
application using pinned forks of N64Recomp, N64ModernRuntime, RT64, and the
launcher UI. It is a preserved work in progress: dependency setup and native
configuration have been validated, but code generation and full native builds
currently stop at the measured blockers listed below.

## ROM policy

You must provide your own legally obtained Pokémon Stadium ROM. ROMs, saves,
extracted game data, generated recompiler output, and local build products are
ignored and must never be committed.

| Field | Required value |
|-------|----------------|
| Release | Pokémon Stadium, US v1.0 (not Rev A) |
| MD5 | `ed1378bc12115f71209a77844965ba50` |
| Size | 33,554,432 bytes (32 MiB) |
| Format | Big-endian `.z64`, magic `80 37 12 40` |

Place the verified ROM at `baserom.z64` in the repository root. `game.toml`
reads it there, while the disassembly expects an ignored copy at
`disasm/baseroms/us/baserom.z64`.

## Repository layout

```text
PokemonStadiumRecomp/
├── disasm/                 # michiiik/pokestadium submodule
├── n64recomp/              # michiiik/N64Recomp submodule
├── lib/N64ModernRuntime/   # native runtime submodule
├── lib/rt64/               # renderer submodule
├── recomp-ui/              # launcher UI submodule
├── generated/              # ignored N64Recomp output
├── game.toml               # recompiler configuration
├── CMakeLists.txt          # native runner build
└── setup.sh / setup.bat    # legacy helpers; use the steps below
```

## Build from source

### Prerequisites

- Git, Python 3, CMake, Ninja, Make, and sufficient disk space.
- Windows: Visual Studio 2022 C++ tools, LLVM (`clang-cl` and `llvm-rc`), Ninja,
  and WSL for the disassembly build.
- Linux: LLVM Clang, SDL2 development files, `pkg-config`, and MIPS binutils.
- macOS: Xcode Command Line Tools, CMake, Ninja, SDL2, `pkg-config`, and MIPS
  binutils; set `MIPS_BINUTILS_PREFIX` when needed.

There is no Android Gradle target. Linux commands are source-derived and remain
unexecuted because the available WSL environment lacks their prerequisites.

### 1. Clone and initialize dependencies

Do not clone with `--recursive`. Two optional Ares gitlinks refer to commits
that are unavailable from the public Ares remote. The normal build uses the
placeholder implementation and does not require Ares.

The following commands work in PowerShell and Bash:

```bash
git clone https://github.com/michiiik/PokemonStadiumRecomp.git
cd PokemonStadiumRecomp
git submodule update --init
git -C lib/N64ModernRuntime submodule update --init -- N64Recomp
git -C n64recomp config submodule.ares-bridge/third_party/ares.update none
git -C lib/N64ModernRuntime/N64Recomp config submodule.ares-bridge/third_party/ares.update none
git submodule update --init --recursive
```

The local `update none` settings skip only the two unavailable optional Ares
pins. They do not change tracked files. Until those pins are restored publicly,
these manual commands are authoritative; the legacy setup helpers should not be
used for recursive initialization.

### 2. Build the disassembly ELF

On Windows, run this stage in WSL from the repository's mounted location.
Linux uses the same commands:

```bash
mkdir -p disasm/baseroms/us
cp baserom.z64 disasm/baseroms/us/baserom.z64
make -C disasm init
make -C disasm -j"$(nproc)"
test -f disasm/build/pokestadium-us.elf
```

On macOS, use `make -C disasm -j"$(sysctl -n hw.logicalcpu)"` for the parallel
build command. The required output is `disasm/build/pokestadium-us.elf`.

### 3. Build the N64Recomp CLI

From a Visual Studio 2022 Developer PowerShell:

```powershell
cmake -S n64recomp -B n64recomp/build-vs -G "Visual Studio 17 2022" -A x64
cmake --build n64recomp/build-vs --config Release --target N64RecompCLI
```

The Windows executable is `n64recomp/build-vs/Release/N64Recomp.exe`.

Linux:

```bash
cmake -S n64recomp -B n64recomp/build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
cmake --build n64recomp/build --target N64RecompCLI
```

macOS uses the same build directory and target with Apple Clang:

```bash
cmake -S n64recomp -B n64recomp/build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="$(xcrun --find clang)" \
  -DCMAKE_CXX_COMPILER="$(xcrun --find clang++)"
cmake --build n64recomp/build --target N64RecompCLI
```

The Linux/macOS executable is `n64recomp/build/N64Recomp`.

### 4. Generate the recompiled sources

PowerShell:

```powershell
& .\n64recomp\build-vs\Release\N64Recomp.exe game.toml
if ($LASTEXITCODE -ne 0) { throw "N64Recomp generation failed" }
```

Linux and macOS:

```bash
./n64recomp/build/N64Recomp game.toml
```

N64Recomp writes the ignored `generated/` directory. If it exits nonzero, any
files left there are incomplete and must not be used as valid build input.
Generation currently exits nonzero because hook `func_81206D9C` is missing.

### 5. Configure and build the native runner

Windows, from a shell with the Visual Studio linker environment, `clang-cl`,
`llvm-rc`, and Ninja:

```powershell
cmake -S . -B build-native -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_C_COMPILER=clang-cl `
  -DCMAKE_CXX_COMPILER=clang-cl `
  -DCMAKE_RC_COMPILER=llvm-rc
cmake --build build-native --target PokemonStadiumRecomp --parallel 2
```

The intended Windows executable is `build-native/PokemonStadiumRecomp.exe`.

Linux:

```bash
cmake -S . -B build-native -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
cmake --build build-native --target PokemonStadiumRecomp --parallel 2
```

macOS:

```bash
cmake -S . -B build-native -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="$(xcrun --find clang)" \
  -DCMAKE_CXX_COMPILER="$(xcrun --find clang++)"
cmake --build build-native --target PokemonStadiumRecomp --parallel 2
```

The intended Linux/macOS executable is `build-native/PokemonStadiumRecomp`.

## Current validation status (September 2026)

| Stage | Measured result |
|-------|-----------------|
| Dependencies, Windows | Exact top-level pins and all required non-Ares recursive modules initialized. |
| Dependencies, macOS | A fresh clone reproduced the Windows result; only the two skipped Ares paths remain uninitialized. |
| Linux | Commands are source-derived and unexecuted because the available WSL environment lacks prerequisites. |
| N64Recomp CLI, Windows | Built with Visual Studio 2022. |
| Code generation | Exits nonzero at missing hook `func_81206D9C`; partial output is invalid. |
| Native configure, Windows | Passed with CMake, Ninja, and clang-cl 22. |
| Native build, Windows clang-cl | Stops in pinned fmt consteval handling. |
| Native build, Windows MSVC | Rejects Clang-style warning flags in the runner configuration. |
| Native configure, macOS | Passed with Apple Clang 21, CMake 4.4, Ninja, SDL2, and a generated snapshot. |
| Native build, macOS | Stops around target 83-87 in pinned `fmt/src/os.cc` consteval errors, first seen at lines 172, 218, and 287. |

## License

Project code is distributed under GPL-3.0; see [`COPYING`](COPYING). Nested
third-party projects retain their own licenses, and additional notices are kept
under [`licenses/`](licenses/). Original game assets are not included.