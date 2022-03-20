#include "../utest/utest.h"
#include <proto/exec.h>

struct special {
	uint8_t* tempbuf_chipmem;
};

enum {
    tempbuf_chipmem_size = 256 * 256 * 4
};

UTEST_F_SETUP(special) {
	utest_fixture->tempbuf_chipmem = AllocMem(tempbuf_chipmem_size, MEMF_CHIP);
	ASSERT_TRUE(utest_fixture->tempbuf_chipmem);
}

UTEST_F_TEARDOWN(special) {
	FreeMem(utest_fixture->tempbuf_chipmem, tempbuf_chipmem_size);
}
