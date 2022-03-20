
set(ASM_SOURCES
  testdata.s)

set_source_files_properties(${ASM_SOURCES} PROPERTIES LANGUAGE AMIGA_VASM)

add_library(testhelpers
	${ASM_SOURCES})

target_include_directories(testhelpers
	PUBLIC
	.)
