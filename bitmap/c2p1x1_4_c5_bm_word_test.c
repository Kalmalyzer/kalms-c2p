#include "../utest/utest.h"

#include "testdata.h"
#include "assert_array.h"
#include "c2p1x1_4_c5_bm_word.h"

#include <string.h>

#include <graphics/gfx.h>

struct utest_state_s;
extern struct utest_state_s utest_state;

UTEST(bitmap, c2p1x1_4_c5_bm_word) {

	const int chunkyx = 320;
	const int chunkyy = 256;
	const int scroffsx = 0;
	const int scroffsy = 0;
	const int bplsize = 320 * 256 / 8;
	const int depth = 4;

	struct BitMap bitmap = {
		.BytesPerRow = chunkyx / 8,
		.Rows = chunkyy,
		.Flags = 0,
		.Depth = depth,
		.Planes = {
			tempbuf + bplsize * 0,
			tempbuf + bplsize * 1,
			tempbuf + bplsize * 2,
			tempbuf + bplsize * 3,
		},
	};

	memset(tempbuf, 0, bplsize * depth);

	c2p1x1_4_c5_bm_word(chunkyx, chunkyy, scroffsx, scroffsy, random_320x256x4bpl_chunky, &bitmap);

	ASSERT_ARRAY_EQ(random_320x256x8bpl_planar, tempbuf, bplsize * depth);
}
