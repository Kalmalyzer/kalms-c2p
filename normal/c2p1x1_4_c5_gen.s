
; c2p1x1_4_c5

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

c2p1x1_4_c5_gen_init
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

c2p1x1_4_c5_gen
	movem.l	d2-d7/a2-a6,-(sp)

	move.l	#$33333333,d5
	move.l	#$55555555,a5
	move.l	#$00ff00ff,a6

	add.w	#BPLSIZE,a1
	add.l	c2p1x1_4_c5_gen_scroffs,a1

	move.l	c2p1x1_4_c5_gen_pixels,a2
	add.l	a0,a2
	cmp.l	a0,a2
	beq	.none

	move.l	(a0)+,d0		; Merge 4x1
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

	move.w	d2,d6			; Swap 16x2
	move.w	d3,d4
	move.w	d0,d2
	move.w	d1,d3
	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d4,d3

	move.l	d2,d6			; Swap 2x2
	move.l	d3,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	d5,d6
	and.l	d5,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	a6,d4			; Swap 8x1
	move.l	d1,d6
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d1
	eor.l	d7,d3

	bra.s	.start
.x
	move.l	(a0)+,d0		; Merge 4x1
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

	move.l	d6,BPLSIZE(a1)

	move.w	d2,d6			; Swap 16x2
	move.w	d3,d4
	move.w	d0,d2
	move.w	d1,d3
	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d4,d3

	move.l	d7,-BPLSIZE(a1)

	move.l	d2,d6			; Swap 2x2
	move.l	d3,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	d5,d6
	and.l	d5,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	a3,BPLSIZE*2(a1)

	move.l	a6,d4			; Swap 8x1
	move.l	d1,d6
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d1
	eor.l	d7,d3

	move.l	a4,(a1)+
.start
	move.l	a5,d4			; Swap 1x1
	move.l	d1,d6
	move.l	d3,d7
	lsr.l	#1,d6
	lsr.l	#1,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d0
	eor.l	d7,d2
	add.l	d6,d6
	add.l	d7,d7
	eor.l	d1,d6
	eor.l	d3,d7

	move.l	d0,a3
	move.l	d2,a4

	cmpa.l	a0,a2
	bne	.x

	move.l	d6,BPLSIZE(a1)
	move.l	d7,-BPLSIZE(a1)
	move.l	a3,BPLSIZE*2(a1)
	move.l	a4,(a1)+

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

	section	bss,bss

c2p1x1_4_c5_gen_scroffs ds.l	1
c2p1x1_4_c5_gen_pixels	ds.l	1
