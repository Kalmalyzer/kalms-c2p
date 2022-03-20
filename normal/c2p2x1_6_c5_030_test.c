#include "../utest/utest.h"

#include "testdata.h"
#include "assert_array.h"
#include "c2p2x1_6_c5_030.h"

#include <string.h>

struct utest_state_s;
extern struct utest_state_s utest_state;

UTEST(normal, c2p2x1_6_c5_030) {

	const int chunkyx = 160;
	const int chunkyy = 256;
	const int scroffsy = 0;
	const int bplsize = 320 * 256 / 8;
	const int depth = 6;

	memset(tempbuf, 0, bplsize * depth);

	c2p2x1_6_c5_030_init(chunkyx, chunkyy, scroffsy);
	c2p2x1_6_c5_030(random_160x256x6bpl_chunky, tempbuf);

	ASSERT_ARRAY_EQ(random_320x256x8bpl_2x1_planar, tempbuf, bplsize * depth);
}
