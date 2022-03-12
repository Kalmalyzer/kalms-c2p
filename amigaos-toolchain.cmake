set(CMAKE_INSTALL_PREFIX "amiga-gcc" CACHE PATH "Cmake install prefix")
set(CMAKE_FIND_ROOT_PATH ${CMAKE_INSTALL_PREFIX})
set(CMAKE_SYSTEM_PREFIX_PATH /)

set(CMAKE_AR                    "m68k-amigaos-ar")
set(CMAKE_ASM_COMPILER          "m68k-amigaos-as")
set(CMAKE_C_COMPILER            "m68k-amigaos-gcc")
set(CMAKE_CXX_COMPILER          "m68k-amigaos-g++")
set(CMAKE_LINKER                "m68k-amigaos-ld")
set(CMAKE_OBJCOPY               "m68k-amigaos-objcopy")
set(CMAKE_RANLIB                "m68k-amigaos-ranlib")
set(CMAKE_SIZE                  "m68k-amigaos-size")
set(CMAKE_STRIP                 "m68k-amigaos-strip")

set(CMAKE_C_FLAGS               "-mcrt=nix13")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)