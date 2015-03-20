
; 4bpl c2p directly to sprites. odd stuff, mon!

	section	code,code

; d0	width (should be 64, 128, 192 or 256)
; d1	height
; a0	chunkybuffer
; a1	array of ptrs to sprite-data

c2p1x1_4_c5_gen_spr64
	movem.l	d2-d7/a2-a6,-(sp)

	lsr.w	#6,d0
	subq.w	#1,d0
	cmp.w	#3,d0
	bhi	.error

	subq.w	#1,d1
	bmi	.error

	sub.w	#8*4,sp

	move.w	d0,-(sp)

	move.l	(a0)+,d2		; Merge 4x1
	lsl.l	#4,d2
	or.l	(a0)+,d2
	move.l	(a0)+,d3
	lsl.l	#4,d3
	or.l	(a0)+,d3
	move.l	(a0)+,d4
	lsl.l	#4,d4
	or.l	(a0)+,d4
	move.l	(a0)+,d5
	lsl.l	#4,d5
	or.l	(a0)+,d5

	move.w	d4,d6			; Swap 16x4
	move.w	d5,d0
	move.w	d2,d4
	move.w	d3,d5
	swap	d4
	swap	d5
	move.w	d4,d2
	move.w	d5,d3
	move.w	d6,d4
	move.w	d0,d5

	move.l	#$33333333,d0
	move.l	d4,d6			; Swap 2x4
	move.l	d5,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d2,d6
	eor.l	d3,d7
	and.l	d0,d6
	and.l	d0,d7
	eor.l	d6,d2
	eor.l	d7,d3
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d4
	eor.l	d7,d5

	move.l	#$00ff00ff,d0
	move.l	d3,d6			; Swap 8x2
	move.l	d5,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d2,d6
	eor.l	d4,d7
	and.l	d0,d6
	and.l	d0,d7
	eor.l	d6,d2
	eor.l	d7,d4
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d3
	eor.l	d7,d5

	move.l	#$55555555,d0
	move.l	d3,d6			; Swap 1x2
	move.l	d5,d7
	lsr.l	#1,d6
	lsr.l	#1,d7
	eor.l	d2,d6
	eor.l	d4,d7
	and.l	d0,d6
	and.l	d0,d7
	eor.l	d6,d2
	eor.l	d7,d4
	add.l	d6,d6
	add.l	d7,d7
	eor.l	d3,d6
	eor.l	d5,d7

	move.l	d2,a5
	move.l	d4,a6

.y	swap	d1
	lea	2(sp),a2
	move.w	(sp),d1

.spr	move.l	(a1)+,a3
	move.l	(a1)+,a4
.x
	move.l	(a0)+,d2		; Merge 4x1
	lsl.l	#4,d2
	or.l	(a0)+,d2
	move.l	(a0)+,d3
	lsl.l	#4,d3
	or.l	(a0)+,d3
	move.l	(a0)+,d4
	lsl.l	#4,d4
	or.l	(a0)+,d4
	move.l	(a0)+,d5
	lsl.l	#4,d5
	or.l	(a0)+,d5

	move.l	d6,(a4)+

	move.w	d4,d6			; Swap 16x4
	move.w	d5,d0
	move.w	d2,d4
	move.w	d3,d5
	swap	d4
	swap	d5
	move.w	d4,d2
	move.w	d5,d3
	move.w	d6,d4
	move.w	d0,d5

	move.l	#$33333333,d0
	move.l	d7,(a3)+
	move.l	d4,d6			; Swap 2x4
	move.l	d5,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d2,d6
	eor.l	d3,d7
	and.l	d0,d6
	and.l	d0,d7
	eor.l	d6,d2
	eor.l	d7,d3
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d4
	eor.l	d7,d5

	move.l	#$00ff00ff,d0
	move.l	d3,d6			; Swap 8x2
	move.l	d5,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	move.l	a5,4(a4)
	eor.l	d2,d6
	eor.l	d4,d7
	and.l	d0,d6
	and.l	d0,d7
	eor.l	d6,d2
	eor.l	d7,d4
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d3
	eor.l	d7,d5

	move.l	#$55555555,d0
	move.l	d3,d6			; Swap 1x2
	move.l	d5,d7
	lsr.l	#1,d6
	lsr.l	#1,d7
	eor.l	d2,d6
	eor.l	d4,d7
	move.l	a6,4(a3)
	and.l	d0,d6
	and.l	d0,d7
	eor.l	d6,d2
	eor.l	d7,d4
	add.l	d6,d6
	add.l	d7,d7
	eor.l	d3,d6
	eor.l	d5,d7

	move.l	d2,a5
	move.l	d4,a6

	not.l	d1
	bmi	.x

	addq.l	#8,a3
	addq.l	#8,a4
	move.l	a3,(a2)+
	move.l	a4,(a2)+
	dbf	d1,.spr
	lea	2(sp),a1
	swap	d1
	dbf	d1,.y

	add.w	#8*4+2,sp
.error
	movem.l	(sp)+,d2-d7/a2-a6
	rts
