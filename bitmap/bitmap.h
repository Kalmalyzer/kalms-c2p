#include "../utest/utest.h"
#include <proto/exec.h>

struct normal {
	uint8_t* tempbuf_chipmem;
};

enum {
    tempbuf_chipmem_size = 256 * 256 * 4
};

UTEST_F_SETUP(normal) {
	utest_fixture->tempbuf_chipmem = AllocMem(tempbuf_chipmem_size, MEMF_CHIP);
	ASSERT_TRUE(utest_fixture->tempbuf_chipmem);
}

UTEST_F_TEARDOWN(normal) {
	FreeMem(utest_fixture->tempbuf_chipmem, tempbuf_chipmem_size);
}
