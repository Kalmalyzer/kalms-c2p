#include "../utest/utest.h"

#include "testdata.h"
#include "assert_array.h"
#include "c2p2x1_8_c4b1_gen.h"
#include "normal.h"

#include <string.h>

struct utest_state_s;
extern struct utest_state_s utest_state;

UTEST_F(normal, c2p2x1_8_c4b1_gen) {

	const int chunkyx = 160;
	const int chunkyy = 256;
	const int scroffsy = 0;
	const int bplsize = 320 * 256 / 8;
	const int depth = 8;

	memset(utest_fixture->tempbuf_chipmem, 0, bplsize * depth);

	c2p2x1_8_c4b1_gen_init(chunkyx, chunkyy, scroffsy, bplsize);
	c2p2x1_8_c4b1_gen(random_160x256x8bpl_chunky, utest_fixture->tempbuf_chipmem, utest_fixture->tempbuf_chipmem + 256 * 256 * 2);
	c2p2x1_8_c4b1_gen_waitblit();

	ASSERT_ARRAY_EQ(random_320x256x8bpl_2x1_planar, utest_fixture->tempbuf_chipmem, bplsize * depth);
}
