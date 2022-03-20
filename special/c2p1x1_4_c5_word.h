#pragma once

#ifdef __cplusplus
extern "C" {
#endif

extern void c2p1x1_4_c5_word(int chunkyx __asm("d0"), int chunkyy __asm("d1"), int bplsize __asm("d5"), void* c2pscreen __asm("a0"), void* bitplanes __asm("a1"));

#ifdef __cplusplus
}
#endif
