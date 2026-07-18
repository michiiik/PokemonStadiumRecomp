@echo off
:: PokemonStadiumRecomp setup - Windows
::
:: What this does:
::   1. Clones N64Recomp into n64recomp\ at the SHA pinned in
::      n64recomp.pin (or junctions to a sister checkout if present).
::   2. Initializes the disasm submodule (pret/pokestadium).
::   3. Stages the verified baserom.z64 into disasm\baseroms\us\.
::   4. (Optional) Clones Ares emulator if WITH_ARES=1.

setlocal

set "ARES_REPO=https://github.com/ares-emulator/ares.git"

:: ---- Framework and disassembly submodules ----
git submodule update --init --recursive engine/N64Recomp disasm
if errorlevel 1 exit /b %errorlevel%

:: ---- Disasm submodule ----
git submodule update --init --recursive disasm

:: ---- Stage ROM into disasm ----
if exist "baserom.z64" (
    if not exist "disasm\baseroms\us\baserom.z64" (
        if not exist "disasm\baseroms\us" mkdir "disasm\baseroms\us"
        copy /Y "baserom.z64" "disasm\baseroms\us\baserom.z64" >nul
        echo Staged baserom.z64 -^> disasm\baseroms\us\
    )
)

:: ---- Ares oracle (optional, opt-in) ----
if "%WITH_ARES%"=="1" (
    if not exist "ares-emulator\.git" (
        echo Cloning Ares ^(this is a large repo^)...
        git clone %ARES_REPO% ares-emulator
    )
)

echo.
echo Setup complete.
echo Next:
echo   1. cd disasm ^&^& make init ^&^& make
echo   2. (back at root) cmake -S . -B build -G "Visual Studio 17 2022" -A x64
echo   3. See ghidra\instructions.txt for analysis setup.

endlocal
