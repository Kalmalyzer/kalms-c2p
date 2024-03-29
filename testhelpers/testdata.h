#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

extern uint8_t random_160x256x4bpl_chunky[];
extern uint8_t random_160x256x6bpl_chunky[];
extern uint8_t random_160x256x8bpl_chunky[];
extern uint8_t random_224x240x2bpl_chunky[];
extern uint8_t random_224x240x4bpl_chunky[];
extern uint8_t random_224x240x6bpl_chunky[];
extern uint8_t random_224x240x8bpl_chunky[];
extern uint8_t random_224x240x8bpl_offs32x10_320x256x8bpl_planar[];
extern uint8_t random_320x256x2bpl_chunky[];
extern uint8_t random_320x256x4bpl_chunky[];
extern uint8_t random_320x256x5bpl_chunky[];
extern uint8_t random_320x256x6bpl_chunky[];
extern uint8_t random_320x256x8bpl_chunky[];
extern uint8_t random_320x256x8bpl_planar[];
extern uint8_t random_320x256x8bpl_2x1_planar[];
extern uint8_t random_320x256x8bpl_2x2_planar[];

extern uint8_t tempbuf[];

#ifdef __cplusplus
}
#endif
