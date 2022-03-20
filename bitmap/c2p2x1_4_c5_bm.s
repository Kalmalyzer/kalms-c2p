;
; File:   c2p2x1_4_c5_bm.s
; Author: Mikael Kalms <mikael@kalms.org>
; Date:   30 Aug 2016
; Title:  C2P - 2x1, 4bpl, BitMap output, 020+ optimized
;
; Description:
;   Performs CPU-only C2P conversion
;   Outputs to any 4bpl native BitMap (interlaced, large, ...)
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
;   2016-08-30: Bugfixes
;   2021-03-16: Bugfixes
;

	include	graphics/gfx.i

	section	code,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	offsx [screen-pixels]
; d3.w	offsy [screen-pixels]
; a0	chunkyscreen
; a1	BitMap

	XDEF	_c2p2x1_4_c5_bm
	XDEF	c2p2x1_4_c5_bm
_c2p2x1_4_c5_bm
c2p2x1_4_c5_bm
	movem.l	d2-d7/a2-a6,-(sp)
					; A few sanity checks
	cmpi.b	#4,bm_Depth(a1)		; At least 4 valid bplptrs?
	blo	.exit
	move.w	d0,d4
	move.w	d2,d5
	andi.w	#$f,d4			; Even 16-pixel width?
	bne	.exit
	andi.w	#$7,d5			; Even 8-pixel xoffset?
	bne	.exit
	moveq	#0,d4
	move.w	bm_BytesPerRow(a1),d4

	move.w	d1,d5			; Skip if 0 pixels to convert
	beq	.exit
	swap	d5
	move.w	d0,d5
	beq	.exit

	ext.l	d2			; Offs to first pixel to draw in bpl
	mulu.w	d4,d3
	lsr.l	#3,d2
	add.l	d2,d3

	move.w	d4,d2			; Modulo from one line to the next in destination BitMap
	lsr.w	#2,d0
	sub.w	d0,d2
	bmi	.exit

	movem.l	bm_Planes(a1),a3-a6	; Setup ptrs to bpl0-3
	add.l	d3,a3
	add.l	d3,a4
	add.l	d3,a5
	add.l	d3,a6

	move.w	d2,a1

	move.l	a0,a2			; End of current line in input chunkybuffer
	add.w	d5,a2

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

	lsl.l	#4,d0			; Merge 4x2, part 1a
	lsl.l	#4,d1

	or.l	d2,d0			; Merge 4x2, part 1b
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

	swap	d5
.y
	swap	d5
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

	lsl.l	#4,d0			; Merge 4x2, part 1a
	move.l	d7,(a5)+
	lsl.l	#4,d1

	eor.l	d6,d4			; Dup 1x1, part 2b
	move.l	d4,d7
	eor.l	d6,d4
	add.l	d6,d6
	eor.l	d4,d6

	move.l	d7,(a4)+
	or.l	d2,d0			; Merge 4x2, part 1b
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

	cmp.l	a0,a2
	bhs.w	.x

	add.l	a1,a3
	add.l	a1,a4
	add.l	a1,a5
	add.l	a1,a6
	add.w	d5,a2

	swap	d5
	
	subq.w	#1,d5
	bne .y

.exit
	movem.l	(sp)+,d2-d7/a2-a6
	rts

