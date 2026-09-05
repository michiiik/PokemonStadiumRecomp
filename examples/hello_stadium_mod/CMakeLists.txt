cmake_minimum_required(VERSION 3.20)
project(HelloStadiumMod LANGUAGES NONE)

set(RECOMP_MOD_TOOL "" CACHE FILEPATH "Path to RecompModTool")
set(PSR_MOD_CLANG "" CACHE FILEPATH "Path to an LLVM clang with MIPS support")
set(PSR_MOD_LLD "" CACHE FILEPATH "Path to ld.lld")

if(NOT RECOMP_MOD_TOOL)
    find_program(RECOMP_MOD_TOOL NAMES RecompModTool RecompModTool.exe)
endif()
if(NOT PSR_MOD_CLANG)
    find_program(PSR_MOD_CLANG NAMES clang-18 clang)
endif()
if(NOT PSR_MOD_LLD)
    find_program(PSR_MOD_LLD NAMES ld.lld-18 ld.lld)
endif()

foreach(required_tool RECOMP_MOD_TOOL PSR_MOD_CLANG PSR_MOD_LLD)
    if(NOT ${required_tool} OR NOT EXISTS "${${required_tool}}")
        message(FATAL_ERROR "${required_tool} was not found; pass -D${required_tool}=/absolute/path")
    endif()
endforeach()

set(MOD_OBJECT "${CMAKE_CURRENT_BINARY_DIR}/hello_stadium.o")
set(MOD_ELF "${CMAKE_CURRENT_BINARY_DIR}/mod.elf")
set(MOD_MAP "${CMAKE_CURRENT_BINARY_DIR}/mod.map")
set(MOD_PACKAGE "${CMAKE_CURRENT_BINARY_DIR}/hello_stadium.nrm")

file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/symbols")
configure_file(mod.toml.in "${CMAKE_CURRENT_BINARY_DIR}/mod.toml" COPYONLY)
configure_file(
    symbols/pokestadium.us.1.0.syms.toml
    "${CMAKE_CURRENT_BINARY_DIR}/symbols/pokestadium.us.1.0.syms.toml"
    COPYONLY)

add_custom_command(
    OUTPUT "${MOD_OBJECT}"
    COMMAND "${PSR_MOD_CLANG}"
        -target mips -mips2 -mabi=32 -O2 -G0 -mno-abicalls
        -mno-odd-spreg -mno-check-zero-division -fomit-frame-pointer
        -ffast-math -fno-unsafe-math-optimizations -fno-builtin-memset
        -Wall -Wextra -Wno-unused-parameter -Wno-unknown-pragmas
        -Wno-unused-variable -Werror=section -D_LANGUAGE_C -nostdinc
        -ffunction-sections -I "${CMAKE_CURRENT_SOURCE_DIR}/include"
        -c "${CMAKE_CURRENT_SOURCE_DIR}/src/hello_stadium.c"
        -o "${MOD_OBJECT}"
    DEPENDS
        src/hello_stadium.c
        include/modding.h
    VERBATIM)

add_custom_command(
    OUTPUT "${MOD_ELF}"
    COMMAND "${PSR_MOD_LLD}"
        "${MOD_OBJECT}" -nostdlib -T "${CMAKE_CURRENT_SOURCE_DIR}/mod.ld"
        "-Map=${MOD_MAP}" --unresolved-symbols=ignore-all --emit-relocs
        -e 0 --no-nmagic --gc-sections -o "${MOD_ELF}"
    DEPENDS "${MOD_OBJECT}" mod.ld
    VERBATIM)

add_custom_command(
    OUTPUT "${MOD_PACKAGE}"
    COMMAND "${RECOMP_MOD_TOOL}"
        "${CMAKE_CURRENT_BINARY_DIR}/mod.toml"
        "${CMAKE_CURRENT_BINARY_DIR}"
    DEPENDS
        "${MOD_ELF}"
        "${CMAKE_CURRENT_BINARY_DIR}/mod.toml"
        "${CMAKE_CURRENT_BINARY_DIR}/symbols/pokestadium.us.1.0.syms.toml"
    VERBATIM)

add_custom_target(package ALL DEPENDS "${MOD_PACKAGE}")
