cmake_minimum_required(VERSION 3.10)

project(kalms_c2p
	LANGUAGES C CXX)

set (CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/amiga-utils/utilslib/CMake")
enable_language(AMIGA_VASM)

set(CMAKE_C_STANDARD 11)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_AMIGA_VASM_FLAGS "${CMAKE_AMIGA_VASM_FLAGS} -m68020 -no-opt")

# Reference c2p routines & tests
add_subdirectory(bitmap)
add_subdirectory(normal)
add_subdirectory(special)
add_subdirectory(testhelpers)
