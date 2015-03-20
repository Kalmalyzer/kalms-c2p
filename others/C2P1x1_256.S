; 1x1 8bpl Chunky2Planar by Blueberry of Efreet (31.07.97)

; Default size values, in use until changed:

ChWidth118 = 320
ChHeight118 = 256
PlSize118 = 320*256/8
PlModulo118 = 0

;SetC2PSizes:
	; D0 = ChunkyWidth
	; D1 = ChunkyHeight
	; D2 = PlaneSize
	; D3 = PlaneModulo

C2P1x1_256_030:
	; A0 = Chunky
	; A1 = Planar
	; A2 = Tempbuffer, half size of chunky.
	; (If chunky can be trashed, A2 may point to chunky.)

	move.l	a1,-(a7)
.mas4	add.l	#PlSize118*4,a1

	move.l	#$0f0f0f0f,d6
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
	move.l	d2,d5
	lsr.l	#4,d5
	eor.l	d0,d5
	and.l	d6,d5
	eor.l	d5,d0
	lsl.l	#4,d5
	eor.l	d5,d2
	move.l	d3,d5
	lsr.l	#4,d5
	eor.l	d1,d5
	and.l	d6,d5
	eor.l	d5,d1
	lsl.l	#4,d5
	eor.l	d5,d3
	move.l	d2,(a2)+
	move.l	d3,(a2)+

	move.l	(a0)+,d4
	move.l	(a0)+,d2
	move.l	(a0)+,d5
	move.l	(a0)+,d3
	move.l	d2,d7
	lsr.l	#4,d7
	eor.l	d4,d7
	and.l	d6,d7
	eor.l	d7,d4
	lsl.l	#4,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d5,d7
	and.l	d6,d7
	eor.l	d7,d5
	lsl.l	#4,d7
	eor.l	d7,d3
	move.l	d2,(a2)+
	move.l	d3,(a2)+

	move.l	d4,d2
	move.l	d5,d3
	move.w	d0,d2
	move.w	d1,d3
	swap.w	d2
	swap.w	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d4,d2
	move.w	d5,d3

	move.l	#$00ff00ff,d6
	move.l	d1,d4
	move.l	d3,d5
	lsr.l	#8,d4
	lsr.l	#8,d5
	eor.l	d0,d4
	eor.l	d2,d5
	and.l	d6,d4
	and.l	d6,d5
	eor.l	d4,d0
	eor.l	d5,d2
	lsl.l	#8,d4
	lsl.l	#8,d5
	eor.l	d4,d1
	eor.l	d5,d3

	move.l	#$33333333,d6
	move.l	d2,d4
	move.l	d3,d5
	lsr.l	#2,d4
	lsr.l	#2,d5
	eor.l	d0,d4
	eor.l	d1,d5
	and.l	d6,d4
	and.l	d6,d5
	eor.l	d4,d0
	eor.l	d5,d1
	lsl.l	#2,d4
	lsl.l	#2,d5
	eor.l	d4,d2
	eor.l	d5,d3

	move.l	#$55555555,d7
	move.l	d1,d4
	move.l	d3,d5
	lsr.l	#1,d4
	lsr.l	#1,d5
	eor.l	d0,d4
	eor.l	d2,d5
	and.l	d7,d4
	and.l	d5,d7
	eor.l	d4,d0
	eor.l	d7,d2
	lsl.l	#1,d4
	lsl.l	#1,d7
	eor.l	d1,d4
	eor.l	d3,d7

.mbhm1	move.w	#ChHeight118-1,-(a7)
.yloop1:
.mcw	lea.l	ChWidth118(a0),a5
.xloop1:
	move.l	d0,a3
	move.l	d2,a4
	move.l	#$0f0f0f0f,d6
	move.l	(a0)+,d0
	move.l	(a0)+,d2
	move.l	(a0)+,d1
	move.l	(a0)+,d3
.mds2	move.l	d4,PlSize118*2(a1)
	move.l	d2,d5
	lsr.l	#4,d5
	eor.l	d0,d5
	and.l	d6,d5
	eor.l	d5,d0
	lsl.l	#4,d5
	eor.l	d5,d2
	move.l	d3,d5
	lsr.l	#4,d5
	eor.l	d1,d5
	and.l	d6,d5
	eor.l	d5,d1
	lsl.l	#4,d5
	eor.l	d5,d3
	move.l	d2,(a2)+
	move.l	d3,(a2)+

	move.l	(a0)+,d4
	move.l	(a0)+,d2
	move.l	(a0)+,d5
	move.l	(a0)+,d3
	move.l	d7,(a1)+
	move.l	d2,d7
	lsr.l	#4,d7
	eor.l	d4,d7
	and.l	d6,d7
	eor.l	d7,d4
	lsl.l	#4,d7
	eor.l	d7,d2
	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d5,d7
	and.l	d6,d7
	eor.l	d7,d5
	lsl.l	#4,d7
	eor.l	d7,d3
	move.l	d2,(a2)+
	move.l	d3,(a2)+

	move.l	d4,d2
	move.l	d5,d3
	move.w	d0,d2
	move.w	d1,d3
	swap.w	d2
	swap.w	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d4,d2
	move.w	d5,d3
.mes3m4	move.l	a3,PlSize118*3-4(a1)

	move.l	#$00ff00ff,d6
	move.l	d1,d4
	move.l	d3,d5
	lsr.l	#8,d4
	lsr.l	#8,d5
	eor.l	d0,d4
	eor.l	d2,d5
	and.l	d6,d4
	and.l	d6,d5
	eor.l	d4,d0
	eor.l	d5,d2
	lsl.l	#8,d4
	lsl.l	#8,d5
	eor.l	d4,d1
	eor.l	d5,d3

	move.l	#$33333333,d6
	move.l	d2,d4
	move.l	d3,d5
	lsr.l	#2,d4
	lsr.l	#2,d5
	eor.l	d0,d4
	eor.l	d1,d5
	and.l	d6,d4
	and.l	d6,d5
	eor.l	d4,d0
	eor.l	d5,d1
.mfsm4	move.l	a4,PlSize118*1-4(a1)
	lsl.l	#2,d4
	lsl.l	#2,d5
	eor.l	d4,d2
	eor.l	d5,d3

	move.l	#$55555555,d7
	move.l	d1,d4
	move.l	d3,d5
	lsr.l	#1,d4
	lsr.l	#1,d5
	eor.l	d0,d4
	eor.l	d2,d5
	and.l	d7,d4
	and.l	d5,d7
	eor.l	d4,d0
	eor.l	d7,d2
	lsl.l	#1,d4
	lsl.l	#1,d7
	eor.l	d1,d4
	eor.l	d3,d7

	cmp.l	a5,a0
	blt.w	.xloop1
.mgm	add.w	#PlModulo118,a1

	subq.w	#1,(a7)
	bgt.w	.yloop1
.mhwm32	lea.l	ChWidth118-32(a0),a5
	beq.w	.xloop1

.mim	sub.w	#PlModulo118,a1
.mjs2	move.l	d4,PlSize118*2(a1)
	move.l	d7,(a1)+
.mks3m4	move.l	d0,PlSize118*3-4(a1)
.mlsm4	move.l	d2,PlSize118*1-4(a1)


.mmwhd2	sub.l	#ChWidth118*ChHeight118/2,a2

	move.l	(a2)+,d0
	move.l	(a2)+,d1
	move.l	(a2)+,d4
	move.l	(a2)+,d5

	move.l	d4,d2
	move.l	d5,d3
	move.w	d0,d2
	move.w	d1,d3
	swap.w	d2
	swap.w	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d4,d2
	move.w	d5,d3

	move.l	#$00ff00ff,d6
	move.l	d1,d4
	move.l	d3,d5
	lsr.l	#8,d4
	lsr.l	#8,d5
	eor.l	d0,d4
	eor.l	d2,d5
	and.l	d6,d4
	and.l	d6,d5
	eor.l	d4,d0
	eor.l	d5,d2
	lsl.l	#8,d4
	lsl.l	#8,d5
	eor.l	d4,d1
	eor.l	d5,d3

	move.l	#$33333333,d6
	move.l	d2,d4
	move.l	d3,d5
	lsr.l	#2,d4
	lsr.l	#2,d5
	eor.l	d0,d4
	eor.l	d1,d5
	and.l	d6,d4
	and.l	d6,d5
	eor.l	d4,d0
	eor.l	d5,d1
	lsl.l	#2,d4
	lsl.l	#2,d5
	eor.l	d4,d2
	eor.l	d5,d3

	move.l	#$55555555,d7
	move.l	d3,d5
	move.l	d1,d4
	lsr.l	#1,d5
	lsr.l	#1,d4
	eor.l	d2,d5
	eor.l	d0,d4
	and.l	d7,d5
	and.l	d4,d7
	eor.l	d5,d2
	eor.l	d7,d0
	lsl.l	#1,d5
	lsl.l	#1,d7
	eor.l	d5,d3
	eor.l	d1,d7

	move.l	2(a7),a1
.mnhm1	move.w	#ChHeight118-1,(a7)
.yloop2:
.mowd2	lea.l	ChWidth118/2(a2),a5
.xloop2:
	move.l	d0,a3
	move.l	d2,a4

	move.l	(a2)+,d0
	move.l	(a2)+,d1
	move.l	(a2)+,d4
	move.l	(a2)+,d5
	move.l	d3,(a1)+

	move.l	d4,d2
	move.l	d5,d3
	move.w	d0,d2
	move.w	d1,d3
	swap.w	d2
	swap.w	d3
	move.w	d2,d0
	move.w	d3,d1
	move.w	d4,d2
	move.w	d5,d3

	move.l	#$00ff00ff,d6
	move.l	d1,d4
	move.l	d3,d5
.mps2m4	move.l	d7,PlSize118*2-4(a1)
	lsr.l	#8,d4
	lsr.l	#8,d5
	eor.l	d0,d4
	eor.l	d2,d5
	and.l	d6,d4
	and.l	d6,d5
	eor.l	d4,d0
	eor.l	d5,d2
	lsl.l	#8,d4
	lsl.l	#8,d5
	eor.l	d4,d1
	eor.l	d5,d3

	move.l	#$33333333,d6
	move.l	d2,d4
	move.l	d3,d5
.mqs3m4	move.l	a3,PlSize118*3-4(a1)
	lsr.l	#2,d4
	lsr.l	#2,d5
	eor.l	d0,d4
	eor.l	d1,d5
	and.l	d6,d4
	and.l	d6,d5
	eor.l	d4,d0
	eor.l	d5,d1
	lsl.l	#2,d4
	lsl.l	#2,d5
	eor.l	d4,d2
	eor.l	d5,d3

	move.l	#$55555555,d7
	move.l	d3,d5
	move.l	d1,d4
.mrsm4	move.l	a4,PlSize118*1-4(a1)
	lsr.l	#1,d5
	lsr.l	#1,d4
	eor.l	d2,d5
	eor.l	d0,d4
	and.l	d7,d5
	and.l	d4,d7
	eor.l	d5,d2
	eor.l	d7,d0
	lsl.l	#1,d5
	lsl.l	#1,d7
	eor.l	d5,d3
	eor.l	d1,d7

	cmp.l	a5,a2
	blt.w	.xloop2
.msm	add.w	#PlModulo118,a1

	subq.w	#1,(a7)
	bgt.w	.yloop2
.mtwd2m16
	lea.l	ChWidth118/2-16(a2),a5
	beq.w	.xloop2

.mum	sub.w	#PlModulo118,a1
	move.l	d3,(a1)+
.mvs2m4	move.l	d7,PlSize118*2-4(a1)
.mws3m4	move.l	d0,PlSize118*3-4(a1)
.mxsm4	move.l	d2,PlSize118*1-4(a1)
	addq.l	#6,a7
	rts

; ------- Delete from here if size changing is not needed! -------

.mod:
	lea.l	C2P1x1_256_030+2(pc),a0
	basereg	C2P1x1_256_030,a0
	move.w	d0,d4
	sub.w	#32,d4
	move.w	d0,.mcw(a0)
	move.w	d4,.mhwm32(a0)
	asr.w	#1,d0
	asr.w	#1,d4
	move.w	d0,.mowd2(a0)
	move.w	d4,.mtwd2m16(a0)
	muls.w	d1,d0
	move.l	d0,.mmwhd2(a0)

	subq.w	#1,d1
	move.w	d1,.mbhm1(a0)
	move.w	d1,.mnhm1(a0)

	subq.l	#4,d2
	move.l	d2,d4
	move.w	d4,.mfsm4(a0)
	move.w	d4,.mlsm4(a0)
	move.w	d4,.mrsm4(a0)
	move.w	d4,.mxsm4(a0)
	addq.l	#4,d4
	add.l	d2,d4
	move.w	d4,.mps2m4(a0)
	move.w	d4,.mvs2m4(a0)
	addq.l	#4,d4
	move.w	d4,.mds2(a0)
	move.w	d4,.mjs2(a0)
	add.l	d2,d4
	move.w	d4,.mes3m4(a0)
	move.w	d4,.mks3m4(a0)
	move.w	d4,.mqs3m4(a0)
	move.w	d4,.mws3m4(a0)
	add.l	d2,d4
	addq.l	#8,d4
	move.l	d4,.mas4(a0)

	move.w	d3,.mgm(a0)
	move.w	d3,.mim(a0)
	move.w	d3,.msm(a0)
	move.w	d3,.mum(a0)

	move.l	$4.w,a6
	jmp	-636(a6)

SetC2PSizes = C2P1x1_256_030\.mod

	endb	a0
