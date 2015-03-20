;
; Date: 1999-02-11			Mikael Kalms (Scout/C-Lous & more)
;					Email: mikael@kalms.org
;
; About:
;   4byte ARGB8888 -> 4pixel RGBB5555 HAM8 C2P for contigous
;   bitplanes with modulo
;
;   This routine is intended for use on all 68040 and 68060 based systems.
;   It is not designed to perform well on 68020-030.
;
;   This routine is released into the public domain. It may be freely used
;   for non-commercial as well as commercial purposes. A short notice via
;   email is always appreciated, though.
;
;   For best conversion speed, bitplane start and row modulo should be
;   evenly divisible by 4; starting X should be evenly divisible by 32.
;   (Don't open screens which are n+16 pixels wide! Do n+32 or n+64 instead)
;   Aligning chunkybuffer on 16-byte boundary may also help slightly.
;
;   Bitplane data for control bitplane 0: $77777777
;   Bitplane data for control bitplane 1: $cccccccc
;
; Timings:
;
; Features:
;   Handles bitplanes of virtually any size (4GB)
;   Modulo support
;
; Restrictions:
;   Chunky-buffer width should be a multiple of 8
;   Starting X should be a multiple of 32
;   If incorrect/invalid parameters are specified, the routine will
;   most probably crash.
;
; c2p_4rgb888_4rgb555h8_040_init	sets screen & chunkybuffer parameters
; c2p_4rgb888_4rgb555h8_040		performs the actual c2p conversion
;

	section	code,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	scroffsx [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.l	rowlen [bytes] -- offset between one row and the next in a bpl
; d5.l	bplsize [bytes] -- offset between one row in one bpl and the next bpl
; d6.l	chunkylen [bytes] -- offset between one row and the next in chunkybuf

_c2p_4rgb888_4rgb555h8_040_init
c2p_4rgb888_4rgb555h8_040_init
	movem.l	d2-d6,-(sp)
	and.l	#$ffff,d0
	lsr.l	#3,d0
	move.l	d1,c2p_4rgb888_4rgb555h8_040_chunkyy
	move.l	d0,d1
	lsl.l	#5,d0
	move.l	d6,c2p_4rgb888_4rgb555h8_040_chunkymod
	move.l	d0,c2p_4rgb888_4rgb555h8_040_chunkyxlen
	sub.l	d0,d6
	move.l	d6,c2p_4rgb888_4rgb555h8_040_chunkyminimod
	move.l	d5,c2p_4rgb888_4rgb555h8_040_bplsize
	and.l	#$ffe0,d2
	and.l	#$ffff,d3
	lsr.l	#3,d2
	mulu.l	d4,d3
	add.l	d2,d3
	move.l	d3,c2p_4rgb888_4rgb555h8_040_scroffs
	lsl.l	#2,d1
	sub.l	d1,d4
	move.l	d4,c2p_4rgb888_4rgb555h8_040_bplmod
	movem.l	(sp)+,d2-d6
	rts

; a0	chunkybuffer
; a1	bitplanes

_c2p_4rgb888_4rgb555h8_040
c2p_4rgb888_4rgb555h8_040

	movem.l	d2-d7/a2-a6,-(sp)

	move.l	c2p_4rgb888_4rgb555h8_040_bplsize,a3
	add.l	c2p_4rgb888_4rgb555h8_040_scroffs,a1
	lea	(a1,a3.l*4),a1

	move.l	c2p_4rgb888_4rgb555h8_040_chunkyxlen,a2
	tst.l	a2
	beq	.none
	add.l	a0,a2

	move.l	c2p_4rgb888_4rgb555h8_040_chunkyy,d0
	subq.w	#1,d0
	beq	.none

	move.l	d0,-(sp)

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d5
	move.l	(a0)+,d6
	move.l	(a0)+,d7

	lsr.l	#3,d0
	lsr.l	#3,d1
	lsr.l	#3,d2
	lsr.l	#3,d3
	lsr.l	#3,d4
	lsr.l	#3,d5
	lsr.l	#3,d6
	lsr.l	#3,d7

	move.l	d7,a5

	move.b	d0,d7
	lsl.l	#8,d0
	move.b	d7,d0
	move.b	d1,d7
	lsl.l	#8,d1
	move.b	d7,d1
	move.b	d2,d7
	lsl.l	#8,d2
	move.b	d7,d2
	move.b	d3,d7
	lsl.l	#8,d3
	move.b	d7,d3
	move.b	d4,d7
	lsl.l	#8,d4
	move.b	d7,d4
	move.b	d5,d7
	lsl.l	#8,d5
	move.b	d7,d5
	move.b	d6,d7
	lsl.l	#8,d6
	move.b	d7,d6
	exg	d6,a5
	move.b	d6,d7
	lsl.l	#8,d6
	move.b	d7,d6
	move.l	d6,a6

	move.l	d1,d6			; Swap 4x1, part 1
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	exg	d2,a5
	exg	d3,a6

	move.l	d5,d6			; Swap 4x1, part 2
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d4,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d4
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d5
	eor.l	d7,d3

	exg	a5,d1

	move.w	d4,d6			; Swap 16x4, part 1
	move.w	d2,d7
	move.w	d0,d4
	move.w	d1,d2
	swap	d4
	swap	d2
	move.w	d4,d0
	move.w	d2,d1
	move.w	d6,d4
	move.w	d7,d2

	bra	.start

.y	move.l	d0,-(sp)

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d5
	move.l	(a0)+,d6
	move.l	(a0)+,d7
	move.l	a5,(a1)
	lsr.l	#3,d0
	sub.l	a3,a1
	lsr.l	#3,d1
	lsr.l	#3,d2
	lsr.l	#3,d3
	lsr.l	#3,d4
	lsr.l	#3,d5
	lsr.l	#3,d6
	lsr.l	#3,d7

	move.l	d7,a5

	move.b	d0,d7
	lsl.l	#8,d0
	move.b	d7,d0
	move.b	d1,d7
	lsl.l	#8,d1
	move.b	d7,d1
	move.b	d2,d7
	lsl.l	#8,d2
	move.b	d7,d2
	move.b	d3,d7
	lsl.l	#8,d3
	move.b	d7,d3
	move.b	d4,d7
	lsl.l	#8,d4
	move.b	d7,d4
	move.b	d5,d7
	lsl.l	#8,d5
	move.b	d7,d5
	move.b	d6,d7
	lsl.l	#8,d6
	move.b	d7,d6
	exg	d6,a5
	move.l	a6,(a1)
	move.b	d6,d7
	sub.l	a3,a1
	lsl.l	#8,d6
	move.b	d7,d6
	move.l	d6,a6

	move.l	d1,d6			; Swap 4x1, part 1
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	exg	d2,a5
	exg	d3,a6

	move.l	d5,d6			; Swap 4x1, part 2
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d4,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d4
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d5
	eor.l	d7,d3

	exg	a5,d1

	move.w	d4,d6			; Swap 16x4, part 1
	move.w	d2,d7
	move.w	d0,d4
	move.w	d1,d2
	swap	d4
	swap	d2
	move.w	d4,d0
	move.w	d2,d1
	move.w	d6,d4
	move.l	a4,(a1)
	move.w	d7,d2
	lea	4(a1,a3.l*4),a1

	add.l	c2p_4rgb888_4rgb555h8_040_bplmod,a1
	bra	.start
	cnop	0,16
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d5
	move.l	(a0)+,d6
	move.l	(a0)+,d7
	move.l	a5,(a1)
	lsr.l	#3,d0
	sub.l	a3,a1
	lsr.l	#3,d1
	lsr.l	#3,d2
	lsr.l	#3,d3
	lsr.l	#3,d4
	lsr.l	#3,d5
	lsr.l	#3,d6
	lsr.l	#3,d7

	move.l	d7,a5

	move.b	d0,d7
	lsl.l	#8,d0
	move.b	d7,d0
	move.b	d1,d7
	lsl.l	#8,d1
	move.b	d7,d1
	move.b	d2,d7
	lsl.l	#8,d2
	move.b	d7,d2
	move.b	d3,d7
	lsl.l	#8,d3
	move.b	d7,d3
	move.b	d4,d7
	lsl.l	#8,d4
	move.b	d7,d4
	move.b	d5,d7
	lsl.l	#8,d5
	move.b	d7,d5
	move.b	d6,d7
	lsl.l	#8,d6
	move.b	d7,d6
	exg	d6,a5
	move.l	a6,(a1)
	move.b	d6,d7
	sub.l	a3,a1
	lsl.l	#8,d6
	move.b	d7,d6
	move.l	d6,a6

	move.l	d1,d6			; Swap 4x1, part 1
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	exg	d2,a5
	exg	d3,a6

	move.l	d5,d6			; Swap 4x1, part 2
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d4,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d4
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d5
	eor.l	d7,d3

	exg	a5,d1

	move.w	d4,d6			; Swap 16x4, part 1
	move.w	d2,d7
	move.w	d0,d4
	move.w	d1,d2
	swap	d4
	swap	d2
	move.w	d4,d0
	move.w	d2,d1
	move.w	d6,d4
	move.l	a4,(a1)
	move.w	d7,d2
	lea	4(a1,a3.l*4),a1
.start
	and.l	#$11111111,d0
	and.l	#$11111111,d1
	lsl.l	#2,d0			; Swap/Merge 2x4, part 1
	lsl.l	#2,d1
	and.l	#$11111111,d4
	and.l	#$11111111,d2
	or.l	d4,d0
	or.l	d2,d1

	move.l	d1,d6			; Swap 8x2, part 1
	move.l	a5,d4			; Swap 16x4, part 2, interleaved
	lsr.l	#8,d6
	swap	d5
	swap	d3
	move.l	a6,d2
	eor.w	d4,d5
	eor.l	d0,d6
	eor.w	d2,d3
	and.l	#$00ff00ff,d6
	eor.w	d5,d4
	eor.l	d6,d0
	eor.w	d3,d2
	add.l	d0,d0			; Swap/Merge 1x2, part 1, interleaved
	lsl.l	#8,d6
	eor.w	d4,d5
	eor.l	d6,d1
	eor.w	d2,d3
	or.l	d1,d0
	swap	d5
	swap	d3
	move.l	d0,(a1)
	sub.l	a3,a1

	move.l	d5,d6			; Swap/Merge 2x4, part 2
	move.l	d3,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d4,d6
	eor.l	d2,d7
	and.l	#$33333333,d6
	and.l	#$33333333,d7
	eor.l	d6,d4
	eor.l	d7,d2
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d5
	eor.l	d7,d3

	move.l	d2,d6			; Swap 8x2, part 2
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d4,d6
	eor.l	d5,d7
	and.l	#$00ff00ff,d6
	and.l	#$00ff00ff,d7
	eor.l	d6,d4
	eor.l	d7,d5
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	d2,d6			; Swap 1x2, part 2
	move.l	d3,d7
	lsr.l	#1,d6
	lsr.l	#1,d7
	eor.l	d4,d6
	eor.l	d5,d7
	and.l	#$55555555,d6
	and.l	#$55555555,d7
	eor.l	d6,d4
	eor.l	d7,d5
	move.l	d4,(a1)
	add.l	d6,d6
	sub.l	a3,a1
	add.l	d7,d7
	eor.l	d2,d6
	eor.l	d7,d3

	move.l	d5,a6
	move.l	d3,a4

	move.l	d6,a5

	cmp.l	a0,a2
	bne	.x

	add.l	c2p_4rgb888_4rgb555h8_040_chunkyminimod,a0
	add.l	c2p_4rgb888_4rgb555h8_040_chunkymod,a2
	move.l	(sp)+,d0
	dbf	d0,.y

	move.l	a5,(a1)
	sub.l	a3,a1
	move.l	a6,(a1)
	sub.l	a3,a1
	move.l	a4,(a1)

.none	movem.l	(sp)+,d2-d7/a2-a6
	rts

	section	bss,bss

c2p_4rgb888_4rgb555h8_040_scroffs	ds.l	1
c2p_4rgb888_4rgb555h8_040_bplsize	ds.l	1
c2p_4rgb888_4rgb555h8_040_chunkymod	ds.l	1
c2p_4rgb888_4rgb555h8_040_chunkyminimod ds.l	1
c2p_4rgb888_4rgb555h8_040_chunkyxlen	ds.l	1
c2p_4rgb888_4rgb555h8_040_bplmod	ds.l	1
c2p_4rgb888_4rgb555h8_040_chunkyy	ds.l	1
