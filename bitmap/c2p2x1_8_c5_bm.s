;
; File:   c2p2x1_8_c5_bm.s
; Author: Mikael Kalms <mikael@kalms.org>
; Date:   29 Aug 2016
; Title:  C2P - 2x1, 8bpl, BitMap output, 020+ optimized
;
; Description:
;   Performs CPU-only C2P conversion
;   Outputs to any 8bpl native BitMap (interlaced, large, ...)
;   Position-independent (PC-relative), reentrant code
;   No selfmodifying code used
;   For best performance, align chunkybuffer on even 16byte boundary
;     and destination window on even 4byte boundary
;
; Restrictions:
;   Chunky-buffer must be an even multiple of 16 pixels wide
;   X-Offset must be set to an even multiple of 8
;
; History:
;   2016-08-29: Initial version
;

	xdef	_c2p2x1_8_c5_bm
	xdef	c2p2x1_8_c5_bm

	incdir	include:
	include	graphics/gfx.i


				rsreset
C2P2X1_8_C5_BM_BITMAPDELTA0	rs.l	1
C2P2X1_8_C5_BM_BITMAPDELTA1	rs.l	1
C2P2X1_8_C5_BM_BITMAPDELTA2	rs.l	1
C2P2X1_8_C5_BM_BITMAPDELTA3	rs.l	1
C2P2X1_8_C5_BM_BITMAPDELTA4	rs.l	1
C2P2X1_8_C5_BM_BITMAPDELTA5	rs.l	1
C2P2X1_8_C5_BM_BITMAPDELTA6	rs.l	1
C2P2X1_8_C5_BM_BITMAPDELTA7	rs.l	1
C2P2X1_8_C5_BM_CHUNKYDELTA0	rs.l	1
C2P2X1_8_C5_BM_CHUNKYDELTA1	rs.l	1
C2P2X1_8_C5_BM_CHUNKYDELTA2	rs.l	1
C2P2X1_8_C5_BM_LOOPY		rs.w	1
C2P2X1_8_C5_BM_CHUNKYX		rs.w	1
C2P2X1_8_C5_BM_CHUNKYY		rs.w	1
				rs.w	1
C2P2X1_8_C5_BM_ORIGSP		rs.l	1
C2P2X1_8_C5_BM_SIZEOF		rs.b	0


	section	code,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	offsx [screen-pixels]
; d3.w	offsy [screen-pixels]
; a0	chunkyscreen
; a1	BitMap

_c2p2x1_8_c5_bm
c2p2x1_8_c5_bm
	movem.l	d2-d7/a2-a6,-(sp)
	move.l	sp,a2
	sub.w	#C2P2X1_8_C5_BM_SIZEOF,sp
	move.l	sp,d4
	and.b	#$f0,d4
	move.l	d4,sp
	move.l	a2,C2P2X1_8_C5_BM_ORIGSP(sp)

					; A few sanity checks
	cmpi.b	#8,bm_Depth(a1)		; At least 8 valid bplptrs?
	blo	.exit
	move.w	d0,d4
	move.w	d2,d5
	andi.w	#$f,d4			; Even 16-pixel width?
	bne	.exit
	andi.w	#$7,d5			; Even 8-pixel xoffset?
	bne	.exit
	moveq	#0,d4
	move.w	bm_BytesPerRow(a1),d4

	move.w	d0,C2P2X1_8_C5_BM_CHUNKYX(sp) ; Skip if 0 pixels to convert
	beq	.exit
	move.w	d1,C2P2X1_8_C5_BM_CHUNKYY(sp)
	beq	.exit

	ext.l	d2			; Offs to first pixel to draw in bpl
	mulu.w	d4,d3
	lsr.l	#3,d2
	add.l	d2,d3

	move.w	bm_BytesPerRow(a1),d2	; Modulo from one line to the next
	lsr.w	#2,d0
	sub.w	d0,d2
	bmi	.exit

	clr.l	C2P2X1_8_C5_BM_CHUNKYDELTA0(sp)
	moveq	#0,d0
	move.w	C2P2X1_8_C5_BM_CHUNKYX(sp),d0
	move.l	d0,C2P2X1_8_C5_BM_CHUNKYDELTA2(sp)
	neg.l	d0
	move.l	d0,C2P2X1_8_C5_BM_CHUNKYDELTA1(sp)

	movem.l	bm_Planes(a1),d5/d7/a4/a6
	movem.l	bm_Planes+4*4(a1),d4/d6/a3/a5
	sub.l	bm_Planes+0*4(a1),d4
	sub.l	bm_Planes+1*4(a1),d6
	sub.l	bm_Planes+2*4(a1),a3
	sub.l	bm_Planes+3*4(a1),a5
	sub.l	bm_Planes+4*4(a1),d5
	sub.l	bm_Planes+5*4(a1),d7
	sub.l	bm_Planes+6*4(a1),a4
	sub.l	bm_Planes+7*4(a1),a6
	moveq	#0,d0
	move.w	C2P2X1_8_C5_BM_CHUNKYX(sp),d0
	lsr.w	#2,d0
	sub.l	d0,d4
	sub.l	d0,d6
	sub.l	d0,a3
	sub.l	d0,a5
	ext.l	d2
	add.l	d2,d5
	add.l	d2,d7
	add.l	d2,a4
	add.l	d2,a6
	movem.l	d4-d7/a3-a6,C2P2X1_8_C5_BM_BITMAPDELTA0(sp)

	move.w	C2P2X1_8_C5_BM_CHUNKYY(sp),d0
	add.w	d0,d0
	move.w	d0,C2P2X1_8_C5_BM_LOOPY(sp)

	movem.l	bm_Planes(a1),a3-a6	; Setup ptrs to bpl0-3
	add.l	d3,a3
	add.l	d3,a4
	add.l	d3,a5
	add.l	d3,a6

	moveq	#4,d5

	move.w	C2P2X1_8_C5_BM_CHUNKYX(sp),a2
	add.l	a0,a2

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	swap	d2			; Swap 16x2
	swap	d3
	eor.w	d0,d2
	eor.w	d1,d3
	eor.w	d2,d0
	eor.w	d3,d1
	eor.w	d0,d2
	eor.w	d1,d3
	swap	d2
	swap	d3

	move.l	d4,d6			; Dup 1x1, part 2a
	lsr.l	#1,d6
	eor.l	d4,d6
	and.l	#$55555555,d6

	lsl.l	d5,d0			; Merge 4x2, part 1a
	lsl.l	d5,d1
	swap	d5
	lsr.l	d5,d2
	lsr.l	d5,d3

	eor.l	d6,d4			; Dup 1x1, part 2b
	move.l	d4,d7
	eor.l	d6,d4
	add.l	d6,d6
	eor.l	d4,d6

	move.l	#$0f0f0f0f,d4		; Merge 4x2, part 1b
	and.l	d4,d2
	and.l	d4,d3
	not.l	d4
	and.l	d4,d0
	and.l	d4,d1
	or.l	d2,d0
	or.l	d3,d1

	move.l	d1,d4			; Swap 8x1
	lsr.l	#8,d4
	eor.l	d0,d4
	and.l	#$00ff00ff,d4
	eor.l	d4,d0
	lsl.l	#8,d4
	eor.l	d4,d1

	move.l	d1,d4			; Swap 2x1
	lsr.l	#2,d4
	eor.l	d0,d4
	and.l	#$33333333,d4
	eor.l	d4,d0
	lsl.l	#2,d4
	eor.l	d1,d4

	move.l	d0,d7			; Dup 1x1, part 1
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	#$55555555,d7
	eor.l	d7,d0
	move.l	d0,d6
	eor.l	d7,d0
	add.l	d7,d7
	eor.l	d0,d7

	swap	d5			; Merge 4x2, part 1c

	bra	.xstart
.y
	add.l	C2P2X1_8_C5_BM_BITMAPDELTA0(sp,d5.w),a3
	add.l	C2P2X1_8_C5_BM_BITMAPDELTA2(sp,d5.w),a4
	add.l	C2P2X1_8_C5_BM_BITMAPDELTA4(sp,d5.w),a5
	add.l	C2P2X1_8_C5_BM_BITMAPDELTA6(sp,d5.w),a6
	add.l	C2P2X1_8_C5_BM_CHUNKYDELTA2(sp),a2

	subq.w	#1,C2P2X1_8_C5_BM_LOOPY(sp)
	beq	.done
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	move.l	d6,(a6)+
	swap	d2			; Swap 16x2
	swap	d3
	eor.w	d0,d2
	eor.w	d1,d3
	eor.w	d2,d0
	eor.w	d3,d1
	eor.w	d0,d2
	eor.w	d1,d3
	swap	d2
	swap	d3

	move.l	d4,d6			; Dup 1x1, part 2a
	lsr.l	#1,d6
	eor.l	d4,d6
	and.l	#$55555555,d6

	lsl.l	d5,d0			; Merge 4x2, part 1a
	move.l	d7,(a5)+
	lsl.l	d5,d1
	swap	d5
	lsr.l	d5,d2
	lsr.l	d5,d3

	eor.l	d6,d4			; Dup 1x1, part 2b
	move.l	d4,d7
	eor.l	d6,d4
	add.l	d6,d6
	eor.l	d4,d6

	move.l	#$0f0f0f0f,d4		; Merge 4x2, part 1b
	and.l	d4,d2
	and.l	d4,d3
	not.l	d4
	and.l	d4,d0
	move.l	d7,(a4)+
	and.l	d4,d1
	or.l	d2,d0
	or.l	d3,d1

	move.l	d1,d4			; Swap 8x1
	lsr.l	#8,d4
	eor.l	d0,d4
	and.l	#$00ff00ff,d4
	eor.l	d4,d0
	lsl.l	#8,d4
	eor.l	d4,d1

	move.l	d1,d4			; Swap 2x1
	lsr.l	#2,d4
	eor.l	d0,d4
	and.l	#$33333333,d4
	eor.l	d4,d0
	move.l	d6,(a3)+
	lsl.l	#2,d4
	eor.l	d1,d4

	move.l	d0,d7			; Dup 1x1, part 1
	lsr.l	#1,d7
	eor.l	d0,d7
	and.l	#$55555555,d7
	eor.l	d7,d0
	move.l	d0,d6
	eor.l	d7,d0
	add.l	d7,d7
	eor.l	d0,d7

	swap	d5			; Merge 4x2, part 1c
.xstart

	cmp.l	a0,a2
	bhi.w	.x
	blo.w	.y
	add.l	C2P2X1_8_C5_BM_CHUNKYDELTA0(sp,d5.w),a0
	swap	d5
	move.l	a0,a2
	bra.w	.x
.xend
.done
.exit
	move.l	C2P2X1_8_C5_BM_ORIGSP(sp),sp
	movem.l	(sp)+,d2-d7/a2-a6
	rts

