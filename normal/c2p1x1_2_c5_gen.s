
; c2p1x1_2_c5_gen

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

	XDEF	_c2p1x1_2_c5_gen_init
	XDEF	c2p1x1_2_c5_gen_init
_c2p1x1_2_c5_gen_init
c2p1x1_2_c5_gen_init
	movem.l	d2-d3,-(sp)
	andi.l	#$ffff,d0
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p1x1_4_c5_gen_scroffs
	mulu.w	d0,d1
	move.l	d1,c2p1x1_4_c5_gen_pixels
	movem.l	(sp)+,d2-d3
	rts

; a0	c2pscreen
; a1	bitplanes

	XDEF	_c2p1x1_2_c5_gen
	XDEF	c2p1x1_2_c5_gen
_c2p1x1_2_c5_gen
c2p1x1_2_c5_gen
	movem.l	d2-d7/a2-a6,-(sp)

	move.l	#$00ff00ff,d4
	move.l	#$55555555,d5

	add.l	c2p1x1_4_c5_gen_scroffs,a1

	move.l	c2p1x1_4_c5_gen_pixels,a2
	add.l	a0,a2
	cmp.l	a0,a2
	beq	.none

	move.l	(a0)+,d0
	lsl.l	#4,d0
	or.l	(a0)+,d0
	move.l	(a0)+,d1
	lsl.l	#4,d1
	or.l	(a0)+,d1

	move.l	(a0)+,d2
	lsl.l	#4,d2
	or.l	(a0)+,d2
	move.l	(a0)+,d3
	lsl.l	#4,d3
	or.l	(a0)+,d3

	move.w	d2,d6
	move.w	d3,d7
	move.w	d0,d2
	move.w	d1,d3
	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d7,d3

	lsl.l	#2,d0
	lsl.l	#2,d1
	or.l	d2,d0
	or.l	d3,d1

	move.l	d1,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	bra.s	.start
.x
	move.l	(a0)+,d0
	lsl.l	#4,d0
	or.l	(a0)+,d0
	move.l	(a0)+,d1
	lsl.l	#4,d1
	or.l	(a0)+,d1

	move.l	(a0)+,d2
	lsl.l	#4,d2
	or.l	(a0)+,d2
	move.l	(a0)+,d3
	lsl.l	#4,d3
	or.l	(a0)+,d3

	move.l	a5,BPLSIZE(a1)

	move.w	d2,d6
	move.w	d3,d7
	move.w	d0,d2
	move.w	d1,d3
	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d7,d3

	lsl.l	#2,d0
	lsl.l	#2,d1
	or.l	d2,d0
	or.l	d3,d1

	move.l	d1,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	move.l	a6,(a1)+
.start
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	move.l	d1,d7
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	add.l	d7,d7
	eor.l	d7,d1

	move.l	d0,a5
	move.l	d1,a6

	cmpa.l	a0,a2
	bne.s	.x

	move.l	a5,BPLSIZE(a1)
	move.l	a6,(a1)+

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

	section	bss,bss

c2p1x1_4_c5_gen_scroffs ds.l	1
c2p1x1_4_c5_gen_pixels	ds.l	1
