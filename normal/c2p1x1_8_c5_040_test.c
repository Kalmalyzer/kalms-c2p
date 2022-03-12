#include "../utest/utest.h"

#include "testdata.h"
#include "assert_array.h"
#include "c2p1x1_8_c5_040.h"

#include <string.h>

struct utest_state_s;
extern struct utest_state_s utest_state;

UTEST(normal, c2p1x1_8_c5_040) {

	const int chunkyx = 320;
	const int chunkyy = 256;
	const int scroffsy = 0;
	const int bplsize = 320 * 256 / 8;

	memset(tempbuf, 0, chunkyx * chunkyy);

	c2p1x1_8_c5_040_init(chunkyx, chunkyy, scroffsy, bplsize);
	c2p1x1_8_c5_040(random_320x256x8bpl_chunky, tempbuf);

	ASSERT_ARRAY_EQ(random_320x256x8bpl_planar, tempbuf, chunkyx * chunkyy);
}
