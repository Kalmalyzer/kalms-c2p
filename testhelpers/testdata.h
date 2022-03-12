#pragma once

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

extern uint8_t random_320x256x2bpl_chunky[];
extern uint8_t random_320x256x4bpl_chunky[];
extern uint8_t random_320x256x5bpl_chunky[];
extern uint8_t random_320x256x6bpl_chunky[];
extern uint8_t random_320x256x8bpl_chunky[];
extern uint8_t random_320x256x8bpl_planar[];

extern uint8_t tempbuf[];

#ifdef __cplusplus
}
#endif
