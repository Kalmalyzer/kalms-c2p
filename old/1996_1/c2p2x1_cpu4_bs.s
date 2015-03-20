
;				modulo	max res	fscreen	compu
; c2p2x1_cpu4_bs		no	320x256?  no	030

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

	;section	c2p,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	(bplsize) [bytes] -- offset between one row in one bpl and the next bpl

c2p2x1_cpu4_bs_init
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

c2p2x1_cpu4_bs
	movem.l	d2-d7/a2-a6,-(sp)

	move.w	#.x2-.x,d0
	bsr	c2p_copyinitblock

	lea	c2p_data(pc),a2

	add.w	#BPLSIZE,a1
	add.l	c2p_scroffs-c2p_data(a2),a1

	move.l	#$33333333,d4
	move.l	#$0f0f0f0f,d5
	move.l	#$00ff00ff,d6

	move.l	c2p_pixels-c2p_data(a2),a2
	add.l	a0,a2
	cmpa.l	a0,a2
	beq	.none

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3


	swap	d2			; Swap 16x2
	move.w	d0,d7
	move.w	d2,d0
	move.w	d7,d2
	swap	d2

	swap	d3
	move.w	d1,d7
	move.w	d3,d1
	move.w	d7,d3
	swap	d3

	move.l	d2,d7			; Swap 4x2
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3

	bra.s	.start
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3


	move.l	d7,BPLSIZE(a1)

	swap	d2			; Swap 16x2
	move.w	d0,d7
	move.w	d2,d0
	move.w	d7,d2
	swap	d2

	swap	d3
	move.w	d1,d7
	move.w	d3,d1
	move.w	d7,d3
	swap	d3
	move.l	a3,(a1)+

	move.l	d2,d7			; Swap 4x2
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3
	move.l	a4,-BPLSIZE-4(a1)
.start

	move.l	d1,d7			; Swap 8x1, part 1
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	move.l	d1,d7			; Swap 2x1, part 1
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d1,d7
	move.l	d0,BPLSIZE*2(a1)

	move.l	d3,d1			; Swap 8x1, part 2
	lsr.l	#8,d1
	eor.l	d2,d1
	and.l	d6,d1
	eor.l	d1,d2
	lsl.l	#8,d1
	eor.l	d1,d3

	move.l	d3,d1			; Swap 2x1, part 2
	lsr.l	#2,d1
	eor.l	d2,d1
	and.l	d4,d1
	eor.l	d1,d2
	lsl.l	#2,d1
	eor.l	d1,d3
	move.l	d2,a3
	move.l	d3,a4

	cmp.l	a0,a2
	bne	.x
.x2
	move.l	d7,BPLSIZE(a1)
	move.l	a3,(a1)+
	move.l	a4,-BPLSIZE-4(a1)

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
c2p_scroffs2 dc.l 0
c2p_bplsize dc.l 0
c2p_pixels dc.l 0
c2p_pixels2 dc.l 0
c2p_pixels4 dc.l 0
c2p_pixels8 dc.l 0
c2p_pixels16 dc.l 0
c2p_chunkyx16 dc.w 0
c2p_chunkyx32 dc.w 0
c2p_chunkyy dc.w 0
c2p_rowmod dc.w	0
	ds.l	16

	cnop 0,4
c2p_datanew
	ds.l	16
