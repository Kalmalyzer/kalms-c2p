#pragma once

#ifdef __cplusplus
extern "C" {
#endif

struct BitMap;

extern void c2p2x1_4_c5_bm(int chunkyx __asm("d0"), int chunkyy __asm("d1"), int offsx __asm("d2"), int offsy __asm("d3"), void* c2pscreen __asm("a0"), struct BitMap* bitmap __asm("a1"));

#ifdef __cplusplus
}
#endif
