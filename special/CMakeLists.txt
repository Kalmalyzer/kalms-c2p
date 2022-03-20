
set(ASM_SOURCES
  c2p1x1_4_c5_word.s)

set(C_SOURCES
  special_test.c
  special.c special.h
  c2p1x1_4_c5_word_test.c c2p1x1_4_c5_word.h)

set_source_files_properties(${ASM_SOURCES} PROPERTIES LANGUAGE AMIGA_VASM)

add_library(special
	${ASM_SOURCES})

add_executable(special_test
	${C_SOURCES})

target_link_libraries(special_test
	special testhelpers)
