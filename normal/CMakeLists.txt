
set(ASM_SOURCES
  c2p1x1_8_c5_030.s)

set(C_SOURCES
  c2p1x1_8_c5_030_test.c c2p1x1_8_c5_030.h)

set_source_files_properties(${ASM_SOURCES} PROPERTIES LANGUAGE AMIGA_VASM)

add_library(normal
	${ASM_SOURCES})

add_executable(normal_test
	${C_SOURCES})

target_link_libraries(normal_test
	normal testhelpers)
