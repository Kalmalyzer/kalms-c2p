
;				modulo	max res	fscreen	compu
; c2p1x1_5_c5_030		no	320x256?  no	030

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

	XDEF	_c2p1x1_5_c5_030_init
	XDEF	c2p1x1_5_c5_030_init
_c2p1x1_5_c5_030_init
c2p1x1_5_c5_030_init
	movem.l	d2-d3,-(sp)
	andi.l	#$ffff,d0
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p1x1_5_c5_030_scroffs
	mulu.w	d0,d1
	move.l	d1,c2p1x1_5_c5_030_pixels
	movem.l	(sp)+,d2-d3
	rts

; a0	c2pscreen
; a1	bitplanes

	XDEF	_c2p1x1_5_c5_030
	XDEF	c2p1x1_5_c5_030
_c2p1x1_5_c5_030
c2p1x1_5_c5_030
	movem.l	d2-d7/a2-a6,-(sp)

	move.l	#$33333333,a6

	add.w	#BPLSIZE,a1
	add.l	c2p1x1_5_c5_030_scroffs,a1
	lea	c2p1x1_5_c5_030_tempbuf,a3

	move.l	c2p1x1_5_c5_030_pixels,a2
	add.l	a0,a2
	cmp.l	a0,a2
	beq	.none

	move.l	a1,-(sp)

	move.l	(a0)+,d1
	move.l	(a0)+,d5
	move.l	(a0)+,d0
	move.l	(a0)+,d6

	move.l	#$0f0f0f0f,d4		; Swap 4x1, part 1
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d4,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d5

	move.l	d6,d7
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d6

	move.l	(a0)+,d3
	move.l	(a0)+,d2

	move.l	d2,d7			; Swap 4x1, part 2
	lsr.l	#4,d7
	eor.l	d3,d7
	and.l	d4,d7
	eor.l	d7,d3
	lsl.l	#4,d7
	eor.l	d7,d2

	move.w	d3,d7			; Swap 16x4, part 1
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	lsl.l	#2,d1			; Swap/Merge 2x4, part 1
	or.l	d1,d3
	move.l	d3,(a3)+

	move.l	(a0)+,d1
	move.l	(a0)+,d3

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d4,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3

	move.w	d1,d7			; Swap 16x4, part 2
	move.w	d0,d1
	swap	d1
	move.w	d1,d0
	move.w	d7,d1

	lsl.l	#2,d0			; Swap/Merge 2x4, part 2
	or.l	d0,d1
	move.l	d1,(a3)+

	bra.s	.start1
.x1
	move.l	(a0)+,d1
	move.l	(a0)+,d5
	move.l	(a0)+,d0
	move.l	(a0)+,d6

	move.l	d7,BPLSIZE(a1)

	move.l	#$0f0f0f0f,d4		; Swap 4x1, part 1
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d4,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d5

	move.l	d6,d7
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d6

	move.l	(a0)+,d3
	move.l	(a0)+,d2

	move.l	a4,(a1)+

	move.l	d2,d7			; Swap 4x1, part 2
	lsr.l	#4,d7
	eor.l	d3,d7
	and.l	d4,d7
	eor.l	d7,d3
	lsl.l	#4,d7
	eor.l	d7,d2

	move.w	d3,d7			; Swap 16x4, part 1
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	lsl.l 	#2,d1 			; Swap/Merge 2x4, part 1
	or.l 	d1,d3
	move.l 	d3,(a3)+

	move.l	(a0)+,d1
	move.l	(a0)+,d3

	move.l	a5,-BPLSIZE-4(a1)

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d4,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3

	move.w	d1,d7			; Swap 16x4, part 2
	move.w	d0,d1
	swap	d1
	move.w	d1,d0
	move.w	d7,d1

	lsl.l	#2,d0			; Swap/Merge 2x4, part 2
	or.l	d0,d1
	move.l	d1,(a3)+

.start1
	move.w	d2,d7			; Swap 16x4, part 3 & 4
	move.w	d5,d2
	swap	d2
	move.w	d2,d5
	move.w	d7,d2

	move.w	d3,d7
	move.w	d6,d3
	swap	d3
	move.w	d3,d6
	move.w	d7,d3

	move.l	a6,d0

	move.l	d2,d7			; Swap/Merge 2x4, part 3 & 4
	lsr.l	#2,d7
	eor.l	d5,d7
	and.l	d0,d7
	eor.l	d7,d5
	lsl.l	#2,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#2,d7
	eor.l	d6,d7
	and.l	d0,d7
	eor.l	d7,d6
	lsl.l	#2,d7
	eor.l	d7,d3

	move.l	#$00ff00ff,d4

	move.l	d6,d7			; Swap 8x2, part 1
	lsr.l	#8,d7
	eor.l	d5,d7
	and.l	d4,d7
	eor.l	d7,d5
	lsl.l	#8,d7
	eor.l	d7,d6

	move.l	#$55555555,d1

	move.l	d6,d7			; Swap 1x2, part 1
	lsr.l	d7
	eor.l	d5,d7
	and.l	d1,d7
	eor.l	d7,d5
	move.l	d5,BPLSIZE*2(a1)
	add.l	d7,d7
	eor.l	d6,d7

	move.l	d3,d5			; Swap 8x2, part 2
	lsr.l	#8,d5
	eor.l	d2,d5
	and.l	d4,d5
	eor.l	d5,d2
	lsl.l	#8,d5
	eor.l	d5,d3

	move.l	d3,d5			; Swap 1x2, part 2
	lsr.l	d5
	eor.l	d2,d5
	and.l	d1,d5
	eor.l	d5,d2
	add.l	d5,d5
	eor.l	d5,d3

	move.l	d2,a4
	move.l	d3,a5

	cmpa.l	a0,a2
	bne	.x1
.x1end
	move.l	d7,BPLSIZE(a1)
	move.l	a4,(a1)+
	move.l	a5,-BPLSIZE-4(a1)

	move.l	(sp)+,a1
	add.l	#BPLSIZE*3,a1

	move.l	#$00ff00ff,d3

	lea	c2p1x1_5_c5_030_tempbuf,a0
	move.l	c2p1x1_5_c5_030_pixels,d0
	lsr.l	#2,d0
	lea	(a0,d0.l),a2

	move.l	(a0)+,d0
	move.l	(a0)+,d1

	bra.s	.start2
.x2
	move.l	(a0)+,d0
	move.l	(a0)+,d1

	move.l	d2,(a1)+
.start2

	move.l	d1,d2			; Swap 8x2
	lsr.l	#8,d2
	eor.l	d0,d2
	and.l	d3,d2
	eor.l	d2,d0
	lsl.l	#8,d2
	eor.l	d1,d2

	add.l	d0,d0			; Merge 1x2
	add.l	d0,d2

	cmpa.l	a0,a2
	bne.s	.x2
.x2end
	move.l	d2,(a1)+

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

	section	bss,bss

c2p1x1_5_c5_030_scroffs ds.l 1
c2p1x1_5_c5_030_pixels ds.l 1

c2p1x1_5_c5_030_tempbuf ds.b CHUNKYXMAX*CHUNKYYMAX/4
