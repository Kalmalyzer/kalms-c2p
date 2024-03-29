
;
; Date: 2016-09-01			Mikael Kalms
;					Email: mikael@kalms.org
;
; 1x1 4bpl cpu5 C2P for arbitrary BitMaps
;
; Features:
; Performs CPU-only C2P conversion
; Different routines for non-modulo and modulo C2P conversions
; Handles bitmaps of virtually any size (>4096x4096)
; Position-independent (PC-relative) code
;
; Restrictions:
; Chunky-buffer must be an even multiple of 32 pixels wide
; X-Offset must be set to an even multiple of 8
; If these conditions not are met, the routine will abort.
; If incorrect/invalid parameters are specified, the routine will
; most probably crash.
;
; c2p1x1_4_c5_bm


	include	graphics/gfx.i


			rsreset
C2P1X1_4_C5_BM_CHUNKYX	rs.w	1
C2P1X1_4_C5_BM_CHUNKYY	rs.w	1
C2P1X1_4_C5_BM_ROWMOD	rs.l	1
C2P1X1_4_C5_BM_SIZEOF	rs.b	0


	section	code,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	offsx [screen-pixels]
; d3.w	offsy [screen-pixels]
; a0	chunkyscreen
; a1	BitMap

	XDEF	_c2p1x1_4_c5_bm
	XDEF	c2p1x1_4_c5_bm
_c2p1x1_4_c5_bm
c2p1x1_4_c5_bm
	movem.l	d2-d7/a2-a6,-(sp)
	subq.l	#C2P1X1_4_C5_BM_SIZEOF,sp
					; A few sanity checks
	cmpi.b	#4,bm_Depth(a1)		; At least 4 valid bplptrs?
	blo	.exit
	move.w	d0,d4
	move.w	d2,d5
	andi.w	#$1f,d4			; Even 32-pixel width?
	bne	.exit
	andi.w	#$7,d5			; Even 8-pixel xoffset?
	bne	.exit
	moveq	#0,d4
	move.w	bm_BytesPerRow(a1),d4

	move.w	d0,C2P1X1_4_C5_BM_CHUNKYX(sp) ; Skip if 0 pixels to convert
	beq	.exit
	move.w	d1,C2P1X1_4_C5_BM_CHUNKYY(sp)
	beq	.exit

	ext.l	d2			; Offs to first pixel to draw in bpl
	mulu.w	d4,d3
	lsr.l	#3,d2
	add.l	d2,d3

	lsl.w	#3,d4			; Modulo c2p required?
	sub.w	d0,d4
	bmi	.exit
	bne	.c2p_mod

	mulu.w	d0,d1
	add.l	a0,d1
	move.l	d1,a2			; Ptr to end of chunkybuffer

	movem.l	a0-a1/d3,-(sp)

	movem.l	bm_Planes(a1),a3-a6	; Setup ptrs to bpl0-3
	add.l	d3,a3
	add.l	d3,a4
	add.l	d3,a5
	add.l	d3,a6

	move.l	(a0)+,d0		; Convert lower 4 bpls
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	lsl.l	#4,d0			; Merge 4x1, part 1
	lsl.l	#4,d1
	or.l	d2,d0
	or.l	d3,d1

	move.l	(a0)+,d2
	move.l	(a0)+,d6
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	lsl.l	#4,d2			; Merge 4x1, part 2
	lsl.l	#4,d3
	or.l	d6,d2
	or.l	d7,d3

	move.w	d2,d6			; Swap 16x2
	move.w	d3,d7
	move.w	d0,d2
	move.w	d1,d3
	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d7,d3

	move.l	#$33333333,d4
	move.l	d2,d6			; Swap 2x2
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
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	#$00ff00ff,d4
	move.l	d1,d6			; Swap 8x1
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d2,d7
	bra	.x1start

.x1
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	d7,(a3)+

	lsl.l	#4,d0			; Merge 4x1, part 1
	lsl.l	#4,d1
	or.l	d2,d0
	or.l	d3,d1

	move.l	(a0)+,d2
	move.l	(a0)+,d6
	move.l	(a0)+,d3
	move.l	(a0)+,d7
	move.l	d4,(a4)+

	lsl.l	#4,d2			; Merge 4x1, part 2
	lsl.l	#4,d3
	or.l	d6,d2
	or.l	d7,d3

	move.w	d2,d6			; Swap 16x2
	move.w	d3,d7
	move.w	d0,d2
	move.w	d1,d3
	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d7,d3
	move.l	d5,(a5)+

	move.l	#$33333333,d4
	move.l	d2,d6			; Swap 2x2
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
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	#$00ff00ff,d4
	move.l	d1,d6			; Swap 8x1
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d2,d7
	move.l	a1,(a6)+
.x1start
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d1
	eor.l	d7,d3

	move.l	#$55555555,d4
	move.l	d1,d5			; Swap 1x1
	move.l	d3,d7
	lsr.l	#1,d5
	lsr.l	#1,d7
	eor.l	d0,d5
	eor.l	d2,d7
	and.l	d4,d5
	and.l	d4,d7
	eor.l	d5,d0
	eor.l	d7,d2
	add.l	d5,d5
	add.l	d7,d7
	eor.l	d1,d5
	eor.l	d3,d7

	move.l	d0,a1
	move.l	d2,d4

	cmpa.l	a0,a2
	bne	.x1

	move.l	d7,(a3)+
	move.l	d4,(a4)+
	move.l	d5,(a5)+
	move.l	a1,(a6)+

	movem.l	(sp)+,a0-a1/d3

.exit
	addq.l	#C2P1X1_4_C5_BM_SIZEOF,sp
	movem.l	(sp)+,d2-d7/a2-a6
.earlyexit
	rts

.c2p_mod
	lsr.w	#3,d4
	move.l	d4,C2P1X1_4_C5_BM_ROWMOD(sp) ; Modulo between two rows

	move.l	a0,a2			; Ptr to end of line + 1 iter
	add.w	C2P1X1_4_C5_BM_CHUNKYX(sp),a2
	add.w	#32,a2

	movem.l	a0-a2/d1/d3,-(sp)

	movem.l	bm_Planes(a1),a3-a6	; Setup ptrs to bpl0-3
	add.l	d3,a3
	add.l	d3,a4
	add.l	d3,a5
	add.l	d3,a6

	move.l	(a0)+,d0		; Convert lower 4 bpls
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	lsl.l	#4,d0			; Merge 4x1, part 1
	lsl.l	#4,d1
	or.l	d2,d0
	or.l	d3,d1

	move.l	(a0)+,d2
	move.l	(a0)+,d6
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	lsl.l	#4,d2			; Merge 4x1, part 2
	lsl.l	#4,d3
	or.l	d6,d2
	or.l	d7,d3

	move.w	d2,d6			; Swap 16x2
	move.w	d3,d7
	move.w	d0,d2
	move.w	d1,d3
	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d7,d3

	move.l	#$33333333,d4
	move.l	d2,d6			; Swap 2x2
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
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	#$00ff00ff,d4
	move.l	d1,d6			; Swap 8x1
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d2,d7
	bra	.modx1start
.modx1y
	add.w	C2P1X1_4_C5_BM_CHUNKYX+20(sp),a2 ; Skip to end of next
						 ; line + 1 iter
	move.l	C2P1X1_4_C5_BM_ROWMOD+20(sp),d0  ; Skip to beginning of
	add.l	d0,a3				 ; next line
	add.l	d0,a4
	add.l	d0,a5
	add.l	d0,a6
.modx1
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	d7,(a3)+

	lsl.l	#4,d0			; Merge 4x1, part 1
	lsl.l	#4,d1
	or.l	d2,d0
	or.l	d3,d1

	move.l	(a0)+,d2
	move.l	(a0)+,d6
	move.l	(a0)+,d3
	move.l	(a0)+,d7
	move.l	d4,(a4)+

	lsl.l	#4,d2			; Merge 4x1, part 2
	lsl.l	#4,d3
	or.l	d6,d2
	or.l	d7,d3

	move.w	d2,d6			; Swap 16x2
	move.w	d3,d7
	move.w	d0,d2
	move.w	d1,d3
	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d7,d3
	move.l	d5,(a5)+

	move.l	#$33333333,d4
	move.l	d2,d6			; Swap 2x2
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
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	#$00ff00ff,d4
	move.l	d1,d6			; Swap 8x1
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d2,d7
	move.l	a1,(a6)+
.modx1start
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d1
	eor.l	d7,d3

	move.l	#$55555555,d4
	move.l	d1,d5			; Swap 1x1
	move.l	d3,d7
	lsr.l	#1,d5
	lsr.l	#1,d7
	eor.l	d0,d5
	eor.l	d2,d7
	and.l	d4,d5
	and.l	d4,d7
	eor.l	d5,d0
	eor.l	d7,d2
	add.l	d5,d5
	add.l	d7,d7
	eor.l	d1,d5
	eor.l	d3,d7

	move.l	d0,a1
	move.l	d2,d4

	cmpa.l	a0,a2
	bne	.modx1

	subq.w	#1,C2P1X1_4_C5_BM_CHUNKYY+20(sp)
	bne	.modx1y

	movem.l	(sp)+,a0-a2/d1/d3

	move.w	d1,C2P1X1_4_C5_BM_CHUNKYY(sp)

	bra	.exit

