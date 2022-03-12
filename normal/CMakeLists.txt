
set(ASM_SOURCES
  c2p1x1_8_c5_030.s
  c2p1x1_8_c5_040.s
  c2p1x1_8_c5_gen.s)

set(C_SOURCES
  normal_test.c
  c2p1x1_8_c5_030_test.c c2p1x1_8_c5_030.h
  c2p1x1_8_c5_040_test.c c2p1x1_8_c5_040.h
  c2p1x1_8_c5_gen_test.c c2p1x1_8_c5_gen.h)

set_source_files_properties(${ASM_SOURCES} PROPERTIES LANGUAGE AMIGA_VASM)

add_library(normal
	${ASM_SOURCES})

add_executable(normal_test
	${C_SOURCES})

target_link_libraries(normal_test
	normal testhelpers)
