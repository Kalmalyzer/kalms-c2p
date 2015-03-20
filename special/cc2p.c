/*
   Chunky-to-Planar conversion outlined in C
   ... using "bit-matrix transposition"
   techniques (define matrix transposition recursively, then parallelize
   it, create optimized merge operations (bit-exchanging ops), and
   compensate for non-square matrix).
   The conversion code presented herein will, if compiled on a 680x0
   system with a good optimizing compiler, produce almost exactly the
   same conversion code as that used in the 680x0 assembly language
   routines. [Those assembly routines are
   additionally optimized to the limit concerning the memory
   reads/writes.]

   Mikael Kalms, 1999-01-07
*/



// Must be at least 32 bits large
#define ULONG	unsigned long

ULONG	d[8];			// D for Data, nothing to do with
ULONG	t0, t1;			// 680x0 d-regs! nonono :)

// The actual merge operation used
#define MERGE(reg1, reg2, temp, shift, mask) \
	temp = reg2; \
	temp >>= shift; \
	temp ^= reg1; \
	temp &= mask; \
	reg1 ^= temp; \
	temp <<= shift; \
	reg2 ^= temp;

// Two merges interleaved -- helps well on 68060 and probably does
// so as well on other superscalar CPUs [don't trust the compilers!]
#define TWOMERGE(reg1, reg2, reg3, reg4, temp1, temp2, shift, mask) \
	temp1 = reg2; \
	temp2 = reg4; \
	temp1 >>= shift; \
	temp2 >>= shift; \
	temp1 ^= reg1; \
	temp2 ^= reg3; \
	temp1 &= mask; \
	temp2 &= mask; \
	reg1 ^= temp1; \
	reg3 ^= temp2; \
	temp1 <<= shift; \
	temp2 <<= shift; \
	reg2 ^= temp1; \
	reg4 ^= temp2;

// Convert 32 pixels, 8bpl

	// Read in original pixels
	for (int i = 0; i < 8; i++)
		d[i] = *source++;

	// Do the magic
	TWOMERGE(d[0], d[1], d[2], d[3], t0, t1, 4, 0x0f0f0f0f);
	TWOMERGE(d[4], d[5], d[6], d[7], t0, t1, 4, 0x0f0f0f0f);
	TWOMERGE(d[0], d[4], d[1], d[5], t0, t1, 16, 0x0000ffff);
	TWOMERGE(d[2], d[6], d[3], d[7], t0, t1, 16, 0x0000ffff);
	TWOMERGE(d[0], d[4], d[1], d[5], t0, t1, 2, 0x33333333);
	TWOMERGE(d[2], d[6], d[3], d[7], t0, t1, 2, 0x33333333);
	TWOMERGE(d[0], d[2], d[1], d[3], t0, t1, 8, 0x00ff00ff);
	TWOMERGE(d[4], d[6], d[5], d[7], t0, t1, 8, 0x00ff00ff);
	TWOMERGE(d[0], d[2], d[1], d[3], t0, t1, 1, 0x55555555);
	TWOMERGE(d[4], d[6], d[5], d[7], t0, t1, 1, 0x55555555);
	// d[01234567] now contains bitplane data
	// for bitplanes 73625140, in that order (sorry 'bout that,
	// but I'm not going to do any tradeoffs just to make the
	// code look better -- you won't be able to fiddle it away
	// for free in the above merging scheme anyway)

// Convert 32 pixels, 4bpl

	// Read in original pixels
	for (int i = 0; i < 8; i++)
		d[i] = *source++;

	// Do the magic
	d0 = (d0 << 4) | d1;	// 4bpl means every other nibble is
	d1 = (d2 << 4) | d3;	// empty, so compress it! Wasted
	d2 = (d4 << 4) | d5;	// space are wasted cycles cause merges
	d3 = (d6 << 4) | d7;	// work on 32bit regardless of contents
				// (actually above is simplified 4bit
				// merge)
	TWOMERGE(d[0], d[2], d[1], d[3], t0, t1, 16, 0x0000ffff);
	TWOMERGE(d[0], d[2], d[1], d[3], t0, t1, 2, 0x33333333);
	TWOMERGE(d[0], d[1], d[2], d[3], t0, t1, 8, 0x00ff00ff);
	TWOMERGE(d[0], d[1], d[2], d[3], t0, t1, 1, 0x55555555);

	// Now d[0123] contains data for bitplanes 3210


