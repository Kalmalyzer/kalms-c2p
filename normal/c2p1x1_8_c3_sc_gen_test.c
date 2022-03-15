#include "../utest/utest.h"

#include "testdata.h"
#include "assert_array.h"
#include "c2p1x1_8_c3_sc_gen.h"

#include <string.h>

struct utest_state_s;
extern struct utest_state_s utest_state;

UTEST(normal, c2p1x1_8_c3_sc_gen) {

	const int chunkyx = 320;
	const int chunkyy = 256;
	const int scroffsy = 0;
	const int bplsize = 320 * 256 / 8;
	const int depth = 8;

	for (int y = 0; y < chunkyy; y++)
		for (int x = 0; x < chunkyx; x++)
			tempbuf[256 * 256 * 2 + y * chunkyx + ((x & 7) << 2) + ((x >> 3) & 3) + (x & ~0x1f)] = random_320x256x8bpl_chunky[y * chunkyx + x];

	memset(tempbuf, 0, bplsize * depth);

	c2p1x1_8_c3_sc_gen_smcinit(chunkyx, chunkyy, scroffsy);
	c2p1x1_8_c3_sc_gen(tempbuf + 256 * 256 * 2, tempbuf);

	ASSERT_ARRAY_EQ(random_320x256x8bpl_planar, tempbuf, bplsize * depth);
}
