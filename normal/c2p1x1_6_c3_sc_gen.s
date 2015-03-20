;
; Date: 26-Nov-1998			Mikael Kalms (Scout/C-Lous & more)
;					Email: mikael@kalms.org
;
; About:
;   1x1 6bpl cpu3 C2P for contigous bitplanes and no horizontal modulo
;
;   This routine is intended for use on all 68020-68060 systems.
;
;   When the c2p reads from the chunkybuffer, it will assume that the pixels
;     are stored in the following order:
;     0,8,16,24,1,9,17,25,2,10,18,26, (n, n+8, n+16, n+24) ...
;     The sequence repeats after each 32-byte block.
;
;   This routine is released into the public domain. It may be freely used
;   for non-commercial as well as commercial purposes. A short notice via
;   email is always appreciated, though.
;
; Timings:
;   Estimated to run close to copyspeed on 040-40 and 060
;
; Features:
;   Performs CPU-only scrambled C2P conversion using rather state-of-the-art
;   (as of the creation date, anyway) techniques
;
; Restrictions:
;   Chunky-buffer must be an even multiple of 32 pixels wide
;   If incorrect/invalid parameters are specified, the routine will
;   most probably crash.
;
; c2p1x1_6_c3_sc_gen_init		sets the chunkybuffer size/pos
; c2p1x1_6_c3_sc_gen			performs the actual c2p conversion
;

	IFND	BPLX
BPLX	EQU	320
	ENDC
	IFND	BPLY
BPLY	EQU	256
	ENDC
	IFND	BPLSIZE
BPLSIZE	EQU	BPLX*BPLY/8
	ENDC
	IFND	CHUNKYXMAX
CHUNKYXMAX EQU	BPLX
	ENDC
	IFND	CHUNKYYMAX
CHUNKYYMAX EQU	BPLY
	ENDC

	section	code,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	(bplsize) [bytes] -- offset between one row in one bpl and the next bpl

_c2p1x1_6_c3_sc_gen_init
c2p1x1_6_c3_sc_gen_init
	move.l	d3,-(sp)
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p1x1_6_c3_sc_gen_scroffs
	mulu.w	d0,d1
	move.l	d1,c2p1x1_6_c3_sc_gen_pixels
	move.l	(sp)+,d3
	rts

; a0	c2pscreen
; a1	bitplanes

_c2p1x1_6_c3_sc_gen
c2p1x1_6_c3_sc_gen
	cmp.w	#.xend-.x,d0
	movem.l	d2-d7/a2-a6,-(sp)

	add.w	#BPLSIZE,a1
	add.l	c2p1x1_6_c3_sc_gen_scroffs,a1
	move.l	a1,a2
	add.l	#BPLSIZE*3,a2

	move.l	#$55555555,a3

	move.l	c2p1x1_6_c3_sc_gen_pixels,d0
	beq	.none
	add.l	a0,d0
	move.l	d0,-(sp)

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d5

	move.l	#$0f0f0f0f,d6

	move.l	d4,d7
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d4
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d6,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d5

	move.l	d4,a5
	move.l	d5,a6

	move.l	(a0)+,d4
	move.l	(a0)+,d5

	move.l	d4,d7
	lsr.l	#4,d7
	eor.l	d2,d7
	and.l	d6,d7
	eor.l	d7,d2
	lsl.l	#4,d7
	eor.l	d7,d4
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d3,d7
	and.l	d6,d7

	bra.s	.start
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d5
	move.l	d7,-BPLSIZE(a1)

	move.l	#$0f0f0f0f,d6

	move.l	d4,d7
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d4
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d6,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d5

	move.l	a5,d7
	move.l	d4,a5
	move.l	d5,a6

	move.l	(a0)+,d4
	move.l	(a0)+,d5
	move.l	d7,(a1)+

	move.l	d4,d7
	lsr.l	#4,d7
	eor.l	d2,d7
	and.l	d6,d7
	eor.l	d7,d2
	lsl.l	#4,d7
	eor.l	d7,d4
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d3,d7
	and.l	d6,d7
	move.l	a4,BPLSIZE-4(a1)
.start
	eor.l	d7,d3
	lsl.l	#4,d7
	eor.l	d7,d5

	lsl.l	#2,d0
	or.l	d2,d0
	lsl.l	#2,d1
	or.l	d3,d1

	move.l	a3,d6

	move.l	d1,d7
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	move.l	d0,BPLSIZE(a2)
	add.l	d7,d7
	eor.l	d7,d1

	move.l	a5,d0
	exg	d1,a6

	move.l	#$33333333,d6

	move.l	d4,d7
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d7,d4
	move.l	d5,d7
	lsr.l	#2,d7
	move.l	a6,(a2)+
	eor.l	d1,d7
	and.l	d6,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d5

	move.l	a3,d6

	move.l	d1,d7
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	move.l	d0,-BPLSIZE-4(a2)
	add.l	d7,d7
	eor.l	d7,d1
	move.l	d5,d7
	lsr.l	#1,d7
	eor.l	d4,d7
	and.l	d6,d7
	eor.l	d7,d4
	add.l	d7,d7
	eor.l	d5,d7

	move.l	d1,a4
	move.l	d4,a5

	cmp.l	(sp),a0
	bne	.x
.xend
	move.l	d7,-BPLSIZE(a1)
	move.l	a5,(a1)+
	move.l	a4,BPLSIZE-4(a1)

	addq.l	#4,sp

.none	movem.l	(sp)+,d2-d7/a2-a6
	rts

	section	bss,bss

c2p1x1_6_c3_sc_gen_scroffs	ds.l	1
c2p1x1_6_c3_sc_gen_pixels	ds.l	1
