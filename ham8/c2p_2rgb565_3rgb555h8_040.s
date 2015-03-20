;
; Date: 1999-02-06			Mikael Kalms (Scout/C-Lous & more)
;					Email: mikael@kalms.org
;
; About:
;   2byte RGB565 -> 3pixel RGB555 HAM8 C2P for contigous
;   bitplanes with modulo
;
;   This routine is intended for use on all 68040 and 68060 based systems.
;   It is not designed to perform well on 68020-030.
;
;   This routine is released into the public domain. It may be freely used
;   for non-commercial as well as commercial purposes. A short notice via
;   email is always appreciated, though.
;
;   For best conversion speed, bitplane start and row modulo should be
;   evenly divisible by 4; starting X should be evenly divisible by 32.
;   (Don't open screens which are n+16 pixels wide! Do n+32 or n+64 instead)
;
;   Bitplane data for control bitplane 0: $6db6db6d
;   Bitplane data for control bitplane 1: $db6db6db
;
;   Chunky-buffer will be converted in 11-chunkypixel runs.
;   Each run will output 32 bitplane-pixels (which means that the last
;   pixel will only get RG components set on-screen, but that's no big deal).
;
; Timings:
;
; Features:
;   Handles bitplanes of virtually any size (4GB)
;   Modulo support
;
; Restrictions:
;   If a modulo-11 chunkywidth is specified, the extraneous pixels will
;   be skipped.
;   If incorrect/invalid parameters are specified, the routine will
;   most probably crash.
;
; c2p_2rgb565_3rgb555h8_040_init	sets screen & chunkybuffer parameters
; c2p_2rgb565_3rgb555h8_040		performs the actual c2p conversion
;

	section	code,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	scroffsx [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.l	rowlen [bytes] -- offset between one row and the next in a bpl
; d5.l	bplsize [bytes] -- offset between one row in one bpl and the next bpl
; d6.l	chunkylen [bytes] -- offset between one row and the next in chunkybuf

_c2p_2rgb565_3rgb555h8_040_init
c2p_2rgb565_3rgb555h8_040_init
	movem.l	d2-d6,-(sp)
	and.l	#$ffff,d0
	divu.l	#11,d0
	move.l	d1,c2p_2rgb565_3rgb555h8_040_chunkyy
	move.l	d0,d1
	mulu.w	#11*2,d0
	move.l	d6,c2p_2rgb565_3rgb555h8_040_chunkymod
	move.l	d0,c2p_2rgb565_3rgb555h8_040_chunkyxlen
	sub.l	d0,d6
	move.l	d6,c2p_2rgb565_3rgb555h8_040_chunkyminimod
	move.l	d5,c2p_2rgb565_3rgb555h8_040_bplsize
	and.l	#$ffe0,d2
	and.l	#$ffff,d3
	lsr.l	#3,d2
	mulu.l	d4,d3
	add.l	d2,d3
	move.l	d3,c2p_2rgb565_3rgb555h8_040_scroffs
	lsl.l	#2,d1
	sub.l	d1,d4
	move.l	d4,c2p_2rgb565_3rgb555h8_040_bplmod
	movem.l	(sp)+,d2-d6
	rts

; a0	chunkybuffer
; a1	bitplanes

_c2p_2rgb565_3rgb555h8_040
c2p_2rgb565_3rgb555h8_040

	movem.l	d2-d7/a2-a6,-(sp)

	move.l	c2p_2rgb565_3rgb555h8_040_bplsize,a3
	add.l	c2p_2rgb565_3rgb555h8_040_scroffs,a1
	lea	(a1,a3.l*4),a1

	move.l	c2p_2rgb565_3rgb555h8_040_chunkyxlen,a2
	tst.l	a2
	beq	.none
	add.l	a0,a2

	move.l	c2p_2rgb565_3rgb555h8_040_chunkyy,d0
	subq.w	#1,d0

	move.l	d0,-(sp)

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d6
	move.l	(a0),d7

	moveq	#16,d2
					; d7 E7E6E5E4E3F7F6F5 F4F3------------ ---------------- ----------------
	move.w	d6,d7			; d7 E7E6E5E4E3F7F6F5 F4F3------------ ----------C7C6C5 C4C3--D7D6D5D4D3
	addq.l	#2,a0
	lsl.w	#2,d7			; d7 E7E6E5E4E3F7F6F5 F4F3------------ ------C7C6C5C4C3 --D7D6D5D4D3----
					; d6 y7y6y5y4y3z7z6z5 z4z3--A7A6A5A4A3 B7B6B5B4B3------ ----------------
	rol.l	#8,d6			; d6 z4z3--A7A6A5A4A3 B7B6B5B4B3------ ---------------- y7y6y5y4y3z7z6z5
	lsr.b	#2,d7			; d7 E7E6E5E4E3F7F6F5 F4F3------------ ------C7C6C5C4C3 ------D7D6D5D4D3
	rol.l	#3,d6			; d6 A7A6A5A4A3B7B6B5 B4B3------------ ----------y7y6y5 y4y3z7z6z5z4z3--
	rol.l	d2,d7			; d7 ------C7C6C5C4C3 ------D7D6D5D4D3 E7E6E5E4E3F7F6F5 F4F3------------
	lsl.w	#2,d6			; d6 A7A6A5A4A3B7B6B5 B4B3------------ ------y7y6y5y4y3 z7z6z5z4z3------
	lsr.w	#3,d7			; d7 ------C7C6C5C4C3 ------D7D6D5D4D3 ------E7E6E5E4E3 F7F6F5F4F3------
	lsr.b	#3,d6			; d6 A7A6A5A4A3B7B6B5 B4B3------------ ------y7y6y5y4y3 ------z7z6z5z4z3
	lsr.b	#3,d7			; d7 ------C7C6C5C4C3 ------D7D6D5D4D3 ------E7E6E5E4E3 ------F7F6F5F4F3
	rol.l	d2,d6			; d6 ------y7y6y5y4y3 ------z7z6z5z4z3 A7A6A5A4A3B7B6B5 B4B3------------
	and.l	#$1f1f1f1f,d7
	lsr.w	#3,d6			; d6 ------y7y6y5y4y3 ------z7z6z5z4z3 ------A7A6A5A4A3 B7B6B5B4B3------
	move.l	d4,d5			; d5 ---------------- ------u7u6u5u4u3 ---------------- ----------------
	lsr.b	#3,d6			; d6 ------y7y6y5y4y3 ------z7z6z5z4z3 ------A7A6A5A4A3 ------B7B6B5B4B3
	lsl.l	#3,d5			; d5 ---------------- u7u6u5u4u3------ ---------------- ----------------
	and.l	#$1f1f1f1f,d6
 	move.w	d4,d5			; d5 ---------------- u7u6u5u4u3------ v7v6v5v4v3w7w6w5 w4w3--x7x6x5x4x3
	move.w	d3,d4			; d4 s7s6s5s4s3t7t6t5 t4t3------------ ----------q7q6q5 q4q3--r7r6r5r4r3
	lsl.l	#5,d5			; d5 ------u7u6u5u4u3 ------v7v6v5v4v3 w7w6w5w4w3--x7x6 x5x4x3----------
	lsl.w	#2,d4			; d4 s7s6s5s4s3t7t6t5 t4t3------------ ------q7q6q5q4q3 --r7r6r5r4r3----
  	lsr.w	#3,d5			; d5 ------u7u6u5u4u3 ------v7v6v5v4v3 ------w7w6w5w4w3 --x7x6x5x4x3----
	lsr.b	#2,d4			; d4 s7s6s5s4s3t7t6t5 t4t3------------ ------q7q6q5q4q3 ------r7r6r5r4r3
  	lsr.b	#2,d5			; d5 ------u7u6u5u4u3 ------v7v6v5v4v3 ------w7w6w5w4w3 ------x7x6x5x4x3
	rol.l	d2,d4			; d4 ------q7q6q5q4q3 ------r7r6r5r4r3 s7s6s5s4s3t7t6t5 t4t3------------
	and.l	#$1f1f1f1f,d5
	lsr.w	#3,d4			; d4 ------q7q6q5q4q3 ------r7r6r5r4r3 ------s7s6s5s4s3 t7t6t5t4t3------
					; d3 m7m6m5m4m3n7n6n5 n4n3--o7o6o5o4o3 p7p6p5p4p3------ ----------------
	rol.l	#8,d3			; d3 n4n3--o7o6o5o4o3 p7p6p5p4p3------ ---------------- m7m6m5m4m3n7n6n5
	lsr.b	#3,d4			; d4 ------q7q6q5q4q3 ------r7r6r5r4r3 ------s7s6s5s4s3 ------t7t6t5t4t3
	rol.l	#3,d3			; d3 o7o6o5o4o3p7p6p5 p4p3------------ ----------m7m6m5 m4m3n7n6n5n4n3--
	and.l	#$1f1f1f1f,d4
	lsl.w	#2,d3			; d3 o7o6o5o4o3p7p6p5 p4p3------------ ------m7m6m5m4m3 n7n6n5n4n3------
	move.l	d1,d2			; d2 ---------------- ------i7i6i5i4i3 ---------------- ----------------
	lsr.b	#3,d3			; d3 o7o6o5o4o3p7p6p5 p4p3------------ ------m7m6m5m4m3 ------n7n6n5n4n3
	lsl.l	#3,d2			; d2 ---------------- i7i6i5i4i3------ ---------------- ----------------
	swap	d3			; d3 ------m7m6m5m4m3 ------n7n6n5n4n3 o7o6o5o4o3p7p6p5 p4p3------------
 	move.w	d1,d2			; d2 ---------------- i7i6i5i4i3------ j7j6j5j4j3k7k6k5 k4k3--l7l6l5l4l3
	lsr.w	#3,d3			; d3 ------m7m6m5m4m3 ------n7n6n5n4n3 ------o7o6o5o4o3 p7p6p5p4p3------
	lsl.l	#5,d2			; d2 ------i7i6i5i4i3 ------j7j6j5j4j3 k7k6k5k4k3--l7l6 l5l4l3----------
	lsr.b	#3,d3			; d3 ------m7m6m5m4m3 ------n7n6n5n4n3 ------o7o6o5o4o3 ------p7p6p5p4p3
  	lsr.w	#3,d2			; d2 ------i7i6i5i4i3 ------j7j6j5j4j3 ------k7k6k5k4k3 --l7l6l5l4l3----
	and.l	#$1f1f1f1f,d3
  	lsr.b	#2,d2			; d2 ------i7i6i5i4i3 ------j7j6j5j4j3 ------k7k6k5k4k3 ------l7l6l5l4l3
	move.w	d0,d1			; d1 g7g6g5g4g3h7h6h5 h4h3------------ ----------e7e6e5 e4e3--f7f6f5f4f3
	and.l	#$1f1f1f1f,d2
					; d1 g7g6g5g4g3h7h6h5 h4h3------------ ---------------- ----------------
	rol.l	#8,d0			; d0 b4b3--c7c6c5c4c3 d7d6d5d4d3------ ---------------- a7a6a5a4a3b7b6b5
	lsl.w	#2,d1			; d1 g7g6g5g4g3h7h6h5 h4h3------------ ------e7e6e5e4e3 --f7f6f5f4f3----
	rol.l	#3,d0			; d0 c7c6c5c4c3d7d6d5 d4d3------------ ----------a7a6a5 a4a3b7b6b5b4b3--
	lsr.b	#2,d1			; d1 g7g6g5g4g3h7h6h5 h4h3------------ ------e7e6e5e4e3 ------f7f6f5f4f3
	swap	d1			; d1 ------e7e6e5e4e3 ------f7f6f5f4f3 g7g6g5g4g3h7h6h5 h4h3------------

	lsl.w	#2,d0			; d0 c7c6c5c4c3d7d6d5 d4d3------------ ------a7a6a5a4a3 b7b6b5b4b3------
	lsr.w	#3,d1			; d1 ------e7e6e5e4e3 ------f7f6f5f4f3 ------g7g6g5g4g3 h7h6h5h4h3------
	lsr.b	#3,d0			; d0 c7c6c5c4c3d7d6d5 d4d3------------ ------a7a6a5a4a3 ------b7b6b5b4b3
	lsr.b	#3,d1			; d1 ------e7e6e5e4e3 ------f7f6f5f4f3 ------g7g6g5g4g3 ------h7h6h5h4h3
	swap	d0			; d0 ------a7a6a5a4a3 ------b7b6b5b4b3 c7c6c5c4c3d7d6d5 d4d3------------
	and.l	#$1f1f1f1f,d1
					; d0 a7a6a5a4a3b7b6b5 b4b3--c7c6c5c4c3 d7d6d5d4d3------ ----------------
	lsr.w	#3,d0			; d0 ------a7a6a5a4a3 ------b7b6b5b4b3 ------c7c6c5c4c3 d7d6d5d4d3------
	move.l	d6,a5
	lsr.b	#3,d0			; d0 ------a7a6a5a4a3 ------b7b6b5b4b3 ------c7c6c5c4c3 ------d7d6d5d4d3
	move.l	d7,a6
	and.l	#$1f1f1f1f,d0

	move.l	d1,d6			; Swap 4x1, part 1
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	exg	d2,a5
	exg	d3,a6

	move.l	d5,d6			; Swap 4x1, part 2
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d4,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d4
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d5
	eor.l	d7,d3

	exg	a5,d1

	move.w	d4,d6			; Swap 16x4, part 1
	move.w	d2,d7
	move.w	d0,d4
	move.w	d1,d2
	swap	d4
	swap	d2
	move.w	d4,d0
	move.w	d2,d1
	move.w	d6,d4
	move.w	d7,d2
	bra	.start

.y	move.l	d0,-(sp)

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d6
	move.l	(a0),d7
	move.l	d5,(a1)

	moveq	#16,d2
	sub.l	a3,a1
					; d7 E7E6E5E4E3F7F6F5 F4F3------------ ---------------- ----------------
	move.w	d6,d7			; d7 E7E6E5E4E3F7F6F5 F4F3------------ ----------C7C6C5 C4C3--D7D6D5D4D3
	addq.l	#2,a0
	lsl.w	#2,d7			; d7 E7E6E5E4E3F7F6F5 F4F3------------ ------C7C6C5C4C3 --D7D6D5D4D3----
					; d6 y7y6y5y4y3z7z6z5 z4z3--A7A6A5A4A3 B7B6B5B4B3------ ----------------
	rol.l	#8,d6			; d6 z4z3--A7A6A5A4A3 B7B6B5B4B3------ ---------------- y7y6y5y4y3z7z6z5
	lsr.b	#2,d7			; d7 E7E6E5E4E3F7F6F5 F4F3------------ ------C7C6C5C4C3 ------D7D6D5D4D3
	rol.l	#3,d6			; d6 A7A6A5A4A3B7B6B5 B4B3------------ ----------y7y6y5 y4y3z7z6z5z4z3--
	rol.l	d2,d7			; d7 ------C7C6C5C4C3 ------D7D6D5D4D3 E7E6E5E4E3F7F6F5 F4F3------------
	lsl.w	#2,d6			; d6 A7A6A5A4A3B7B6B5 B4B3------------ ------y7y6y5y4y3 z7z6z5z4z3------
	lsr.w	#3,d7			; d7 ------C7C6C5C4C3 ------D7D6D5D4D3 ------E7E6E5E4E3 F7F6F5F4F3------
	lsr.b	#3,d6			; d6 A7A6A5A4A3B7B6B5 B4B3------------ ------y7y6y5y4y3 ------z7z6z5z4z3
	lsr.b	#3,d7			; d7 ------C7C6C5C4C3 ------D7D6D5D4D3 ------E7E6E5E4E3 ------F7F6F5F4F3
	rol.l	d2,d6			; d6 ------y7y6y5y4y3 ------z7z6z5z4z3 A7A6A5A4A3B7B6B5 B4B3------------
	and.l	#$1f1f1f1f,d7
	lsr.w	#3,d6			; d6 ------y7y6y5y4y3 ------z7z6z5z4z3 ------A7A6A5A4A3 B7B6B5B4B3------
	move.l	d4,d5			; d5 ---------------- ------u7u6u5u4u3 ---------------- ----------------
	lsr.b	#3,d6			; d6 ------y7y6y5y4y3 ------z7z6z5z4z3 ------A7A6A5A4A3 ------B7B6B5B4B3
	lsl.l	#3,d5			; d5 ---------------- u7u6u5u4u3------ ---------------- ----------------
	and.l	#$1f1f1f1f,d6
 	move.w	d4,d5			; d5 ---------------- u7u6u5u4u3------ v7v6v5v4v3w7w6w5 w4w3--x7x6x5x4x3
	move.w	d3,d4			; d4 s7s6s5s4s3t7t6t5 t4t3------------ ----------q7q6q5 q4q3--r7r6r5r4r3
	lsl.l	#5,d5			; d5 ------u7u6u5u4u3 ------v7v6v5v4v3 w7w6w5w4w3--x7x6 x5x4x3----------
	lsl.w	#2,d4			; d4 s7s6s5s4s3t7t6t5 t4t3------------ ------q7q6q5q4q3 --r7r6r5r4r3----
  	lsr.w	#3,d5			; d5 ------u7u6u5u4u3 ------v7v6v5v4v3 ------w7w6w5w4w3 --x7x6x5x4x3----
	lsr.b	#2,d4			; d4 s7s6s5s4s3t7t6t5 t4t3------------ ------q7q6q5q4q3 ------r7r6r5r4r3
  	lsr.b	#2,d5			; d5 ------u7u6u5u4u3 ------v7v6v5v4v3 ------w7w6w5w4w3 ------x7x6x5x4x3
	rol.l	d2,d4			; d4 ------q7q6q5q4q3 ------r7r6r5r4r3 s7s6s5s4s3t7t6t5 t4t3------------
	and.l	#$1f1f1f1f,d5
	lsr.w	#3,d4			; d4 ------q7q6q5q4q3 ------r7r6r5r4r3 ------s7s6s5s4s3 t7t6t5t4t3------
					; d3 m7m6m5m4m3n7n6n5 n4n3--o7o6o5o4o3 p7p6p5p4p3------ ----------------
	rol.l	#8,d3			; d3 n4n3--o7o6o5o4o3 p7p6p5p4p3------ ---------------- m7m6m5m4m3n7n6n5
	lsr.b	#3,d4			; d4 ------q7q6q5q4q3 ------r7r6r5r4r3 ------s7s6s5s4s3 ------t7t6t5t4t3
	rol.l	#3,d3			; d3 o7o6o5o4o3p7p6p5 p4p3------------ ----------m7m6m5 m4m3n7n6n5n4n3--
	and.l	#$1f1f1f1f,d4
	lsl.w	#2,d3			; d3 o7o6o5o4o3p7p6p5 p4p3------------ ------m7m6m5m4m3 n7n6n5n4n3------
	move.l	d1,d2			; d2 ---------------- ------i7i6i5i4i3 ---------------- ----------------
	lsr.b	#3,d3			; d3 o7o6o5o4o3p7p6p5 p4p3------------ ------m7m6m5m4m3 ------n7n6n5n4n3
	lsl.l	#3,d2			; d2 ---------------- i7i6i5i4i3------ ---------------- ----------------
	swap	d3			; d3 ------m7m6m5m4m3 ------n7n6n5n4n3 o7o6o5o4o3p7p6p5 p4p3------------
 	move.w	d1,d2			; d2 ---------------- i7i6i5i4i3------ j7j6j5j4j3k7k6k5 k4k3--l7l6l5l4l3
	lsr.w	#3,d3			; d3 ------m7m6m5m4m3 ------n7n6n5n4n3 ------o7o6o5o4o3 p7p6p5p4p3------
	lsl.l	#5,d2			; d2 ------i7i6i5i4i3 ------j7j6j5j4j3 k7k6k5k4k3--l7l6 l5l4l3----------
	lsr.b	#3,d3			; d3 ------m7m6m5m4m3 ------n7n6n5n4n3 ------o7o6o5o4o3 ------p7p6p5p4p3
  	lsr.w	#3,d2			; d2 ------i7i6i5i4i3 ------j7j6j5j4j3 ------k7k6k5k4k3 --l7l6l5l4l3----
	and.l	#$1f1f1f1f,d3
  	lsr.b	#2,d2			; d2 ------i7i6i5i4i3 ------j7j6j5j4j3 ------k7k6k5k4k3 ------l7l6l5l4l3
	move.w	d0,d1			; d1 g7g6g5g4g3h7h6h5 h4h3------------ ----------e7e6e5 e4e3--f7f6f5f4f3
	and.l	#$1f1f1f1f,d2
					; d1 g7g6g5g4g3h7h6h5 h4h3------------ ---------------- ----------------
	rol.l	#8,d0			; d0 b4b3--c7c6c5c4c3 d7d6d5d4d3------ ---------------- a7a6a5a4a3b7b6b5
	lsl.w	#2,d1			; d1 g7g6g5g4g3h7h6h5 h4h3------------ ------e7e6e5e4e3 --f7f6f5f4f3----
	rol.l	#3,d0			; d0 c7c6c5c4c3d7d6d5 d4d3------------ ----------a7a6a5 a4a3b7b6b5b4b3--
	lsr.b	#2,d1			; d1 g7g6g5g4g3h7h6h5 h4h3------------ ------e7e6e5e4e3 ------f7f6f5f4f3
	swap	d1			; d1 ------e7e6e5e4e3 ------f7f6f5f4f3 g7g6g5g4g3h7h6h5 h4h3------------

	lsl.w	#2,d0			; d0 c7c6c5c4c3d7d6d5 d4d3------------ ------a7a6a5a4a3 b7b6b5b4b3------
	lsr.w	#3,d1			; d1 ------e7e6e5e4e3 ------f7f6f5f4f3 ------g7g6g5g4g3 h7h6h5h4h3------
	lsr.b	#3,d0			; d0 c7c6c5c4c3d7d6d5 d4d3------------ ------a7a6a5a4a3 ------b7b6b5b4b3
	lsr.b	#3,d1			; d1 ------e7e6e5e4e3 ------f7f6f5f4f3 ------g7g6g5g4g3 ------h7h6h5h4h3
	swap	d0			; d0 ------a7a6a5a4a3 ------b7b6b5b4b3 c7c6c5c4c3d7d6d5 d4d3------------
	and.l	#$1f1f1f1f,d1
					; d0 a7a6a5a4a3b7b6b5 b4b3--c7c6c5c4c3 d7d6d5d4d3------ ----------------
	lsr.w	#3,d0			; d0 ------a7a6a5a4a3 ------b7b6b5b4b3 ------c7c6c5c4c3 d7d6d5d4d3------
	move.l	d6,a5
	lsr.b	#3,d0			; d0 ------a7a6a5a4a3 ------b7b6b5b4b3 ------c7c6c5c4c3 ------d7d6d5d4d3
	move.l	a6,(a1)
	move.l	d7,a6
	sub.l	a3,a1
	and.l	#$1f1f1f1f,d0

	move.l	d1,d6			; Swap 4x1, part 1
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	exg	d2,a5
	exg	d3,a6

	move.l	d5,d6			; Swap 4x1, part 2
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d4,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d4
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d5
	eor.l	d7,d3

	exg	a5,d1

	move.w	d4,d6			; Swap 16x4, part 1
	move.w	d2,d7
	move.w	d0,d4
	move.w	d1,d2
	swap	d4
	swap	d2
	move.w	d4,d0
	move.w	d2,d1
	move.w	d6,d4
	move.l	a4,(a1)
	move.w	d7,d2
	lea	4(a1,a3.l*4),a1

	add.l	c2p_2rgb565_3rgb555h8_040_bplmod,a1
	bra	.start
	cnop	0,16
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	(a0)+,d4
	move.l	(a0)+,d6
	move.l	(a0),d7
	move.l	d5,(a1)

	moveq	#16,d2
	sub.l	a3,a1
					; d7 E7E6E5E4E3F7F6F5 F4F3------------ ---------------- ----------------
	move.w	d6,d7			; d7 E7E6E5E4E3F7F6F5 F4F3------------ ----------C7C6C5 C4C3--D7D6D5D4D3
	addq.l	#2,a0
	lsl.w	#2,d7			; d7 E7E6E5E4E3F7F6F5 F4F3------------ ------C7C6C5C4C3 --D7D6D5D4D3----
					; d6 y7y6y5y4y3z7z6z5 z4z3--A7A6A5A4A3 B7B6B5B4B3------ ----------------
	rol.l	#8,d6			; d6 z4z3--A7A6A5A4A3 B7B6B5B4B3------ ---------------- y7y6y5y4y3z7z6z5
	lsr.b	#2,d7			; d7 E7E6E5E4E3F7F6F5 F4F3------------ ------C7C6C5C4C3 ------D7D6D5D4D3
	rol.l	#3,d6			; d6 A7A6A5A4A3B7B6B5 B4B3------------ ----------y7y6y5 y4y3z7z6z5z4z3--
	rol.l	d2,d7			; d7 ------C7C6C5C4C3 ------D7D6D5D4D3 E7E6E5E4E3F7F6F5 F4F3------------
	lsl.w	#2,d6			; d6 A7A6A5A4A3B7B6B5 B4B3------------ ------y7y6y5y4y3 z7z6z5z4z3------
	lsr.w	#3,d7			; d7 ------C7C6C5C4C3 ------D7D6D5D4D3 ------E7E6E5E4E3 F7F6F5F4F3------
	lsr.b	#3,d6			; d6 A7A6A5A4A3B7B6B5 B4B3------------ ------y7y6y5y4y3 ------z7z6z5z4z3
	lsr.b	#3,d7			; d7 ------C7C6C5C4C3 ------D7D6D5D4D3 ------E7E6E5E4E3 ------F7F6F5F4F3
	rol.l	d2,d6			; d6 ------y7y6y5y4y3 ------z7z6z5z4z3 A7A6A5A4A3B7B6B5 B4B3------------
	and.l	#$1f1f1f1f,d7
	lsr.w	#3,d6			; d6 ------y7y6y5y4y3 ------z7z6z5z4z3 ------A7A6A5A4A3 B7B6B5B4B3------
	move.l	d4,d5			; d5 ---------------- ------u7u6u5u4u3 ---------------- ----------------
	lsr.b	#3,d6			; d6 ------y7y6y5y4y3 ------z7z6z5z4z3 ------A7A6A5A4A3 ------B7B6B5B4B3
	lsl.l	#3,d5			; d5 ---------------- u7u6u5u4u3------ ---------------- ----------------
	and.l	#$1f1f1f1f,d6
 	move.w	d4,d5			; d5 ---------------- u7u6u5u4u3------ v7v6v5v4v3w7w6w5 w4w3--x7x6x5x4x3
	move.w	d3,d4			; d4 s7s6s5s4s3t7t6t5 t4t3------------ ----------q7q6q5 q4q3--r7r6r5r4r3
	lsl.l	#5,d5			; d5 ------u7u6u5u4u3 ------v7v6v5v4v3 w7w6w5w4w3--x7x6 x5x4x3----------
	lsl.w	#2,d4			; d4 s7s6s5s4s3t7t6t5 t4t3------------ ------q7q6q5q4q3 --r7r6r5r4r3----
  	lsr.w	#3,d5			; d5 ------u7u6u5u4u3 ------v7v6v5v4v3 ------w7w6w5w4w3 --x7x6x5x4x3----
	lsr.b	#2,d4			; d4 s7s6s5s4s3t7t6t5 t4t3------------ ------q7q6q5q4q3 ------r7r6r5r4r3
  	lsr.b	#2,d5			; d5 ------u7u6u5u4u3 ------v7v6v5v4v3 ------w7w6w5w4w3 ------x7x6x5x4x3
	rol.l	d2,d4			; d4 ------q7q6q5q4q3 ------r7r6r5r4r3 s7s6s5s4s3t7t6t5 t4t3------------
	and.l	#$1f1f1f1f,d5
	lsr.w	#3,d4			; d4 ------q7q6q5q4q3 ------r7r6r5r4r3 ------s7s6s5s4s3 t7t6t5t4t3------
					; d3 m7m6m5m4m3n7n6n5 n4n3--o7o6o5o4o3 p7p6p5p4p3------ ----------------
	rol.l	#8,d3			; d3 n4n3--o7o6o5o4o3 p7p6p5p4p3------ ---------------- m7m6m5m4m3n7n6n5
	lsr.b	#3,d4			; d4 ------q7q6q5q4q3 ------r7r6r5r4r3 ------s7s6s5s4s3 ------t7t6t5t4t3
	rol.l	#3,d3			; d3 o7o6o5o4o3p7p6p5 p4p3------------ ----------m7m6m5 m4m3n7n6n5n4n3--
	and.l	#$1f1f1f1f,d4
	lsl.w	#2,d3			; d3 o7o6o5o4o3p7p6p5 p4p3------------ ------m7m6m5m4m3 n7n6n5n4n3------
	move.l	d1,d2			; d2 ---------------- ------i7i6i5i4i3 ---------------- ----------------
	lsr.b	#3,d3			; d3 o7o6o5o4o3p7p6p5 p4p3------------ ------m7m6m5m4m3 ------n7n6n5n4n3
	lsl.l	#3,d2			; d2 ---------------- i7i6i5i4i3------ ---------------- ----------------
	swap	d3			; d3 ------m7m6m5m4m3 ------n7n6n5n4n3 o7o6o5o4o3p7p6p5 p4p3------------
 	move.w	d1,d2			; d2 ---------------- i7i6i5i4i3------ j7j6j5j4j3k7k6k5 k4k3--l7l6l5l4l3
	lsr.w	#3,d3			; d3 ------m7m6m5m4m3 ------n7n6n5n4n3 ------o7o6o5o4o3 p7p6p5p4p3------
	lsl.l	#5,d2			; d2 ------i7i6i5i4i3 ------j7j6j5j4j3 k7k6k5k4k3--l7l6 l5l4l3----------
	lsr.b	#3,d3			; d3 ------m7m6m5m4m3 ------n7n6n5n4n3 ------o7o6o5o4o3 ------p7p6p5p4p3
  	lsr.w	#3,d2			; d2 ------i7i6i5i4i3 ------j7j6j5j4j3 ------k7k6k5k4k3 --l7l6l5l4l3----
	and.l	#$1f1f1f1f,d3
  	lsr.b	#2,d2			; d2 ------i7i6i5i4i3 ------j7j6j5j4j3 ------k7k6k5k4k3 ------l7l6l5l4l3
	move.w	d0,d1			; d1 g7g6g5g4g3h7h6h5 h4h3------------ ----------e7e6e5 e4e3--f7f6f5f4f3
	and.l	#$1f1f1f1f,d2
					; d1 g7g6g5g4g3h7h6h5 h4h3------------ ---------------- ----------------
	rol.l	#8,d0			; d0 b4b3--c7c6c5c4c3 d7d6d5d4d3------ ---------------- a7a6a5a4a3b7b6b5
	lsl.w	#2,d1			; d1 g7g6g5g4g3h7h6h5 h4h3------------ ------e7e6e5e4e3 --f7f6f5f4f3----
	rol.l	#3,d0			; d0 c7c6c5c4c3d7d6d5 d4d3------------ ----------a7a6a5 a4a3b7b6b5b4b3--
	lsr.b	#2,d1			; d1 g7g6g5g4g3h7h6h5 h4h3------------ ------e7e6e5e4e3 ------f7f6f5f4f3
	swap	d1			; d1 ------e7e6e5e4e3 ------f7f6f5f4f3 g7g6g5g4g3h7h6h5 h4h3------------

	lsl.w	#2,d0			; d0 c7c6c5c4c3d7d6d5 d4d3------------ ------a7a6a5a4a3 b7b6b5b4b3------
	lsr.w	#3,d1			; d1 ------e7e6e5e4e3 ------f7f6f5f4f3 ------g7g6g5g4g3 h7h6h5h4h3------
	lsr.b	#3,d0			; d0 c7c6c5c4c3d7d6d5 d4d3------------ ------a7a6a5a4a3 ------b7b6b5b4b3
	lsr.b	#3,d1			; d1 ------e7e6e5e4e3 ------f7f6f5f4f3 ------g7g6g5g4g3 ------h7h6h5h4h3
	swap	d0			; d0 ------a7a6a5a4a3 ------b7b6b5b4b3 c7c6c5c4c3d7d6d5 d4d3------------
	and.l	#$1f1f1f1f,d1
					; d0 a7a6a5a4a3b7b6b5 b4b3--c7c6c5c4c3 d7d6d5d4d3------ ----------------
	lsr.w	#3,d0			; d0 ------a7a6a5a4a3 ------b7b6b5b4b3 ------c7c6c5c4c3 d7d6d5d4d3------
	move.l	d6,a5
	lsr.b	#3,d0			; d0 ------a7a6a5a4a3 ------b7b6b5b4b3 ------c7c6c5c4c3 ------d7d6d5d4d3
	move.l	a6,(a1)
	move.l	d7,a6
	sub.l	a3,a1
	and.l	#$1f1f1f1f,d0

	move.l	d1,d6			; Swap 4x1, part 1
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	exg	d2,a5
	exg	d3,a6

	move.l	d5,d6			; Swap 4x1, part 2
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d4,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d4
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d5
	eor.l	d7,d3

	exg	a5,d1

	move.w	d4,d6			; Swap 16x4, part 1
	move.w	d2,d7
	move.w	d0,d4
	move.w	d1,d2
	swap	d4
	swap	d2
	move.w	d4,d0
	move.w	d2,d1
	move.w	d6,d4
	move.l	a4,(a1)
	move.w	d7,d2
	lea	4(a1,a3.l*4),a1
.start
	lsl.l	#2,d0			; Swap/Merge 2x4, part 1
	lsl.l	#2,d1
	or.l	d4,d0
	or.l	d2,d1

	move.l	d1,d6			; Swap 8x2, part 1
	move.l	a5,d4			; Swap 16x4, part 2, interleaved
	lsr.l	#8,d6
	swap	d5
	swap	d3
	move.l	a6,d2
	eor.w	d4,d5
	eor.l	d0,d6
	eor.w	d2,d3
	and.l	#$00ff00ff,d6
	eor.w	d5,d4
	eor.l	d6,d0
	eor.w	d3,d2
	add.l	d0,d0			; Swap/Merge 1x2, part 1, interleaved
	lsl.l	#8,d6
	eor.w	d4,d5
	eor.l	d6,d1
	eor.w	d2,d3
	or.l	d1,d0
	swap	d5
	swap	d3
	move.l	d0,(a1)
	sub.l	a3,a1

	move.l	d5,d6			; Swap/Merge 2x4, part 2
	move.l	d3,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d4,d6
	eor.l	d2,d7
	and.l	#$33333333,d6
	and.l	#$33333333,d7
	eor.l	d6,d4
	eor.l	d7,d2
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d5
	eor.l	d7,d3

	move.l	d2,d6			; Swap 8x2, part 2
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d4,d6
	eor.l	d5,d7
	and.l	#$00ff00ff,d6
	and.l	#$00ff00ff,d7
	eor.l	d6,d4
	eor.l	d7,d5
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	d2,d6			; Swap 1x2, part 2
	move.l	d3,d7
	lsr.l	#1,d6
	lsr.l	#1,d7
	eor.l	d4,d6
	eor.l	d5,d7
	and.l	#$55555555,d6
	and.l	#$55555555,d7
	eor.l	d6,d4
	eor.l	d7,d5
	move.l	d4,(a1)
	add.l	d6,d6
	sub.l	a3,a1
	add.l	d7,d7
	eor.l	d2,d6
	eor.l	d7,d3

	move.l	d5,a6
	move.l	d3,a4

	move.l	d6,d5

	cmp.l	a0,a2
	bne	.x

	add.l	c2p_2rgb565_3rgb555h8_040_chunkyminimod,a0
	add.l	c2p_2rgb565_3rgb555h8_040_chunkymod,a2
	move.l	(sp)+,d0
	dbf	d0,.y

	move.l	d5,(a1)
	sub.l	a3,a1
	move.l	a6,(a1)
	sub.l	a3,a1
	move.l	a4,(a1)

.none	movem.l	(sp)+,d2-d7/a2-a6
	rts

	section	bss,bss

c2p_2rgb565_3rgb555h8_040_scroffs	ds.l	1
c2p_2rgb565_3rgb555h8_040_bplsize	ds.l	1
c2p_2rgb565_3rgb555h8_040_chunkymod	ds.l	1
c2p_2rgb565_3rgb555h8_040_chunkyminimod	ds.l	1
c2p_2rgb565_3rgb555h8_040_chunkyxlen	ds.l	1
c2p_2rgb565_3rgb555h8_040_bplmod	ds.l	1
c2p_2rgb565_3rgb555h8_040_chunkyy	ds.l	1
