;
; Date: 1999-01-08			Mikael Kalms (Scout/C-Lous & more)
;					Email: mikael@kalms.org
;
; About:
;   1x1 6bpl cpu5 C2P for contigous bitplanes and no horizontal modulo
;
;   This routine is intended for use on all 68040 and 68060 based systems.
;   It is not designed to perform well on 68020-030.
;
;   This routine is released into the public domain. It may be freely used
;   for non-commercial as well as commercial purposes. A short notice via
;   email is always appreciated, though.
;
; Timings:
;   ~133% on (a1200 Blizzard) 040-25
;   Estimated to run at copyspeed on 040-40 and 060
;
; Features:
;   Performs CPU-only C2P conversion using rather state-of-the-art (as of
;   the creation date, anyway) techniques
;   Handles bitplanes of virtually any size (4GB)
;
; Restrictions:
;   Chunky-buffer must be an even multiple of 32 pixels wide
;   If incorrect/invalid parameters are specified, the routine will
;   most probably crash.
;
; c2p1x1_6_c5_040_smcinit		changes the bitplane-size &
;					chunkybuffer size/pos
; c2p1x1_6_c5_040_init			sets only the chunkybuffer size/pos
; c2p1x1_6_c5_040			performs the actual c2p conversion
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

	XDEF	_c2p1x1_6_c5_040_smcinit
	XDEF	_c2p1x1_6_c5_040_init
	XDEF	_c2p1x1_6_c5_040

;	include	include:lvo/exec_lib.i

	section	code,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	bplsize [bytes] -- offset between one row in one bpl and the next bpl

_c2p1x1_6_c5_040_smcinit
c2p1x1_6_c5_040_smcinit
	movem.l	d2-d3/a6,-(sp)
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p1x1_6_c5_040_scroffs
	mulu.w	d0,d1
	move.l	d1,c2p1x1_6_c5_040_pixels
	move.l	d5,d0
	lsl.l	#2,d0
	add.l	d5,d0
	move.l	d0,c2p1x1_6_c5_040_smc1
	addq.l	#4,d0
	move.l	d0,c2p1x1_6_c5_040_smc4
	move.l	d5,c2p1x1_6_c5_040_smc2
	move.l	d5,c2p1x1_6_c5_040_smc3
	move.l	d5,c2p1x1_6_c5_040_smc5
	move.l	d5,c2p1x1_6_c5_040_smc6
	move.l	d5,c2p1x1_6_c5_040_smc7
	move.l	d5,c2p1x1_6_c5_040_smc8
	move.l	d5,c2p1x1_6_c5_040_smc9
	move.l	execbase,a6
	jsr	_LVOCacheClearU(a6)
	movem.l	(sp)+,d2-d3/a6
	rts

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	(bplsize) [bytes] -- offset between one row in one bpl and the next bpl

_c2p1x1_6_c5_040_init
c2p1x1_6_c5_040_init
	move.l	d3,-(sp)
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p1x1_6_c5_040_scroffs
	mulu.w	d0,d1
	move.l	d1,c2p1x1_6_c5_040_pixels
	move.l	(sp)+,d3
	rts

; a0	chunkybuffer
; a1	bitplanes

_c2p1x1_6_c5_040
c2p1x1_6_c5_040

	movem.l	d2-d7/a2-a6,-(sp)

	add.l	#BPLSIZE*5,a1
c2p1x1_6_c5_040_smc1 EQU *-4
	add.l	c2p1x1_6_c5_040_scroffs,a1

	move.l	c2p1x1_6_c5_040_pixels,a2
	tst.l	a2
	beq	.none
	add.l	a0,a2

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d5
	move.l	(a0)+,a5
	move.l	(a0)+,a6

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

	lsl.l	#2,d0			; Swap/Merge 2x4, part 1
	lsl.l	#2,d1
	or.l	d4,d0
	or.l	d2,d1

	move.l	d1,d6			; Swap 8x2, part 1
	move.l	a5,d4			; Swap 16x4, part 2, interleaved
	lsr.l	#8,d6
	move.l	a6,d2

	bra	.start
	cnop	0,16
.x
	tst.b	16(a0)
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	tst.b	16(a0)
	move.l	(a0)+,d4
	move.l	(a0)+,d5
	move.l	(a0)+,a5
	move.l	(a0)+,a6

	move.l	d6,(a1)
	sub.l	#BPLSIZE,a1
c2p1x1_6_c5_040_smc2 EQU *-4

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
	move.l	a3,(a1)
	sub.l	#BPLSIZE,a1
c2p1x1_6_c5_040_smc3 EQU *-4
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

	lsl.l	#2,d0			; Swap/Merge 2x4, part 1
	lsl.l	#2,d1
	or.l	d4,d0
	or.l	d2,d1

	move.l	d1,d6			; Swap 8x2, part 1
	move.l	a5,d4			; Swap 16x4, part 2, interleaved
	lsr.l	#8,d6
	move.l	a6,d2
	move.l	a4,(a1)
	add.l	#BPLSIZE*5+4,a1
c2p1x1_6_c5_040_smc4 EQU *-4
.start
	swap	d5
	swap	d3
	eor.l	d0,d6
	eor.w	d4,d5
	and.l	#$00ff00ff,d6
	eor.w	d2,d3
	eor.l	d6,d0
	eor.w	d5,d4
	lsl.l	#8,d6
	eor.w	d3,d2
	eor.l	d6,d1
	eor.w	d4,d5

	move.l	d1,d6			; Swap 1x2, part 1
	eor.w	d2,d3			; Swap 16x4, part 2, interleaved
	swap	d5
	swap	d3
	lsr.l	#1,d6
	eor.l	d0,d6
	and.l	#$55555555,d6
	eor.l	d6,d0
	add.l	d6,d6
	eor.l	d6,d1

	move.l	d0,(a1)
	sub.l	#BPLSIZE,a1
c2p1x1_6_c5_040_smc5 EQU *-4

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
	move.l	d1,(a1)
	sub.l	#BPLSIZE,a1
c2p1x1_6_c5_040_smc6 EQU *-4
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
	sub.l	#BPLSIZE,a1
c2p1x1_6_c5_040_smc7 EQU *-4
	add.l	d6,d6
	add.l	d7,d7
	eor.l	d2,d6
	eor.l	d7,d3

	move.l	d5,a3
	move.l	d3,a4

	cmp.l	a0,a2
	bne	.x

	move.l	d6,(a1)
	sub.l	#BPLSIZE,a1
c2p1x1_6_c5_040_smc8 EQU *-4
	move.l	a3,(a1)
	sub.l	#BPLSIZE,a1
c2p1x1_6_c5_040_smc9 EQU *-4
	move.l	a4,(a1)


.none	movem.l	(sp)+,d2-d7/a2-a6
	rts

	section	bss,bss

c2p1x1_6_c5_040_scroffs	ds.l	1
c2p1x1_6_c5_040_pixels	ds.l	1
