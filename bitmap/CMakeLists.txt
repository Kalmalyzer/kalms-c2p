
set(ASM_SOURCES
  c2p1x1_4_c5_bm.s
  c2p1x1_4_c5_bm_word.s
  c2p1x1_6_c5_bm_040.s
  c2p1x1_6_c5_bm.s
  c2p1x1_6_c5_bm_word.s
  c2p1x1_8_c5_bm_040.s
  c2p1x1_8_c5_bm.s
  c2p2x1_4_c5_bm.s
  c2p2x1_8_c5_bm.s
  c2p2x2_8_c5_bm.s)

set(C_SOURCES
  bitmap_test.c
  bitmap.c bitmap.h
  c2p1x1_4_c5_bm_test.c c2p1x1_4_c5_bm.h
  c2p1x1_4_c5_bm_word_test.c c2p1x1_4_c5_bm_word.h
  c2p1x1_6_c5_bm_040_test.c c2p1x1_6_c5_bm_040.h
  c2p1x1_6_c5_bm_test.c c2p1x1_6_c5_bm.h
  c2p1x1_6_c5_bm_word_test.c c2p1x1_6_c5_bm_word.h
  c2p1x1_8_c5_bm_040_test.c c2p1x1_8_c5_bm_040.h
  c2p1x1_8_c5_bm_test.c c2p1x1_8_c5_bm.h
  c2p2x1_4_c5_bm_test.c c2p2x1_4_c5_bm.h
  c2p2x1_8_c5_bm_test.c c2p2x1_8_c5_bm.h
  c2p2x2_8_c5_bm_test.c c2p2x2_8_c5_bm.h)

set_source_files_properties(${ASM_SOURCES} PROPERTIES LANGUAGE AMIGA_VASM)

add_library(bitmap
	${ASM_SOURCES})

add_executable(bitmap_test
	${C_SOURCES})

target_link_libraries(bitmap_test
	bitmap testhelpers)
