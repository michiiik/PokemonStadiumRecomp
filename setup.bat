@echo off
:: Verify the shared Pokemon Stadium workspace layout.
setlocal enabledelayedexpansion

for %%I in ("%~dp0..\..") do set "WORKSPACE_ROOT=%%~fI"
set "DECOMP_DIR=%WORKSPACE_ROOT%\decomp\pokestadium"
set "N64RECOMP_DIR=%WORKSPACE_ROOT%\toolchain\N64Recomp"
set "RUNTIME_DIR=%WORKSPACE_ROOT%\toolchain\N64ModernRuntime"
set "RT64_DIR=%WORKSPACE_ROOT%\toolchain\rt64"
set "UI_DIR=%WORKSPACE_ROOT%\toolchain\recomp-ui"
set "ARES_DIR=%WORKSPACE_ROOT%\toolchain\ares"

for %%D in ("%DECOMP_DIR%" "%N64RECOMP_DIR%" "%RUNTIME_DIR%" "%RT64_DIR%" "%UI_DIR%") do (
    if not exist "%%~D\.git" (
        echo Error: required workspace repository is missing: %%~D
        echo Run git submodule update --init --recursive from %WORKSPACE_ROOT%.
        exit /b 1
    )
)

set "SHA="
for /f "usebackq tokens=1,* delims==" %%a in ("%~dp0n64recomp.pin") do (
    set "key=%%a"
    set "key=!key: =!"
    if "!key!"=="sha" (
        set "SHA=%%b"
        set "SHA=!SHA: =!"
    )
)
if not defined SHA (
    echo Error: no sha found in n64recomp.pin
    exit /b 1
)

for /f %%h in ('git -C "%N64RECOMP_DIR%" rev-parse HEAD') do set "ACTUAL=%%h"
if not "!ACTUAL!"=="%SHA%" (
    echo Note: N64Recomp HEAD ^(!ACTUAL!^) differs from the game pin ^(%SHA%^).
)

set "ROM_PATH=%DECOMP_DIR%\baseroms\us\baserom.z64"
if exist "%ROM_PATH%" (
    echo Stadium 1 baserom found at %ROM_PATH%
) else (
    echo Note: place your legal Stadium 1 US v1.0 ROM at %ROM_PATH%
)

if "%WITH_ARES%"=="1" if not exist "%ARES_DIR%\.git" (
    echo Error: initialize the workspace Ares submodule at %ARES_DIR%.
    exit /b 1
)

echo.
echo Workspace dependencies are available.
for /f %%h in ('git -C "%DECOMP_DIR%" rev-parse --short HEAD') do echo   pokestadium: %%h
for /f %%h in ('git -C "%N64RECOMP_DIR%" rev-parse --short HEAD') do echo   N64Recomp:   %%h
echo.
echo Build the disassembly from: %DECOMP_DIR%
echo Configure the game from the workspace root:
echo   cmake -S games/PokemonStadiumRecomp -B build/games/stadium1

endlocal
