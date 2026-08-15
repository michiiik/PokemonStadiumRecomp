@echo off
:: PokemonStadiumRecomp setup - Windows
::
:: What this does:
::   1. Initializes the framework and disasm submodules needed by the build.
::   2. Recreates the local lib\ dependency junctions CMake expects.
::   3. Stages the verified baserom.z64 into disasm\baseroms\us\.
::   4. (Optional) initializes the Ares oracle dependency if WITH_ARES=1.

setlocal

if not exist "lib" mkdir "lib"

call :link_dep "N64ModernRuntime" "..\N64ModernRuntime-cosim" "..\N64ModernRuntime"
if errorlevel 1 exit /b %errorlevel%
call :link_dep "rt64" "..\rt64"
if errorlevel 1 exit /b %errorlevel%
call :link_dep "RmlUi" "..\RmlUi"
if errorlevel 1 exit /b %errorlevel%
call :link_dep "lunasvg" "..\lunasvg"
if errorlevel 1 exit /b %errorlevel%
call :link_dep "GamepadMotionHelpers" "..\GamepadMotionHelpers"
if errorlevel 1 exit /b %errorlevel%
call :link_dep "SlotMap" "..\SlotMap"
if errorlevel 1 exit /b %errorlevel%
call :link_dep "freetype-windows-binaries" "..\freetype-windows-binaries"
if errorlevel 1 exit /b %errorlevel%
call :link_dep "concurrentqueue" "lib\N64ModernRuntime\thirdparty\concurrentqueue"
if errorlevel 1 exit /b %errorlevel%
call :write_freetype_module
if errorlevel 1 exit /b %errorlevel%

:: ---- Framework and disassembly submodules ----
git submodule update --init engine/N64Recomp disasm
if errorlevel 1 exit /b %errorlevel%
git -C engine\N64Recomp submodule update --init --recursive lib\rabbitizer lib\ELFIO lib\fmt lib\tomlplusplus lib\sljit
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
    git -C engine\N64Recomp submodule update --init --recursive ares-bridge\third_party\ares
    if errorlevel 1 exit /b %errorlevel%
)

echo.
echo Setup complete.
echo Next:
echo   1. cd disasm ^&^& make init ^&^& make
echo   2. (back at root) cmake -S . -B build -G "Visual Studio 17 2022" -A x64
echo   3. See ghidra\instructions.txt for analysis setup.

endlocal
exit /b 0

:link_dep
set "NAME=%~1"
set "PRIMARY=%~2"
set "SECONDARY=%~3"
if exist "lib\%NAME%" exit /b 0
if exist "%PRIMARY%" (
    echo Junctioning lib\%NAME% -^> %PRIMARY%
    mklink /J "lib\%NAME%" "%PRIMARY%" >nul
    exit /b %errorlevel%
)
if not "%SECONDARY%"=="" if exist "%SECONDARY%" (
    echo Junctioning lib\%NAME% -^> %SECONDARY%
    mklink /J "lib\%NAME%" "%SECONDARY%" >nul
    exit /b %errorlevel%
)
echo Error: missing dependency for lib\%NAME%.
echo   Expected sibling checkout: %PRIMARY%
if not "%SECONDARY%"=="" echo   Or fallback checkout: %SECONDARY%
exit /b 1

:write_freetype_module
(
    echo set(FREETYPE_INCLUDE_DIRS ${CMAKE_SOURCE_DIR}/lib/freetype-windows-binaries/include^)
    echo set(FREETYPE_LIBRARIES "${CMAKE_SOURCE_DIR}/lib/freetype-windows-binaries/release static/vs2015-2022/win64/freetype.lib"^)
    echo add_library(Freetype::Freetype STATIC IMPORTED^)
    echo set_target_properties(Freetype::Freetype PROPERTIES
    echo     IMPORTED_LOCATION ${FREETYPE_LIBRARIES}
    echo ^)
    echo target_include_directories(Freetype::Freetype INTERFACE
    echo     ${FREETYPE_INCLUDE_DIRS}
    echo ^)
) > "lib\FindFreetype.cmake"
exit /b %errorlevel%
