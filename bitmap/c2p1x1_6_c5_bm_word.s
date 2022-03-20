
;
; Date: 2022-03-20			Mikael Kalms
;					Email: mikael@kalms.org
;
; 1x1 6bpl cpu5 C2P for arbitrary BitMaps
; Word writes to chipmem, good for OCS/ECS machines
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
; c2p1x1_6_c5_bm_word


	include	graphics/gfx.i


			rsreset
C2P1X1_6_C5_BM_WORD_CHUNKYX	rs.w	1
C2P1X1_6_C5_BM_WORD_CHUNKYY	rs.w	1
C2P1X1_6_C5_BM_WORD_ROWMOD	rs.l	1
C2P1X1_6_C5_BM_WORD_SIZEOF	rs.b	0


	section	code,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	offsx [screen-pixels]
; d3.w	offsy [screen-pixels]
; a0	chunkyscreen
; a1	BitMap

	XDEF	_c2p1x1_6_c5_bm_word
	XDEF	c2p1x1_6_c5_bm_word
_c2p1x1_6_c5_bm_word
c2p1x1_6_c5_bm_word
	movem.l	d2-d7/a2-a6,-(sp)
	subq.l	#C2P1X1_6_C5_BM_WORD_SIZEOF,sp
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

	move.w	d0,C2P1X1_6_C5_BM_WORD_CHUNKYX(sp) ; Skip if 0 pixels to convert
	beq	.exit
	move.w	d1,C2P1X1_6_C5_BM_WORD_CHUNKYY(sp)
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

	; Convert bpl0-3

	movem.l	bm_Planes(a1),a3-a6	; Setup ptrs to bpl0-3
	add.l	d3,a3
	add.l	d3,a4
	add.l	d3,a5
	add.l	d3,a6

	move.l	#$0f0f0f0f,d4
	move.l	#$00ff00ff,d5

	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3
	lsl.l	#4,d0
	lsl.l	#4,d1
	or.l	d2,d0
	or.l	d3,d1

; a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0
; i3i2i1i0m3m2m1m0 j3j2j1j0n3n2n1n0 k3k2k1k0o3o2o1o0 l3l2l1l0p3p2p1p0

	move.l	d1,d2
	lsr.l	#8,d2
	eor.l	d0,d2
	and.l	d5,d2
	eor.l	d2,d0
	lsl.l	#8,d2
	eor.l	d2,d1

; a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
; b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0

	move.l	d1,d2
	lsr.l	#1,d2
	eor.l	d0,d2
	and.l	#$55555555,d2
	eor.l	d2,d0
	add.l	d2,d2
	eor.l	d2,d1

; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1
; a2b2a0b0e2f2f0f0 i2j2i0j0m2n2m0n0 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.w	d1,d2
	move.w	d0,d1
	swap	d1
	move.w	d1,d0
	move.w	d2,d1

; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 a2b2a0b0e2f2f0f0 i2j2i0j0m2n2m0n0
; c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.l	d1,d2

	bra	.x1start

.x1
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	move.w	d6,(a5)+
	swap	d6

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3
	lsl.l	#4,d0
	lsl.l	#4,d1
	or.l	d2,d0
	or.l	d3,d1

; a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0
; i3i2i1i0m3m2m1m0 j3j2j1j0n3n2n1n0 k3k2k1k0o3o2o1o0 l3l2l1l0p3p2p1p0

	move.w	d7,(a3)+
	swap	d7

	move.l	d1,d2
	lsr.l	#8,d2
	eor.l	d0,d2
	and.l	d5,d2
	eor.l	d2,d0
	lsl.l	#8,d2
	eor.l	d2,d1

; a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
; b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0

	move.l	d1,d2
	lsr.l	#1,d2

	move.w	d6,(a6)+

	eor.l	d0,d2
	and.l	#$55555555,d2
	eor.l	d2,d0
	add.l	d2,d2
	eor.l	d2,d1

; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1
; a2b2a0b0e2f2f0f0 i2j2i0j0m2n2m0n0 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.w	d1,d2
	move.w	d0,d1
	swap	d1
	move.w	d1,d0
	move.w	d2,d1

; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 a2b2a0b0e2f2f0f0 i2j2i0j0m2n2m0n0
; c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.l	d1,d2

	move.w	d7,(a4)+
.x1start
	lsr.l	#2,d2
	eor.l	d0,d2
	and.l	#$33333333,d2
	eor.l	d2,d0
	lsl.l	#2,d2
	eor.l	d2,d1

; a3b3c3d3e3f3g3h3 i3j3k3l3m3n3o3p3 a2b2c2d2e2f2g2h2 i2j2k2l2m2n2o2p2
; a1b1c1d1e1f1g1h1 i1j1k1l1m1n1o1p1 a0b0c0d0e0f0g0h0 i0j0k0l0m0n0o0p0

	move.l	d0,d6
	move.l	d1,d7

	cmpa.l	a0,a2
	bne	.x1

	move.w	d6,(a5)+
	swap	d6
	move.w	d7,(a3)+
	swap	d7
	move.w	d6,(a6)+
	move.w	d7,(a4)+

	movem.l	(sp)+,a0-a1/d3

	; Convert bpl4-5

	movem.l	bm_Planes+4*4(a1),a3-a4	; Setup ptrs to bpl4-5
	add.l	d3,a3
	add.l	d3,a4

	move.l	#$f0f0f0f0,d4

	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3
	lsr.l	#4,d2
	lsr.l	#4,d3
	or.l	d2,d0
	or.l	d3,d1

	move.l	(a0)+,d2
	move.l	(a0)+,d6
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	and.l	d4,d2
	and.l	d4,d3
	and.l	d4,d6
	and.l	d4,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	or.l	d6,d2
	or.l	d7,d3

; ----a5a4----e5e4 ----b5b4----f5f4 ----c5c4----g5g4 ----d5d4----h5h4
; ----i5i4----m5m4 ----j5j4----n5n4 ----k5k4----o5o4 ----l5l4----p5p4
; ----q5q4----u5u4 ----r5r4----v5v4 ----s5s4----w5w4 ----t5t4----x5x4
; ----y5y4----C5C4 ----z5z4----D5D4 ----A5A4----E5E4 ----B5B4----F5F4

	move.w	d2,d6
	move.w	d3,d7
	move.w	d0,d2
	move.w	d1,d3

	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d7,d3

; ----a5a4----e5e4 ----b5b4----f5f4 ----q5q4----u5u4 ----r5r4----v5v4
; ----i5i4----m5m4 ----j5j4----n5n4 ----y5y4----C5C4 ----z5z4----D5D4
; ----c5c4----g5g4 ----d5d4----h5h4 ----s5s4----w5w4 ----t5t4----x5x4
; ----k5k4----o5o4 ----l5l4----p5p4 ----A5A4----E5E4 ----B5B4----F5F4

	lsl.l	#2,d0
	lsl.l	#2,d1
	or.l	d2,d0
	or.l	d3,d1
	
; a5a4c5c4e5e4g5g4 b5b4d5d4f5f4h5h4 q5q4s5s4u5u4w5w4 r5r4t5t4v5v4x5x4
; i5i4k5k4m5m4o5o4 j5j4l5l4n5n4p5p4 y5y4A5A4C5C4E5E4 z5z4B5B4D5D4F5F4

	move.l	d1,d2
	lsr.l	#8,d2
	eor.l	d0,d2
	and.l	#$00ff00ff,d2
	eor.l	d2,d0

	bra	.x2start
.x2
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	move.w	d6,(a4)+

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3
	lsr.l	#4,d2
	lsr.l	#4,d3
	or.l	d2,d0
	or.l	d3,d1

	move.l	(a0)+,d2
	move.l	(a0)+,d6
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	move.w	a5,(a4)+

	and.l	d4,d2
	and.l	d4,d3
	and.l	d4,d6
	and.l	d4,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	or.l	d6,d2
	or.l	d7,d3

; ----a5a4----e5e4 ----b5b4----f5f4 ----c5c4----g5g4 ----d5d4----h5h4
; ----i5i4----m5m4 ----j5j4----n5n4 ----k5k4----o5o4 ----l5l4----p5p4
; ----q5q4----u5u4 ----r5r4----v5v4 ----s5s4----w5w4 ----t5t4----x5x4
; ----y5y4----C5C4 ----z5z4----D5D4 ----A5A4----E5E4 ----B5B4----F5F4

	move.w	d2,d6
	move.w	d3,d7
	move.w	d0,d2
	move.w	d1,d3

	move.w	d5,(a3)+
	swap	d5

	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d7,d3

; ----a5a4----e5e4 ----b5b4----f5f4 ----q5q4----u5u4 ----r5r4----v5v4
; ----i5i4----m5m4 ----j5j4----n5n4 ----y5y4----C5C4 ----z5z4----D5D4
; ----c5c4----g5g4 ----d5d4----h5h4 ----s5s4----w5w4 ----t5t4----x5x4
; ----k5k4----o5o4 ----l5l4----p5p4 ----A5A4----E5E4 ----B5B4----F5F4

	lsl.l	#2,d0
	lsl.l	#2,d1
	or.l	d2,d0
	or.l	d3,d1
	
; a5a4c5c4e5e4g5g4 b5b4d5d4f5f4h5h4 q5q4s5s4u5u4w5w4 r5r4t5t4v5v4x5x4
; i5i4k5k4m5m4o5o4 j5j4l5l4n5n4p5p4 y5y4A5A4C5C4E5E4 z5z4B5B4D5D4F5F4

	move.l	d1,d2
	lsr.l	#8,d2
	eor.l	d0,d2
	and.l	#$00ff00ff,d2
	eor.l	d2,d0
	move.w	d5,(a3)+
.x2start
	lsl.l	#8,d2
	eor.l	d2,d1

; a5a4c5c4e5e4g5g4 i5i4k5k4m5m4o5o4 q5q4s5s4u5u4w5w4 y5y4A5A4C5C4E5E4
; b5b4d5d4f5f4h5h4 j5j4l5l4n5n4p5p4 r5r4t5t4v5v4x5x4 z5z4B5B4D5D4F5F4

	move.l	d1,d5
	lsr.l	#1,d5
	eor.l	d0,d5
	and.l	#$55555555,d5
	eor.l	d5,d0
	add.l	d5,d5
	eor.l	d1,d5

; a5b5c5d5e5f5g5h5 i5jik5l5m5n5o5p5 q5r5s5t5u5v5w5x5 y5z5A5B5C5D5E5F5
; a4b4c4d4e4f4g4h4 i4jik4l4m4n4o4p4 q4r4s4t4u4v4w4x4 y4z4A4B4C4D4E4F4

	move.l	d0,d6
	move.l	d6,a5
	swap	d6
	swap	d5

	cmpa.l	a0,a2
	bne	.x2

	move.w	d6,(a4)+
	move.w	a5,(a4)+
	move.w	d5,(a3)+
	swap	d5
	move.w	d5,(a3)+

.exit
	addq.l	#C2P1X1_6_C5_BM_WORD_SIZEOF,sp
	movem.l	(sp)+,d2-d7/a2-a6
.earlyexit
	rts

.c2p_mod
	lsr.w	#3,d4
	move.l	d4,C2P1X1_6_C5_BM_WORD_ROWMOD(sp) ; Modulo between two rows

	move.l	a0,a2			; Ptr to end of line + 1 iter
	add.w	C2P1X1_6_C5_BM_WORD_CHUNKYX(sp),a2
	add.w	#16,a2

	movem.l	a0-a2/d1/d3,-(sp)

	movem.l	bm_Planes(a1),a3-a6	; Setup ptrs to bpl0-3
	add.l	d3,a3
	add.l	d3,a4
	add.l	d3,a5
	add.l	d3,a6

	move.l	#$0f0f0f0f,d4
	move.l	#$00ff00ff,d5

	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3
	lsl.l	#4,d0
	lsl.l	#4,d1
	or.l	d2,d0
	or.l	d3,d1

; a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0
; i3i2i1i0m3m2m1m0 j3j2j1j0n3n2n1n0 k3k2k1k0o3o2o1o0 l3l2l1l0p3p2p1p0

	move.l	d1,d2
	lsr.l	#8,d2
	eor.l	d0,d2
	and.l	d5,d2
	eor.l	d2,d0
	lsl.l	#8,d2
	eor.l	d2,d1

; a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
; b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0

	move.l	d1,d2
	lsr.l	#1,d2
	eor.l	d0,d2
	and.l	#$55555555,d2
	eor.l	d2,d0
	add.l	d2,d2
	eor.l	d2,d1

; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1
; a2b2a0b0e2f2f0f0 i2j2i0j0m2n2m0n0 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.w	d1,d2
	move.w	d0,d1
	swap	d1
	move.w	d1,d0
	move.w	d2,d1

; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 a2b2a0b0e2f2f0f0 i2j2i0j0m2n2m0n0
; c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.l	d1,d2
	bra	.modx1start
.modx1y
	add.w	C2P1X1_6_C5_BM_WORD_CHUNKYX+20(sp),a2 ; Skip to end of next
						 ; line + 1 iter
	move.l	C2P1X1_6_C5_BM_WORD_ROWMOD+20(sp),d0  ; Skip to beginning of
	add.l	d0,a3				 ; next line
	add.l	d0,a4
	add.l	d0,a5
	add.l	d0,a6
.modx1
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	move.w	d6,(a5)+
	swap	d6

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3
	lsl.l	#4,d0
	lsl.l	#4,d1
	or.l	d2,d0
	or.l	d3,d1

; a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0
; i3i2i1i0m3m2m1m0 j3j2j1j0n3n2n1n0 k3k2k1k0o3o2o1o0 l3l2l1l0p3p2p1p0

	move.w	d7,(a3)+
	swap	d7

	move.l	d1,d2
	lsr.l	#8,d2
	eor.l	d0,d2
	and.l	d5,d2
	eor.l	d2,d0
	lsl.l	#8,d2
	eor.l	d2,d1

; a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0
; b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0

	move.l	d1,d2
	lsr.l	#1,d2

	move.w	d6,(a6)+

	eor.l	d0,d2
	and.l	#$55555555,d2
	eor.l	d2,d0
	add.l	d2,d2
	eor.l	d2,d1

; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1
; a2b2a0b0e2f2f0f0 i2j2i0j0m2n2m0n0 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.w	d1,d2
	move.w	d0,d1
	swap	d1
	move.w	d1,d0
	move.w	d2,d1

; a3b3a1b1e3f3e1f1 i3j3i1j1m3n3m1n1 a2b2a0b0e2f2f0f0 i2j2i0j0m2n2m0n0
; c3d3c1d1g3h3g1h1 k3l3k1l1o3p3o1p1 c2d2c0d0g2h2g0h0 k2l2k0l0o2p2o0p0

	move.l	d1,d2

	move.w	d7,(a4)+
.modx1start
	lsr.l	#2,d2
	eor.l	d0,d2
	and.l	#$33333333,d2
	eor.l	d2,d0
	lsl.l	#2,d2
	eor.l	d2,d1

; a3b3c3d3e3f3g3h3 i3j3k3l3m3n3o3p3 a2b2c2d2e2f2g2h2 i2j2k2l2m2n2o2p2
; a1b1c1d1e1f1g1h1 i1j1k1l1m1n1o1p1 a0b0c0d0e0f0g0h0 i0j0k0l0m0n0o0p0

	move.l	d0,d6
	move.l	d1,d7

	cmpa.l	a0,a2
	bne	.modx1

	subq.w	#1,C2P1X1_6_C5_BM_WORD_CHUNKYY+20(sp)
	bne	.modx1y

	movem.l	(sp)+,a0-a2/d1/d3

	move.w	d1,C2P1X1_6_C5_BM_WORD_CHUNKYY(sp)

	add.w	#16,a2

	movem.l	bm_Planes+4*4(a1),a3-a4	; Setup ptrs to bpl4-5
	add.l	d3,a3
	add.l	d3,a4

	move.l	#$f0f0f0f0,d4

	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3
	lsr.l	#4,d2
	lsr.l	#4,d3
	or.l	d2,d0
	or.l	d3,d1

	move.l	(a0)+,d2
	move.l	(a0)+,d6
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	and.l	d4,d2
	and.l	d4,d3
	and.l	d4,d6
	and.l	d4,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	or.l	d6,d2
	or.l	d7,d3

; ----a5a4----e5e4 ----b5b4----f5f4 ----c5c4----g5g4 ----d5d4----h5h4
; ----i5i4----m5m4 ----j5j4----n5n4 ----k5k4----o5o4 ----l5l4----p5p4
; ----q5q4----u5u4 ----r5r4----v5v4 ----s5s4----w5w4 ----t5t4----x5x4
; ----y5y4----C5C4 ----z5z4----D5D4 ----A5A4----E5E4 ----B5B4----F5F4

	move.w	d2,d6
	move.w	d3,d7
	move.w	d0,d2
	move.w	d1,d3

	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d7,d3

; ----a5a4----e5e4 ----b5b4----f5f4 ----q5q4----u5u4 ----r5r4----v5v4
; ----i5i4----m5m4 ----j5j4----n5n4 ----y5y4----C5C4 ----z5z4----D5D4
; ----c5c4----g5g4 ----d5d4----h5h4 ----s5s4----w5w4 ----t5t4----x5x4
; ----k5k4----o5o4 ----l5l4----p5p4 ----A5A4----E5E4 ----B5B4----F5F4

	lsl.l	#2,d0
	lsl.l	#2,d1
	or.l	d2,d0
	or.l	d3,d1
	
; a5a4c5c4e5e4g5g4 b5b4d5d4f5f4h5h4 q5q4s5s4u5u4w5w4 r5r4t5t4v5v4x5x4
; i5i4k5k4m5m4o5o4 j5j4l5l4n5n4p5p4 y5y4A5A4C5C4E5E4 z5z4B5B4D5D4F5F4

	move.l	d1,d2
	lsr.l	#8,d2
	eor.l	d0,d2
	and.l	#$00ff00ff,d2
	eor.l	d2,d0
	bra	.modx2start
.modx2y
	add.w	C2P1X1_6_C5_BM_WORD_CHUNKYX(sp),a2 ; Skip to end of next
						 ; line + 1 iter
	move.l	C2P1X1_6_C5_BM_WORD_ROWMOD(sp),d0  ; Skip to beginning of
	add.l	d0,a3				 ; next line
	add.l	d0,a4
.modx2
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3

	move.w	d6,(a4)+

	and.l	d4,d0
	and.l	d4,d1
	and.l	d4,d2
	and.l	d4,d3
	lsr.l	#4,d2
	lsr.l	#4,d3
	or.l	d2,d0
	or.l	d3,d1

	move.l	(a0)+,d2
	move.l	(a0)+,d6
	move.l	(a0)+,d3
	move.l	(a0)+,d7

	move.w	a5,(a4)+

	and.l	d4,d2
	and.l	d4,d3
	and.l	d4,d6
	and.l	d4,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	or.l	d6,d2
	or.l	d7,d3

; ----a5a4----e5e4 ----b5b4----f5f4 ----c5c4----g5g4 ----d5d4----h5h4
; ----i5i4----m5m4 ----j5j4----n5n4 ----k5k4----o5o4 ----l5l4----p5p4
; ----q5q4----u5u4 ----r5r4----v5v4 ----s5s4----w5w4 ----t5t4----x5x4
; ----y5y4----C5C4 ----z5z4----D5D4 ----A5A4----E5E4 ----B5B4----F5F4

	move.w	d2,d6
	move.w	d3,d7
	move.w	d0,d2
	move.w	d1,d3

	move.w	d5,(a3)+
	swap	d5

	swap	d2
	swap	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d6,d2
	move.w	d7,d3

; ----a5a4----e5e4 ----b5b4----f5f4 ----q5q4----u5u4 ----r5r4----v5v4
; ----i5i4----m5m4 ----j5j4----n5n4 ----y5y4----C5C4 ----z5z4----D5D4
; ----c5c4----g5g4 ----d5d4----h5h4 ----s5s4----w5w4 ----t5t4----x5x4
; ----k5k4----o5o4 ----l5l4----p5p4 ----A5A4----E5E4 ----B5B4----F5F4

	lsl.l	#2,d0
	lsl.l	#2,d1
	or.l	d2,d0
	or.l	d3,d1
	
; a5a4c5c4e5e4g5g4 b5b4d5d4f5f4h5h4 q5q4s5s4u5u4w5w4 r5r4t5t4v5v4x5x4
; i5i4k5k4m5m4o5o4 j5j4l5l4n5n4p5p4 y5y4A5A4C5C4E5E4 z5z4B5B4D5D4F5F4

	move.l	d1,d2
	lsr.l	#8,d2
	eor.l	d0,d2
	and.l	#$00ff00ff,d2
	eor.l	d2,d0
	move.w	d5,(a3)+
.modx2start
	lsl.l	#8,d2
	eor.l	d2,d1

; a5a4c5c4e5e4g5g4 i5i4k5k4m5m4o5o4 q5q4s5s4u5u4w5w4 y5y4A5A4C5C4E5E4
; b5b4d5d4f5f4h5h4 j5j4l5l4n5n4p5p4 r5r4t5t4v5v4x5x4 z5z4B5B4D5D4F5F4

	move.l	d1,d5
	lsr.l	#1,d5
	eor.l	d0,d5
	and.l	#$55555555,d5
	eor.l	d5,d0
	add.l	d5,d5
	eor.l	d1,d5

; a5b5c5d5e5f5g5h5 i5jik5l5m5n5o5p5 q5r5s5t5u5v5w5x5 y5z5A5B5C5D5E5F5
; a4b4c4d4e4f4g4h4 i4jik4l4m4n4o4p4 q4r4s4t4u4v4w4x4 y4z4A4B4C4D4E4F4

	move.l	d0,d6
	move.l	d6,a5
	swap	d6
	swap	d5

	cmpa.l	a0,a2
	bne	.modx2

	subq.w	#1,C2P1X1_6_C5_BM_WORD_CHUNKYY(sp)
	bne	.modx2y

	bra	.exit

