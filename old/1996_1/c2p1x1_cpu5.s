
;				modulo	max res	fscreen	compu
; c2p1x1_cpu5_queue		no	320x256?  no	030

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

c2p1x1_cpu5_init
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

c2p_blitcleanup
	st	c2p_blitfin-c2p_bltnode(a1)
	sf	c2p_blitactive-c2p_bltnode(a1)
	rts

c2p_waitblit
	tst.b	c2p_blitactive(pc)
	beq.s	.n
.y	tst.b	c2p_blitfin(pc)
	beq.s	.y
.n	rts

; a0	c2pscreen
; a1	bitplanes

c2p1x1_cpu5
	movem.l	d2-d7/a2-a6,-(sp)

	bsr	c2p_copyinitblock

	lea	c2p_data(pc),a2

	move.l	#$33333333,d5
	move.l	#$55555555,d6
	move.l	#$00ff00ff,a6

	add.w	#BPLSIZE,a1
	add.l	c2p_scroffs-c2p_data(a2),a1

	movem.l	a0-a1,-(sp)

	move.l	c2p_pixels-c2p_data(a2),a2
	add.l	a0,a2
	cmp.l	a0,a2
	beq	.none

	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	move.l	#$0f0f0f0f,d4		; Merge 4x1, part 1
	and.l	d4,d0
	and.l	d4,d2
	lsl.l	#4,d0
	or.l	d2,d0

	and.l	d4,d1
	and.l	d4,d3
	lsl.l	#4,d1
	or.l	d3,d1

	move.l	d1,a3

	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d7


	and.l	d4,d1			; Merge 4x1, part 2
	and.l	d4,d2
	lsl.l	#4,d2
	or.l	d1,d2

	and.l	d4,d3
	and.l	d4,d7
	lsl.l	#4,d3
	or.l	d7,d3

	move.l	a3,d1

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

	bra.s	.start1
.x1
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	
	move.l	d7,BPLSIZE(a1)

	move.l	#$0f0f0f0f,d4		; Merge 4x1, part 1
	and.l	d4,d0
	and.l	d4,d2
	lsl.l	#4,d0
	or.l	d2,d0

	and.l	d4,d1
	and.l	d4,d3
	lsl.l	#4,d1
	or.l	d3,d1

	move.l	d1,a3

	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	
	move.l	a4,(a1)+

	and.l	d4,d1			; Merge 4x1, part 2
	and.l	d4,d2
	lsl.l	#4,d2
	or.l	d1,d2

	and.l	d4,d3
	and.l	d4,d7
	lsl.l	#4,d3
	or.l	d7,d3

	move.l	a3,d1

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

	move.l	a5,-BPLSIZE-4(a1)
.start1
	move.l	a6,d4

	move.l	d2,d7			; Swap 2x2
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#2,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d3

	move.l	d1,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	move.l	d1,d7
	lsr.l	d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	move.l	d0,BPLSIZE*2(a1)
	add.l	d7,d7
	eor.l	d1,d7

	move.l	d3,d1
	lsr.l	#8,d1
	eor.l	d2,d1
	and.l	d4,d1
	eor.l	d1,d2
	lsl.l	#8,d1
	eor.l	d1,d3

	move.l	d3,d1
	lsr.l	d1
	eor.l	d2,d1
	and.l	d6,d1
	eor.l	d1,d2
	add.l	d1,d1
	eor.l	d1,d3

	move.l	d2,a4
	move.l	d3,a5

	cmpa.l	a0,a2
	bne	.x1

	move.l	d7,BPLSIZE(a1)
	move.l	a4,(a1)+
	move.l	a5,-BPLSIZE-4(a1)

	movem.l	(sp)+,a0-a1
	add.l	#BPLSIZE*4,a1

	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	
	move.l	#$f0f0f0f0,d4		; Merge 4x1, part 1
	and.l	d4,d0
	and.l	d4,d2
	lsr.l	#4,d2
	or.l	d2,d0

	and.l	d4,d1
	and.l	d4,d3
	lsr.l	#4,d3
	or.l	d3,d1

	move.l	d1,a3

	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	
	and.l	d4,d1			; Merge 4x1, part 2
	and.l	d4,d2
	lsr.l	#4,d1
	or.l	d1,d2

	and.l	d4,d3
	and.l	d4,d7
	lsr.l	#4,d7
	or.l	d7,d3

	move.l	a3,d1

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

	bra.s	.start2
.x2
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	
	move.l	d7,BPLSIZE(a1)

	move.l	#$f0f0f0f0,d4		; Merge 4x1, part 1
	and.l	d4,d0
	and.l	d4,d2
	lsr.l	#4,d2
	or.l	d2,d0

	and.l	d4,d1
	and.l	d4,d3
	lsr.l	#4,d3
	or.l	d3,d1

	move.l	d1,a3

	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	move.l	a4,(a1)+

	and.l	d4,d1			; Merge 4x1, part 2
	and.l	d4,d2
	lsr.l	#4,d1
	or.l	d1,d2

	and.l	d4,d3
	and.l	d4,d7
	lsr.l	#4,d7
	or.l	d7,d3

	move.l	a3,d1

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

	move.l	a5,-BPLSIZE-4(a1)
.start2
	move.l	a6,d4

	move.l	d2,d7			; Swap 2x2
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#2,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#2,d7
	eor.l	d7,d3

	move.l	d1,d7
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	move.l	d1,d7
	lsr.l	d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	move.l	d0,BPLSIZE*2(a1)
	add.l	d7,d7
	eor.l	d1,d7

	move.l	d3,d1
	lsr.l	#8,d1
	eor.l	d2,d1
	and.l	d4,d1
	eor.l	d1,d2
	lsl.l	#8,d1
	eor.l	d1,d3

	move.l	d3,d1
	lsr.l	d1
	eor.l	d2,d1
	and.l	d6,d1
	eor.l	d1,d2
	add.l	d1,d1
	eor.l	d1,d3

	move.l	d2,a4
	move.l	d3,a5

	cmpa.l	a0,a2
	bne	.x2

	move.l	d7,BPLSIZE(a1)
	move.l	a4,(a1)+
	move.l	a5,-BPLSIZE-4(a1)

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

	cnop 0,4
c2p_bltnode
	dc.l	0
c2p_bltroutptr
	dc.l	0
	dc.b	$40,0
	dc.l	0
c2p_bltroutcleanup
	dc.l	c2p_blitcleanup
c2p_blitfin dc.b 0
c2p_blitactive dc.b 0

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
