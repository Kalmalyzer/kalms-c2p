
; c2p1x1_6_c0_2
;
; Plain copy, for timing purposes

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

c2p1x1_6_c0_2_init
	movem.l	d2-d3,-(sp)
	andi.l	#$ffff,d0
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p1x1_6_c0_2_scroffs
	mulu.w	d0,d1
	move.l	d1,c2p1x1_6_c0_2_pixels
	movem.l	(sp)+,d2-d3
	rts

; a0	c2pscreen
; a1	bitplanes

c2p1x1_6_c0_2
	movem.l	d2-d7/a2-a6,-(sp)

	add.w	#BPLSIZE,a1
	add.l	c2p1x1_6_c0_2_scroffs,a1

	move.l	c2p1x1_6_c0_2_pixels,a3
	add.l	a0,a3

	move.l	a1,a2
	add.l	#BPLSIZE*3,a2
	cmp.l	a0,a3
	beq.s	.none

.x1
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	move.l	d7,BPLSIZE(a1)
	move.l	a4,(a1)+
	move.l	a5,-BPLSIZE-4(a1)
	move.l	d0,-BPLSIZE(a2)
	move.l	a1,(a2)+
	move.l	a2,BPLSIZE-4(a2)

	cmpa.l	a0,a3
	bne.s	.x1

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

	section	bss,bss

c2p1x1_6_c0_2_scroffs	ds.l	1
c2p1x1_6_c0_2_pixels	ds.l	1
