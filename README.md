## ⚠️ Project Status: No Longer Maintained

**As of August 2026, this project is no longer maintained.** The repository
stays up, existing releases stay available, and the source remains public — but there will be no further bugfixes or releases.

### Why

This project is built on **N64Recomp, a toolchain I forked but did not
create**. After months of working inside it, my conclusion is that its
architecture is structurally unsound — the problems are foundational, not
fixable from a fork — and **I can't stand behind work built on it**, in this
project or any future one.

My other recompilation ecosystems
([NESRecomp](https://github.com/mstan/nesrecomp),
[SNESRecomp](https://github.com/mstan/snesrecomp),
[PSXRecomp](https://github.com/mstan/psxrecomp),
[NDSRecomp](https://github.com/mstan/ndsrecomp)) are toolchains I created
from the ground up, built with my standards and vision in mind. That's where
my time is going: maintaining the ecosystems I've committed to and continuing
to improve them, rather than propping up a foundation I believe
unmaintainable.

### What this means for you

- **The game still works.** The latest release (v0.4.6-beta) remains
  downloadable and playable as-is.
- **Known issues will not be fixed.** [`ISSUES.md`](ISSUES.md) and the issue
  tracker describe the state the project was left in; new reports won't be
  acted on.
- **The source stays public and buildable** at the pinned commits, per the
  GPL. Forks are welcome.

### The future

I haven't lost interest in Pokémon Stadium — I've lost confidence in this
foundation. If a foundation for N64 recompilation exists someday that I
believe in and can stand behind, I may revisit this game and rebuild it
properly. Until then, this repository is a finished artifact, not an active
project.

---

# PokemonStadiumRecomp — SS Anne

Static recompilation of **Pokémon Stadium (US v1.0)** to native PC.
Built on top of [N64Recomp](https://github.com/michiiik/N64Recomp).

This project is **SS Anne**, a Pokémon Stadium recompilation: it turns the
original game into a native PC program instead of running it in an
emulator. It is built on the N64Recomp toolchain and depends on a set of
companion forks maintained alongside it:

- [N64Recomp](https://github.com/michiiik/N64Recomp) — the static recompiler
- [N64ModernRuntime](https://github.com/michiiik/N64ModernRuntime) — the runtime that stands in for the N64's operating system
- [rt64](https://github.com/michiiik/rt64) — the graphics renderer

Each of those repositories lists, at the top of its own README, the
changes made to it for this project.

## Changes in this fork

What this project adds, in plain terms:

- **Makes Pokémon Stadium run as a native PC program** instead of inside
  an emulator. Most of the work is teaching the recompilation toolchain
  about this one specific game.
- **Transfer Pak support** — the game can read a Pokémon party from your
  own Game Boy cartridge, the way the real Transfer Pak accessory did, and
  save back to it. See [Transfer Pak](#transfer-pak).
- **GB Tower works** — the Game Boy emulator built into Stadium can play
  full Game Boy games. See [GB Tower](#gb-tower).
- **A setup screen before the game starts** — the SS Anne launcher, for
  choosing carts and controllers. See
  [The SS Anne launcher](#the-ss-anne-launcher).
- **Your progress is saved** — registered Pokémon are remembered between
  sessions, and sound plays through whatever output device your system is
  set to use.
- **The game looks sharper** — anti-aliasing is on by default (4× MSAA) to
  smooth the N64 models' hard polygon edges, and the renderer can
  **supersample** (render above the window resolution and filter down) to
  clean up the thin, far-away geometry that aliasing alone can't fix. The
  2D menus and HUD stay crisp at any internal resolution. See
  [Configuration](#configuration).
- **All the under-the-hood fixes** listed in the three companion projects
  above — graphics glitches, audio timing, and crashes/freezes. Each of
  those READMEs describes its own changes.

## Status

This is a work-in-progress recompilation. The list below reflects what
has actually been exercised, not everything the game contains. Known
issues are tracked in [`ISSUES.md`](ISSUES.md); expect occasional audio
crackle and some menu-level visual glitches.

**Tested and working:**

- Boot, the title / attract sequence, and the in-game **menus**.
- The **SS Anne launcher** (see below).
- The **Kid's Club mini-games**.
- **GB Tower** — the Game Boy player built into Stadium. Pokémon Red, Blue,
  and Yellow play from start to live gameplay, your cartridge's save is read
  and written back, and the Game Boy sound comes through your speakers.
  (The Game Boy games themselves run in an emulator — but that emulator is
  *built into Pokémon Stadium*, so it gets turned into native PC code right
  along with the rest of the game.)
- **Transfer Pak** — import your party from your own Game Boy Pokémon
  cartridge (Game Pak Check / Registration), and the Pokémon you register
  are remembered between sessions. Up to four players' controllers and
  cartridges, on ports 1–4.
- **Entering and exiting a battle** — a battle starts, plays, and returns
  to the menu.

**Not yet tested end-to-end:**

- A full Stadium **cup** has **not** been run from start to finish.
- **Gym Leader Castle** has **not** been run from start to finish.
- Individual battles work, but completing an entire cup or Gym Leader
  Castle run — multiple consecutive battles with the full
  win/loss/progression flow — has **not** been validated end-to-end.

**First launch:** the project opens the SS Anne launcher. If no ROM has
been remembered yet it pops a file picker; point it at your own legal
Pokémon Stadium (US v1.0) ROM (`.z64` / `.n64` / `.v64`). The path is
remembered (`rom.cfg` next to the exe) and CLI arg `argv[1]` is also
honored for scripted runs.

## The SS Anne launcher

On launch the project shows an in-app configuration screen — the **SS
Anne launcher** — before the game boots, replacing the original
straight-to-game boot.

![The SS Anne launcher](docs/launcher.png)

From the launcher you can:

- Assign a **Game Boy cart (Transfer Pak)** to each of the four player
  slots, with per-slot enable toggles. Cart art, trainer name, and ID are
  read from the configured ROM + save.
- Assign a **controller** to each slot (one device per slot), routed to
  that player's port when the game starts.
- Confirm the **Stadium (N64) ROM** (shown verified) and change it.
- Toggle **Auto-play**: a 5-second countdown that starts the game once the
  configuration is valid, so a controller-only user can opt into just
  waiting. It is **off by default**; the preference is persisted to
  `launcher.cfg` (`autoplay=on|off`) and can be overridden at launch with
  the `PSR_AUTOPLAY` environment variable (`PSR_AUTOPLAY=1` enables it,
  `PSR_AUTOPLAY=0` disables it).
- Press **PLAY** (enabled once at least one enabled slot has a controller).

`PSR_AUTOBOOT=1` skips the launcher entirely and boots straight into the
game (used for regression runs).

## Controls

Default bindings (per-button remapping in the launcher is planned).

**Game controller** (Xbox-style layout; DualSense / DualShock map the same way):

| N64 | Controller |
|-----|------------|
| A / B | A / B |
| Start | Start |
| **L** / **R** | **Left / Right bumper (LB / RB)** |
| **Z** | **Either trigger (LT / RT)** |
| D-Pad | D-Pad |
| Control Stick | Left stick |
| C-Buttons | Right stick (push up / down / left / right) |

(Earlier builds put N64 **L** on the left-stick *click*, where it was easy to
miss — issue #8. L and R are now the bumpers.)

**Keyboard:** `X`→A, `Z`→B, `Enter`→Start, `Q`→L, `E`→R, `Left-Shift`/`Space`→Z,
arrow keys→D-Pad, `W`/`A`/`S`/`D`→Control Stick, `I`/`K`/`J`/`L`→C-Up/Down/Left/Right.

## Configuration

- **RT64-backed rendering** with internal-resolution upscaling.
- **Smoother graphics, on by default.** The game runs with anti-aliasing
  (4× MSAA) so the models' edges aren't jagged. You don't have to set
  anything — it just looks better out of the box. The 2D menus stay sharp.
- **Optional: render at a higher resolution (supersampling).** If you have a
  capable GPU and want the far-away, thin parts of the models even cleaner,
  you can have the game draw at a higher resolution and shrink the result
  down. It's off by default; turn it on with these environment variables
  (see [`docs/graphics.md`](docs/graphics.md) for the full list and
  examples):
  - `PSR_RT64_RES_MULT` — how much higher than the window to render
    (e.g. `2` for double).
  - `PSR_RT64_DOWNSAMPLE` — how much to shrink it back down before showing
    it. Using both together is what gives the cleanest image.
  - `PSR_RT64_MSAA` — change the anti-aliasing level (`None`, `2X`, `4X`,
    `8X`) if the default doesn't suit your GPU.
- **Audio** plays through your system's default output device; override
  with `PSR_AUDIO_DEVICE=<name substring>`.
- **Fullscreen at launch.** By default the game opens in a window; press
  **Alt + Enter** to toggle fullscreen at any time. To have it *open*
  fullscreen every time, set `window_mode=fullscreen` in `launcher.cfg`
  (next to the exe), or launch with `PSR_FULLSCREEN=1` (equivalently
  `PSR_WINDOW_MODE=fullscreen`). The env vars override the file for that one
  run without changing it; `PSR_FULLSCREEN=0` / `PSR_WINDOW_MODE=windowed`
  force windowed. See [Configuration](#configuration) keys below.
- **Game-controller input** (including DualSense / DualShock).
- Configured via environment variables and `*.cfg` files placed next to
  the exe (`rom.cfg`, `launcher.cfg`).

## Troubleshooting

### Windows says the download is a virus / SmartScreen blocks it

Some antivirus products — and **Windows Smart App Control** in particular —
flag the release `.zip` or the `.exe` and may delete it automatically. **This
is a false positive.** Two things set heuristic scanners off:

- The executable is **statically recompiled** N64 code. The instruction
  patterns don't look like a normal compiler's output, which trips
  signature-free heuristics.
- The release binary is **not code-signed**. Code-signing requires a paid
  (EV) certificate; until the project has one, unsigned builds will keep
  drawing SmartScreen warnings regardless of what they contain.

To proceed:

1. Restore the file from quarantine, or add an exclusion for the folder you
   extracted it to (Windows Security → *Virus & threat protection* →
   *Manage settings* → *Exclusions*). With **Smart App Control** on, you may
   need to turn it off (it can't be exclusion-listed) — note that this is a
   one-way switch until a Windows reset.
2. If you'd rather not trust a prebuilt binary at all, **build it yourself
   from source** — the whole toolchain is in this repo and the companion
   forks. See [Build from source](#build-from-source). A build you compiled locally
   won't be flagged.

There is no malware in the release. The source is fully public; you're
welcome to inspect or rebuild it.

### No sound

Audio plays through your system's **default output device**. If you get no
sound at all:

1. **Make sure you're on the latest release.** Early builds shipped before
   the audio path was finished; current releases (v0.4.2-beta and later)
   have working sound. Grab the newest from the
   [Releases](https://github.com/mstan/PokemonStadiumRecomp/releases) page.
2. **Check which device is default** in Windows Sound settings — the game
   follows it. If your default is a device that's off or muted, you'll hear
   nothing.
3. **Force a specific device** with `PSR_AUDIO_DEVICE=<name substring>`
   (e.g. `PSR_AUDIO_DEVICE=Speakers`). The match is a case-sensitive
   substring of the device name; the first device that matches is used.

A subtle **audio crackle** during gameplay is a separate, known issue that's
being worked on — it's in the recompiled N64 sound synthesis, not your
device. `PSR_DISABLE_GBTOWER_AUDIO=1` silences only the GB Tower audio path
if you want to isolate it.

### It closes immediately / crashes on launch

The most common cause is a problem creating the Direct3D 12 graphics device
(a missing or broken D3D12 runtime, an old GPU/driver, or some virtualized /
remote-desktop setups). The renderer now **falls back to Vulkan automatically**
when the graphics API is left on its default (Auto), so most of these machines
start working without any change.

If it still won't start, force a backend explicitly:

- `PSR_GRAPHICS_API=vulkan` — use the Vulkan renderer (the usual fix for D3D12
  trouble). `PSR_GRAPHICS_API=d3d12` forces D3D12; `auto` is the default.
- Update your **GPU drivers** and make sure Windows is current — D3D12 needs a
  reasonably modern driver.

If you get an error box ("Unable to initialize…" / "Unable to find compatible
graphics device"), neither backend could start — that almost always means GPU
drivers need updating. A `last_error.log` is written next to the exe; attach it
to a bug report.

## ROM

| Field | Value |
|-------|-------|
| Title | Pokémon Stadium (US, v1.0) |
| MD5   | `ed1378bc12115f71209a77844965ba50` |
| Size  | 33,554,432 bytes (32 MB) |
| Format | `.z64` (big-endian native, magic `80 37 12 40`) |

**Rev A (v1.1) is not compatible** — pret's disassembly targets v1.0
specifically, and the address tables in `disasm/yamls/us/rom.yaml`
will not align with a Rev A binary. If you have Rev A, find a v1.0
dump.

## Layout

```
PokemonStadiumRecomp/
├── baserom.z64                     # canonical ROM (gitignored)
├── disasm/                         # michiiik/pokestadium submodule
├── n64recomp/                      # michiiik/N64Recomp submodule
├── lib/N64ModernRuntime/           # native runtime submodule
├── lib/rt64/                       # renderer submodule
├── recomp-ui/                      # launcher UI submodule
├── ghidra/                         # Ghidra project + instructions
├── generated/                      # recompiler C output (gitignored)
├── tools/                          # game-specific tooling
├── tests/                          # regression tests
├── docs/                           # design notes
├── game.toml                       # N64Recomp config
├── n64recomp.pin                   # engine SHA pin
├── CMakeLists.txt                  # build entrypoint
├── setup.sh / setup.bat            # legacy helpers; follow the guide below
├── DEBUG.md                        # divergence triage protocol
├── ISSUES.md / MODDING.md
└── README.md
```

## Build from source

The repository uses nested, pinned submodules. Do not use `--recursive` on the
initial clone: two optional Ares gitlinks currently point to commits that are
not available from the public Ares remote. The default build uses placeholder
mode and does not require Ares.

While those optional pins remain unavailable, the manual initialization steps
below are authoritative. The existing setup helpers are retained for reference
and should not be relied on for recursive initialization.

### Prerequisites

- All platforms: Git, Python 3, CMake, Ninja, and enough disk space for the
  nested dependencies and generated C.
- Windows: Visual Studio 2022 with C++ tools for `N64Recomp`, LLVM/Clang
  (`clang-cl`, `llvm-rc`) and Ninja for the native runner, plus WSL for the
  disassembly build.
- Linux: LLVM Clang, Make, SDL2 development files, `pkg-config`, Python 3, and
  MIPS binutils (normally commands prefixed `mips-linux-gnu-`).
- macOS: Xcode Command Line Tools (Apple Clang), CMake, Ninja, SDL2,
  `pkg-config`, Python 3, Make, and MIPS binutils. Set
  `MIPS_BINUTILS_PREFIX` if they use a different prefix.

There is currently no Android Gradle target in this Stadium 1 repository.

The Linux commands below are source-derived and have not been executed in the
current validation environment. Its WSL Ubuntu installation did not yet have
CMake, Ninja, `clang++`, `pkg-config`/SDL2 metadata, or MIPS binutils installed.

### 1. Clone and initialize dependencies

PowerShell:

```powershell
git clone https://github.com/michiiik/PokemonStadiumRecomp.git
Set-Location PokemonStadiumRecomp
git submodule update --init
git -C lib/N64ModernRuntime submodule update --init -- N64Recomp
git -C n64recomp config submodule.ares-bridge/third_party/ares.update none
git -C lib/N64ModernRuntime/N64Recomp config submodule.ares-bridge/third_party/ares.update none
git submodule update --init --recursive
```

Linux and macOS:

```bash
git clone https://github.com/michiiik/PokemonStadiumRecomp.git
cd PokemonStadiumRecomp
git submodule update --init
git -C lib/N64ModernRuntime submodule update --init -- N64Recomp
git -C n64recomp config submodule.ares-bridge/third_party/ares.update none
git -C lib/N64ModernRuntime/N64Recomp config submodule.ares-bridge/third_party/ares.update none
git submodule update --init --recursive
```

The two local `update none` settings skip only the unavailable optional Ares
pins. They do not modify tracked files. All dependencies required by the
default placeholder build are still initialized recursively.

### 2. Build the disassembly ELF

Place a legally obtained, exact Pokémon Stadium US v1.0 ROM at
`baserom.z64`, then copy it to the disassembly's ignored input location.
The expected identity is listed in [ROM](#rom).

On Windows, run this stage in WSL from the repository mounted under `/mnt`:

```bash
mkdir -p disasm/baseroms/us
cp baserom.z64 disasm/baseroms/us/baserom.z64
make -C disasm init
make -C disasm -j"$(nproc)"
test -f disasm/build/pokestadium-us.elf
```

Linux uses the same commands. On macOS, replace `$(nproc)` with
`$(sysctl -n hw.logicalcpu)`. The required output is
`disasm/build/pokestadium-us.elf`.

### 3. Build the N64Recomp CLI

From a Visual Studio 2022 Developer PowerShell:

```powershell
cmake -S n64recomp -B n64recomp/build-vs -G "Visual Studio 17 2022" -A x64
cmake --build n64recomp/build-vs --config Release --target N64RecompCLI
```

The Windows executable is
`n64recomp/build-vs/Release/N64Recomp.exe`.

Linux:

```bash
cmake -S n64recomp -B n64recomp/build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
cmake --build n64recomp/build --target N64RecompCLI
```

macOS:

```bash
cmake -S n64recomp -B n64recomp/build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER="$(xcrun --find clang)" \
  -DCMAKE_CXX_COMPILER="$(xcrun --find clang++)"
cmake --build n64recomp/build --target N64RecompCLI
```

The Linux/macOS executable is `n64recomp/build/N64Recomp`.

### 4. Generate the recompiled C sources

PowerShell:

```powershell
& .\n64recomp\build-vs\Release\N64Recomp.exe game.toml
if ($LASTEXITCODE -ne 0) { throw "N64Recomp generation failed" }
```

Linux and macOS:

```bash
./n64recomp/build/N64Recomp game.toml
```

This writes the ignored `generated/` directory. Generation is currently known
to exit nonzero because hook `func_81206D9C` is missing. If N64Recomp exits
nonzero, any files it left in `generated/` are incomplete and must not be
treated as valid build input.

### 5. Configure and build the native runner

Windows, from a shell where `clang-cl`, `llvm-rc`, Ninja, and the Visual Studio
linker environment are available:

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

### Current validation status (September 2026)

These are measured results, not a claim that the full source pipeline succeeds:

| Stage | Measured result |
|-------|-----------------|
| Nested dependencies, Windows | Top-level pins and every required non-Ares recursive module initialized successfully. |
| Nested dependencies, macOS | Fresh clones reproduced the same result; only the two deliberately skipped Ares paths remained uninitialized. |
| Linux | Commands are source-derived and unexecuted; the available WSL environment lacks the prerequisites listed above. |
| N64Recomp CLI, Windows | Built successfully with Visual Studio 2022. |
| Code generation | Exits nonzero because hook `func_81206D9C` is missing; partial `generated/` output is invalid. |
| Native configure, Windows | CMake/Ninja configure passed with clang-cl 22. |
| Native build, Windows clang-cl | Stops in pinned fmt consteval handling; no full build success is claimed. |
| Native build, Windows MSVC | Also rejects Clang-style warning flags in the Stadium 1 runner configuration. |
| Native configure, macOS | Passed with Apple Clang 21, CMake 4.4, Ninja, SDL2, and a generated snapshot. |
| Native build, macOS | Stops around target 83-87 in pinned `fmt/src/os.cc` consteval errors (first seen at lines 172, 218, and 287). No later blocker was reached. |

## Transfer Pak

Stadium reads your Pokémon party out of a Game Boy cart through the
N64 Transfer Pak accessory. This runtime ships a hardware-level
emulator of that accessory plus the Game Boy cart it bridges to, so
the in-game Game Pak Check menu sees the configured ROM/save as if
a real cart were plugged into a Transfer Pak in port 1.

**Supported games:** the Gen 1 and Gen 2 Pokémon Game Boy titles — Red,
Blue, Yellow, Gold, Silver, and Crystal. Your cartridge's save is written
back to disk as you play, so progress isn't lost.

**Configuration.** The SS Anne launcher normally writes `launcher.cfg`
for you (it is the launcher's persistent store — see
[The SS Anne launcher](#the-ss-anne-launcher)), but you can also hand-edit
or create it next to the exe:

```ini
# Paths are relative to this file (or absolute).
p1_rom=pokemon-yellow.gbc
p1_save=pokemon-yellow.sav
```

Keys are `pN_rom` / `pN_save` for ports 1–4. Environment variables
`PSR_TRANSFER_PAK_P{1..4}_ROM` and `..._SAVE` override the config
file. Set `PSR_TRANSFER_PAK_DEBUG=1` for verbose bus-level tracing
(off by default).

`launcher.cfg` and `*.gb` / `*.gbc` are gitignored — bring your
own legal dumps.

## Pipeline overview

```
disasm/  +  baserom.z64    -->  pret build      -->  pokestadium-us.elf
                                  (make init && make)         |
                                                              v
                          game.toml  +  N64RecompCLI  -->  generated/*.c
                                                              |
                                                              v
                                  CMake build  +  N64ModernRuntime
                                                              |
                                                              v
                                                  PokemonStadiumRecomp.exe
```

The disasm produces an ELF that already encodes every section's
load VA, symbols, and relocations. **N64Recomp consumes the ELF
directly** — there's no per-fragment slicing step. Ghidra also
imports the ELF directly (see `ghidra/instructions.txt`).

## Overlays — flat VA, not NES-style banks

Pokémon Stadium has a flat 8 MB virtual address space and uses
DMA-loaded *fragments* (overlays). Verified from
`disasm/yamls/us/rom.yaml`:

- 77 numbered fragments at **mostly unique VRAM addresses**
  (`0x81200000`, `0x87800000`, `0x87900000`, `0x8F000000`, …).
- Only **2 placeholder VRAM collisions** (`0x8FC00000` ×2,
  `0x88920000` ×2), commented in pret as "unk VRAM, shuts linker
  up" — likely not real runtime collisions.

This is **unlike NES bank-switching** (where every bank shares
`0x8000-0xFFFF`). For PokemonStadium the disasm's ELF is sufficient
for both N64Recomp and Ghidra; per-fragment extraction is not
needed and the project doesn't ship that tooling.

## GB Tower

Stadium's built-in **GB Tower** lets you play full Game Boy games on the
big screen, right inside Pokémon Stadium — different from the Transfer Pak,
which only imports a *party* (see above). It **works**: Pokémon Red, Blue,
and Yellow play to live gameplay, your cartridge save is read and written
back, and the Game Boy sound plays through your speakers.

A note for the curious: the Game Boy games genuinely run in an emulator,
the way they always did inside Pokémon Stadium. The difference here is that
the emulator — which is part of the Pokémon Stadium game itself — is
recompiled into native PC code along with everything else, rather than being
run by a separate emulator on top.

GB Tower reads carts through the same Transfer Pak cart model, so you
supply your own legal GB/GBC ROM + save the same way — via
`launcher.cfg` (`p1_rom` / `p1_save`) or the
`PSR_TRANSFER_PAK_P{1..4}_ROM` / `..._SAVE` environment variables. In the
game: **POKéMON STADIUM → right to the giant Game Boy (GB Tower) → pick a
cart → A**. The 1P slot is the default cart; additional ports map to the
2P/3P carts.

`PSR_DISABLE_GBTOWER_AUDIO=1` is available as a diagnostic opt-out for
the GB audio path.

## Out of scope (first pass)

Nothing major remains explicitly out of scope for the base game at this
point — GB Tower (above) was the last big "out of scope" item and is now
in. Remaining gaps are tracked as ordinary issues in
[`ISSUES.md`](ISSUES.md) rather than scope exclusions.

## Oracle (Ares)

Divergence checking against a reference emulator is currently done by
manual side-by-side runs against [ares](https://ares-emu.net/). An
automated bridge — running Ares in-process as an oracle and diffing N64
state against it — is a planned follow-up, not part of the current build.
The slot is reserved at `ares-emulator/` (opt-in via `WITH_ARES=1` in
setup); the bridge code (`ares_bridge.cpp`, `n64_snapshot.c`,
`verify_mode.c`, `watchdog.c`) is not yet written. Tracked in `ISSUES.md`.

## Documentation

- [`docs/graphics.md`](docs/graphics.md) — anti-aliasing + supersampling options.
- [`DEBUG.md`](DEBUG.md) — debug + divergence protocol.
- [`ISSUES.md`](ISSUES.md) — known issues + open work.
- [`MODDING.md`](MODDING.md) — modding hooks (post-MVP).
- [`ghidra/instructions.txt`](ghidra/instructions.txt) — Ghidra setup.

## Acknowledgements

- [pret/pokestadium](https://github.com/pret/pokestadium) — the Pokémon
  Stadium disassembly this project builds on.
- the [ares](https://ares-emu.net/) emulator team — accuracy reference.

## License

PokemonStadiumRecomp is distributed under the **GNU General Public
License, version 3** — see [`COPYING`](COPYING).

It is built from several components under their own licenses, whose terms
and copyright notices are retained in their respective repositories:

- N64ModernRuntime — GPL-3.0 (`COPYING`)
- N64Recomp — MIT (`LICENSE`)
- rt64 — MIT (`LICENSE`)

The original game's assets are **not** included; a legal copy of the
Pokémon Stadium (US v1.0) ROM is required to build or run this project.

---

<p align="center">
  <sub><b>R.A.I.D. — Retro AI Development</b> · a Discord for AI-assisted retro reverse-engineering, decomp &amp; recomp</sub>
</p>

<p align="center">
  <a href="https://discord.gg/Ad9BwSzctP"><img src=".github/raid-discord.png" alt="Join the Retro AI Development (R.A.I.D.) Discord" width="200"></a>
</p>
