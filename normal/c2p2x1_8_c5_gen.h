#pragma once

#ifdef __cplusplus
extern "C" {
#endif

extern void c2p2x1_8_c5_gen_init(int chunkyx __asm("d0"), int chunkyy __asm("d1"), int scroffsx __asm("d2"), int scroffsy __asm("d3"), int rowlen __asm("d4"), int bplsize __asm("d5"), int chunkylen __asm("d6"));
extern void c2p2x1_8_c5_gen(void* c2pscreen __asm("a0"), void* bitplanes __asm("a1"));

#ifdef __cplusplus
}
#endif
