
; c2p1x1_8_c5_060

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

	section	c2p,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	(bplsize) [bytes] -- offset between one row in one bpl and the next bpl

c2p1x1_8_c5_060_init
	movem.l	d2-d3,-(sp)
	lea	c2p_datanew(pc),a0
	andi.l	#$ffff,d0
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p_scroffs-c2p_data(a0)
	mulu.w	d0,d1
	move.l	d1,c2p_pixels-c2p_data(a0)
	movem.l	(sp)+,d2-d3
	rts

; a0	c2pscreen
; a1	bitplanes

c2p1x1_8_c5_060
	move.w	#.xend-.x,d0

	movem.l	d2-d7/a2-a6,-(sp)

	bsr	c2p_copyinitblock

	lea	c2p_data(pc),a2

	add.w	#BPLSIZE,a1
	add.l	c2p_scroffs-c2p_data(a2),a1

	move.l	c2p_pixels-c2p_data(a2),a3
	add.l	a0,a3

	move.l	a1,a2
	add.l	#BPLSIZE*4,a2

	cmp.l	a0,a3
	beq	.none

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	move.l	#$0f0f0f0f,d5		; Swap 4x1, parts 1 & 2
	move.l	d1,d6
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	d5,d6
	and.l	d5,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	move.l	d0,a4
	move.l	d1,a5
	move.l	d2,a6
	move.l	d3,d5

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	move.l	d1,d6			; Swap 4x1, parts 3 & 4
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

	exg	d1,a4
	exg	d3,a6

	move.w	d0,d6			; Swap 16x4, parts 1 & 3
	move.w	d2,d7
	move.w	d1,d0
	move.w	d3,d2
	swap	d0
	swap	d2
	move.w	d0,d1
	move.w	d2,d3
	move.w	d6,d0
	move.w	d7,d2

	bra	.start
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	move.l	d7,BPLSIZE*2(a1)

	move.l	#$0f0f0f0f,d5		; Swap 4x1, parts 1 & 2
	move.l	d1,d6
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	d5,d6
	and.l	d5,d7
	move.l	a6,-BPLSIZE(a1)
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	move.l	a5,d7

	move.l	d0,a4
	move.l	d1,a5
	move.l	d2,a6
	move.l	d3,d5

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	move.l	d7,(a1)+

	move.l	d1,d6			; Swap 4x1, parts 3 & 4
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

	exg	d1,a4
	exg	d3,a6

	move.w	d0,d6			; Swap 16x4, parts 1 & 3
	move.w	d2,d7
	move.w	d1,d0
	move.w	d3,d2
	swap	d0
	swap	d2
	move.w	d0,d1
	move.w	d2,d3
	move.w	d6,d0
	move.w	d7,d2

	move.l	d4,BPLSIZE-4(a1)
.start
	move.l	#$33333333,d4		; Swap 2x4, parts 1 & 3
	move.l	d0,d6
	move.l	d2,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d1,d6
	eor.l	d3,d7
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d1
	eor.l	d7,d3
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d0
	eor.l	d7,d2

	move.l	#$00ff00ff,d4		; Swap 8x2, parts 1 & 3
	move.l	d2,d6
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	#$55555555,d4		; Swap 1x2, parts 1 & 3
	move.l	d2,d6
	move.l	d3,d7
	lsr.l	#1,d6
	lsr.l	#1,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d0
	eor.l	d7,d1
	move.l	d1,BPLSIZE*2(a2)
	add.l	d6,d6
	add.l	d7,d7
	eor.l	d6,d2
	eor.l	d7,d3

	exg	a5,d0
	exg	d5,d1
	exg	a4,d2
	exg	a6,d3

	move.w	d2,d6			; Swap 16x4, parts 2 & 4
	move.w	d3,d7
	move.w	d0,d2
	move.w	d1,d3
	swap	d2
	swap	d3
	move.l	a6,BPLSIZE(a2)
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d7,d3

	move.l	#$33333333,d4		; Swap 2x4, parts 2 & 4
	move.l	d2,d6
	move.l	d3,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#2,d6
	lsl.l	#2,d7
	move.l	a5,(a2)+
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	#$00ff00ff,d4		; Swap 8x2, parts 2 & 4
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
	move.l	a4,-BPLSIZE-4(a2)
	eor.l	d6,d1
	eor.l	d7,d3

	move.l	#$55555555,d4		; Swap 1x2, parts 2 & 4
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
	eor.l	d6,d1
	eor.l	d7,d3

	move.l	d0,d7
	move.l	d1,d4
	move.l	d2,a5
	move.l	d3,a6

	cmp.l	a0,a3
	bne	.x
.xend

	move.l	d7,BPLSIZE*2(a1)
	move.l	d4,BPLSIZE(a1)
	move.l	a5,(a1)+
	move.l	a6,-BPLSIZE-4(a1)
.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

c2p_copyinitblock
	movem.l	a0-a1,-(sp)
	lea	c2p_datanew,a0
	lea	c2p_data,a1
	moveq	#16-1,d0
.copy	move.l	(a0)+,(a1)+
	dbf	d0,.copy
	movem.l	(sp)+,a0-a1
	rts

	cnop	0,4

c2p_data
c2p_screen dc.l	0
c2p_scroffs dc.l 0
c2p_pixels dc.l 0
	ds.l	16

	cnop 0,4
c2p_datanew
	ds.l	16
