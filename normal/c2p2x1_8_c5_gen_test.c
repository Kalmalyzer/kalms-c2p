#include "../utest/utest.h"

#include "testdata.h"
#include "assert_array.h"
#include "c2p2x1_8_c5_gen.h"

#include <string.h>

struct utest_state_s;
extern struct utest_state_s utest_state;

UTEST(normal, c2p2x1_8_c5_gen) {

	const int chunkyx = 160;
	const int chunkyy = 256;
	const int scroffsx = 0;
	const int scroffsy = 0;
	const int rowlen = chunkyx / 4;
	const int bplsize = 320 * 256 / 8;
	const int chunkylen = chunkyx;
	const int depth = 8;

	memset(tempbuf, 0, bplsize * depth);

	c2p2x1_8_c5_gen_init(chunkyx, chunkyy, scroffsx, scroffsy, rowlen, bplsize, chunkylen);
	c2p2x1_8_c5_gen(random_160x256x8bpl_chunky, tempbuf);

	ASSERT_ARRAY_EQ(random_320x256x8bpl_2x1_planar, tempbuf, bplsize * depth);
}
