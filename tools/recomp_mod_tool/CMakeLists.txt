cmake_minimum_required(VERSION 3.20)
project(PokemonStadiumRecompModTool LANGUAGES C CXX)

set(N64RECOMP_SOURCE
    "${CMAKE_CURRENT_LIST_DIR}/../../lib/N64ModernRuntime/N64Recomp"
    CACHE PATH "N64Recomp checkout used to build RecompModTool")

if(NOT EXISTS "${N64RECOMP_SOURCE}/CMakeLists.txt")
    message(FATAL_ERROR
        "N64Recomp is not initialized at ${N64RECOMP_SOURCE}. See MODDING.md.")
endif()

# Give scripts and documentation one generator-independent executable path.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
foreach(config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${config} "${CMAKE_CURRENT_BINARY_DIR}")
endforeach()

# The pinned N64Recomp target compiles src/config.cpp but does not propagate
# Rabbitizer's public include directory to RecompModTool. Add the missing usage
# requirement here instead of modifying the dependency checkout.
add_subdirectory("${N64RECOMP_SOURCE}" "${CMAKE_CURRENT_BINARY_DIR}/N64Recomp")
target_include_directories(RecompModTool PRIVATE
    "${N64RECOMP_SOURCE}/lib/rabbitizer/include"
    "${N64RECOMP_SOURCE}/lib/rabbitizer/cplusplus/include")
target_link_libraries(RecompModTool N64Recomp rabbitizer)
