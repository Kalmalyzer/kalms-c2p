
set(ASM_SOURCES
  c2p1x1_2_c5_gen.s
  c2p1x1_4_c5_gen.s
  c2p1x1_5_c5_030.s
  c2p1x1_5_c5_060.s
  c2p1x1_6_c3b1_030.s
  c2p1x1_6_c5_030.s
  c2p1x1_6_c5_030_2.s
  c2p1x1_6_c5_040.s
  c2p1x1_6_c5_gen.s
  c2p1x1_8_c3b1_030.s
  c2p1x1_8_c5_030.s
  c2p1x1_8_c5_030_2.s
  c2p1x1_8_c5_040.s
  c2p1x1_8_c5_gen.s)

set(C_SOURCES
  normal_test.c
  normal.c normal.h
  c2p1x1_2_c5_gen_test.c c2p1x1_2_c5_gen.h
  c2p1x1_4_c5_gen_test.c c2p1x1_4_c5_gen.h
  c2p1x1_5_c5_030_test.c c2p1x1_5_c5_030.h
  c2p1x1_5_c5_060_test.c c2p1x1_5_c5_060.h
  c2p1x1_6_c3b1_030_test.c c2p1x1_6_c3b1_030.h
  c2p1x1_6_c5_030_test.c c2p1x1_6_c5_030.h
  c2p1x1_6_c5_030_2_test.c c2p1x1_6_c5_030_2.h
  c2p1x1_6_c5_040_test.c c2p1x1_6_c5_040.h
  c2p1x1_6_c5_gen_test.c c2p1x1_6_c5_gen.h
  c2p1x1_8_c3b1_030_test.c c2p1x1_8_c3b1_030.h
  c2p1x1_8_c5_030_test.c c2p1x1_8_c5_030.h
  c2p1x1_8_c5_030_2_test.c c2p1x1_8_c5_030_2.h
  c2p1x1_8_c5_040_test.c c2p1x1_8_c5_040.h
  c2p1x1_8_c5_gen_test.c c2p1x1_8_c5_gen.h)

set_source_files_properties(${ASM_SOURCES} PROPERTIES LANGUAGE AMIGA_VASM)

add_library(normal
	${ASM_SOURCES})

add_executable(normal_test
	${C_SOURCES})

target_link_libraries(normal_test
	normal testhelpers)
