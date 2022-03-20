#pragma once

#ifdef __cplusplus
extern "C" {
#endif

extern void c2p1x1_6_c3_sc_gen_init(int chunkyx __asm("d0"), int chunkyy __asm("d1"), int scroffsy __asm("d3"));
extern void c2p1x1_6_c3_sc_gen(void* c2pscreen __asm("a0"), void* bitplanes __asm("a1"));

#ifdef __cplusplus
}
#endif
