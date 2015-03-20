
; Tiny 8bpl converter. 4k intros, anyone?
;
; c2p1x1_8_c5_gen_mini

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

; a0	chunkybuffer
; a1	bitplanes

c2p1x1_8_c5_gen_mini

	moveq	#0,d4
	add.w	#BPLSIZE*2,a1
	bsr.s	.conv
	sub.l	#CHUNKYXMAX*CHUNKYYMAX+32,a0
	add.w	#BPLSIZE*3,a1
	moveq	#4,d4
.conv	lea	32(a0),a6
	bsr.s	.pix32
	subq.l	#4,a1
	move.l	a0,a6
	add.l	#CHUNKYXMAX*CHUNKYYMAX,a6

.pix32
	movem.l	(a0)+,d0-d3
	move.l	#$0f0f0f0f,d5
	lsr.l	d4,d0
	lsr.l	d4,d1
	lsr.l	d4,d2
	lsr.l	d4,d3
	and.l	d5,d0
	and.l	d5,d1
	and.l	d5,d2
	and.l	d5,d3
	lsl.l	#4,d0
	lsl.l	#4,d2
	or.l	d1,d0
	or.l	d3,d2
	movem.l	(a0)+,d1/d3/d6-d7
	move.l	a5,-BPLSIZE*2(a1)
	lsr.l	d4,d1
	lsr.l	d4,d3
	lsr.l	d4,d6
	lsr.l	d4,d7
	and.l	d5,d1
	and.l	d5,d3
	and.l	d5,d6
	and.l	d5,d7
	lsl.l	#4,d1
	lsl.l	#4,d6
	or.l	d3,d1
	or.l	d7,d6

	swap	d1
	swap	d6
	eor.w	d0,d1
	eor.w	d2,d6
	eor.w	d1,d0
	eor.w	d6,d2
	eor.w	d0,d1
	eor.w	d2,d6
	swap	d1
	swap	d6

	move.l	a4,-BPLSIZE(a1)

	move.l	#$33333333,d5
	move.l	d1,d3
	move.l	d6,d7
	lsr.l	#2,d3
	lsr.l	#2,d7
	eor.l	d0,d3
	eor.l	d2,d7
	and.l	d5,d3
	and.l	d5,d7
	eor.l	d3,d0
	eor.l	d7,d2
	lsl.l	#2,d3
	lsl.l	#2,d7
	eor.l	d3,d1
	eor.l	d7,d6

	move.l	a3,(a1)+

	move.l	#$00ff00ff,d5
	move.l	d2,d3
	move.l	d6,d7
	lsr.l	#8,d3
	lsr.l	#8,d7
	eor.l	d0,d3
	eor.l	d1,d7
	and.l	d5,d3
	and.l	d5,d7
	eor.l	d3,d0
	eor.l	d7,d1
	lsl.l	#8,d3
	lsl.l	#8,d7
	eor.l	d3,d2
	eor.l	d7,d6

	move.l	a2,BPLSIZE-4(a1)

	move.l	#$55555555,d5
	move.l	d2,d3
	move.l	d6,d7
	lsr.l	#1,d3
	lsr.l	#1,d7
	eor.l	d0,d3
	eor.l	d1,d7
	and.l	d5,d3
	and.l	d5,d7
	eor.l	d3,d0
	eor.l	d7,d1
	add.l	d3,d3
	add.l	d7,d7
	eor.l	d3,d2
	eor.l	d7,d6

	move.l	d0,a2
	move.l	d2,a3
	move.l	d1,a4
	move.l	d6,a5
	cmp.l	a0,a6
	bne	.pix32
	rts
