
; c2p1x1_6_c5_040
;
; 110% on 040-25

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

c2p1x1_6_c5_040_init
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

c2p1x1_6_c5_040
	movem.l	d2-d7/a2-a6,-(sp)

	bsr	c2p_copyinitblock

	lea	c2p_data(pc),a2

	move.l	c2p_pixels-c2p_data(a2),a3
	add.l	a0,a3

	add.w	#BPLSIZE,a1
	add.l	c2p_scroffs-c2p_data(a2),a1
	move.l	a1,a2
	add.l	#BPLSIZE*3,a2

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d5

	move.l	d1,d7			; Swap 4x1, part 1
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	#$0f0f0f0f,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d1
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d4,d7
	and.l	#$0f0f0f0f,d7
	eor.l	d7,d4
	lsl.l	#4,d7
	eor.l	d7,d5

	move.w	d4,d7			; Swap 16x4, part 1
	move.w	d0,d4
	swap	d4
	move.w	d4,d0
	move.w	d7,d4
	move.w	d5,d7
	move.w	d1,d5
	swap	d5
	move.w	d5,d1
	move.w	d7,d5

	lsl.l	#2,d0			; Swap/merge 2x4, part 1
	or.l	d4,d0
	move.l	d5,d7
	lsr.l	#2,d7
	eor.l	d1,d7
	and.l	#$33333333,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d5
	move.l	d5,a4

	move.l	(a0)+,d4
	move.l	(a0)+,d5

	move.l	d3,d7			; Swap 4x1, part 2
	lsr.l	#4,d7
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d7
	eor.l	d7,d2
	lsl.l	#4,d7
	eor.l	d7,d3
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d4,d7
	and.l	#$0f0f0f0f,d7
	eor.l	d7,d4
	lsl.l	#4,d7
	eor.l	d7,d5

	move.w	d4,d7			; Swap 16x4, part 2
	move.w	d2,d4
	swap	d4
	move.w	d4,d2
	move.w	d7,d4
	move.w	d5,d7
	move.w	d3,d5
	swap	d5
	move.w	d5,d3
	move.w	d7,d5

	bra	.start
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d5

	move.l	d7,-BPLSIZE(a1)

	move.l	d1,d7			; Swap 4x1, part 1
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	#$0f0f0f0f,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d1
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d4,d7
	and.l	#$0f0f0f0f,d7
	eor.l	d7,d4
	lsl.l	#4,d7
	eor.l	d7,d5

	move.w	d4,d7			; Swap 16x4, part 1
	move.w	d0,d4
	swap	d4
	move.w	d4,d0
	move.l	a5,(a1)+
	move.w	d7,d4
	move.w	d5,d7
	move.w	d1,d5
	swap	d5
	move.w	d5,d1
	move.w	d7,d5

	lsl.l	#2,d0			; Swap/merge 2x4, part 1
	or.l	d4,d0
	move.l	d5,d7
	lsr.l	#2,d7
	eor.l	d1,d7
	and.l	#$33333333,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d5
	move.l	d5,a4

	move.l	(a0)+,d4
	move.l	(a0)+,d5

	move.l	d6,BPLSIZE-4(a1)

	move.l	d3,d7			; Swap 4x1, part 2
	lsr.l	#4,d7
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d7
	eor.l	d7,d2
	lsl.l	#4,d7
	eor.l	d7,d3
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d4,d7
	and.l	#$0f0f0f0f,d7
	eor.l	d7,d4
	lsl.l	#4,d7
	eor.l	d7,d5

	move.w	d4,d7			; Swap 16x4, part 2
	move.w	d2,d4
	swap	d4
	move.w	d4,d2
	move.w	d7,d4
	move.w	d5,d7
	move.w	d3,d5
	swap	d5
	move.w	d5,d3
	move.l	a6,-BPLSIZE-4(a2)
	move.w	d7,d5
.start
	lsl.l	#2,d2			; Swap/merge 2x4, part 2
	or.l	d4,d2
	move.l	d5,d7
	lsr.l	#2,d7
	eor.l	d3,d7
	and.l	#$33333333,d7
	eor.l	d7,d3
	lsl.l	#2,d7
	eor.l	d7,d5

	move.l	a4,d4

	move.l	d2,d7			; Swap 8x2, part 1
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	#$00ff00ff,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d2
	move.l	d2,d7			; Swap 1x2, part 1
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	#$55555555,d7
	eor.l	d7,d0
	move.l	d0,BPLSIZE(a2)
	add.l	d7,d7
	eor.l	d7,d2

	move.l	d3,d7			; Swap 8x2, part 2
	lsr.l	#8,d7
	eor.l	d1,d7
	and.l	#$00ff00ff,d7
	eor.l	d7,d1
	lsl.l	#8,d7
	eor.l	d7,d3
	move.l	d5,d7
	lsr.l	#8,d7
	eor.l	d4,d7
	and.l	#$00ff00ff,d7
	eor.l	d7,d4
	lsl.l	#8,d7
	eor.l	d7,d5
	move.l	d2,(a2)+

	move.l	d3,d6			; Swap 1x2, part 2
	lsr.l	#1,d6
	eor.l	d1,d6
	and.l	#$55555555,d6
	eor.l	d6,d1
	add.l	d6,d6
	eor.l	d3,d6
	move.l	d5,d7
	lsr.l	#1,d7
	eor.l	d4,d7
	and.l	#$55555555,d7
	eor.l	d7,d4
	add.l	d7,d7
	eor.l	d5,d7

	move.l	d1,a6
	move.l	d4,a5

	cmpa.l	a0,a3
	bne	.x
.x2
	move.l	d7,-BPLSIZE(a1)
	move.l	a5,(a1)+
	move.l	d6,BPLSIZE-4(a1)
	move.l	a6,-BPLSIZE-4(a2)

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
c2p_scroffs dc.l 0
c2p_pixels dc.l 0
	ds.l	16

	cnop 0,4
c2p_datanew
	ds.l	16
