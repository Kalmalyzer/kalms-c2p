#include "../utest/utest.h"

#include "testdata.h"
#include "assert_array.h"
#include "c2p1x1_6_c5_030_2.h"

#include <string.h>

struct utest_state_s;
extern struct utest_state_s utest_state;

UTEST(normal, c2p1x1_6_c5_030_2) {

	const int chunkyx = 320;
	const int chunkyy = 256;
	const int scroffsy = 0;
	const int bplsize = 320 * 256 / 8;
	const int depth = 6;

	memset(tempbuf, 0, bplsize * depth);

	c2p1x1_6_c5_030_2_smcinit(chunkyx, chunkyy, scroffsy, bplsize);
	c2p1x1_6_c5_030_2(random_320x256x6bpl_chunky, tempbuf);

	ASSERT_ARRAY_EQ(random_320x256x8bpl_planar, tempbuf, bplsize * depth);
}
