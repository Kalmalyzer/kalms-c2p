#include "../utest/utest.h"

#include "testdata.h"
#include "assert_array.h"
#include "c2p1x1_5_c3b1_030.h"
#include "normal.h"

#include <string.h>

struct utest_state_s;
extern struct utest_state_s utest_state;

UTEST_F(normal, c2p1x1_5_c3b1_030) {

	const int chunkyx = 320;
	const int chunkyy = 256;
	const int scroffsy = 0;
	const int bplsize = 320 * 256 / 8;
	const int depth = 5;

	memset(utest_fixture->tempbuf_chipmem, 0, bplsize * depth);

	c2p1x1_5_c3b1_030_init(chunkyx, chunkyy, scroffsy, bplsize);
	c2p1x1_5_c3b1_030(random_320x256x5bpl_chunky, utest_fixture->tempbuf_chipmem, utest_fixture->tempbuf_chipmem + 256 * 256 * 2);
	c2p1x1_5_c3b1_030_waitblit();

	ASSERT_ARRAY_EQ(random_320x256x8bpl_planar, utest_fixture->tempbuf_chipmem, bplsize * depth);
}
