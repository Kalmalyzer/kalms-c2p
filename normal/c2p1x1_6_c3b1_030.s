
; c2p1x1_6_c3b1_030
;
; Copy speed on 040-25 (? Probably)

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

	include hardware/custom.i
	include	lvo/graphics_lib.i

	XREF	_GfxBase

	section	c2p,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	bplsize [bytes] -- offset between one row in one bpl and the next bpl

	XDEF	_c2p1x1_6_c3b1_030_init
	XDEF	c2p1x1_6_c3b1_030_init
_c2p1x1_6_c3b1_030_init
c2p1x1_6_c3b1_030_init
	movem.l	d2-d3,-(sp)
	lea	c2p1x1_6_c3b1_030_datanew(pc),a0
	andi.l	#$ffff,d0
	andi.l	#$ffff,d2
	move.l	d5,c2p1x1_6_c3b1_030_bplsize-c2p1x1_6_c3b1_030_data(a0)
	move.w	d1,c2p1x1_6_c3b1_030_chunkyy-c2p1x1_6_c3b1_030_data(a0)
	add.w	d3,d1
	mulu.w	d0,d1
	lsr.l	#3,d1
	subq.l	#2,d1
	move.l	d1,c2p1x1_6_c3b1_030_scroffs2-c2p1x1_6_c3b1_030_data(a0)
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p1x1_6_c3b1_030_scroffs-c2p1x1_6_c3b1_030_data(a0)
	move.w	c2p1x1_6_c3b1_030_chunkyy-c2p1x1_6_c3b1_030_data(a0),d1
	mulu.w	d0,d1
	move.l	d1,c2p1x1_6_c3b1_030_pixels-c2p1x1_6_c3b1_030_data(a0)
	lsr.l	d1
	move.l	d1,c2p1x1_6_c3b1_030_pixels2-c2p1x1_6_c3b1_030_data(a0)
	lsr.l	d1
	move.l	d1,c2p1x1_6_c3b1_030_pixels4-c2p1x1_6_c3b1_030_data(a0)
	lsr.l	#2,d1
	move.l	d1,c2p1x1_6_c3b1_030_pixels16-c2p1x1_6_c3b1_030_data(a0)
	lsr.l	d1
	move.l	d1,c2p1x1_6_c3b1_030_pixels32-c2p1x1_6_c3b1_030_data(a0)
	movem.l	(sp)+,d2-d3
	rts

c2p1x1_6_c3b1_030_blitcleanup
	st	c2p1x1_6_c3b1_030_blitfin-c2p1x1_6_c3b1_030_bltnode(a1)
	sf	c2p1x1_6_c3b1_030_blitactive-c2p1x1_6_c3b1_030_bltnode(a1)
	rts

	XDEF	_c2p1x1_6_c3b1_030_waitblit
	XDEF	c2p1x1_6_c3b1_030_waitblit
_c2p1x1_6_c3b1_030_waitblit
c2p1x1_6_c3b1_030_waitblit
	tst.b	c2p1x1_6_c3b1_030_blitactive(pc)
	beq.s	.n
.y	tst.b	c2p1x1_6_c3b1_030_blitfin(pc)
	beq.s	.y
.n	rts

; a0	c2pscreen
; a1	bitplanes
; a2    blitbuf

	XDEF	_c2p1x1_6_c3b1_030
	XDEF	c2p1x1_6_c3b1_030
_c2p1x1_6_c3b1_030
c2p1x1_6_c3b1_030
	movem.l	d2-d7/a2-a6,-(sp)

	bsr.s	c2p1x1_6_c3b1_030_waitblit
	bsr	c2p1x1_6_c3b1_030_copyinitblock

	lea	c2p1x1_6_c3b1_030_data(pc),a3
	move.l	a1,c2p1x1_6_c3b1_030_screen-c2p1x1_6_c3b1_030_data(a3)
	move.l	a2,c2p1x1_6_c3b1_030_blitbuf-c2p1x1_6_c3b1_030_data(a3)
	move.l	a2,a1
	move.l	a2,a6
	move.l	a3,a2

	move.l	#$55555555,d4
	move.l	#$0f0f0f0f,d5
	move.l	#$00ff00ff,d6

	add.l	c2p1x1_6_c3b1_030_pixels2-c2p1x1_6_c3b1_030_data(a2),a6
	move.l	c2p1x1_6_c3b1_030_pixels-c2p1x1_6_c3b1_030_data(a2),a2
	add.l	a0,a2
	cmpa.l	a0,a2
	beq	.none

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	d1,d7			; Swap 4x1
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d1,d7

	move.l	d3,d1
	lsr.l	#4,d1
	eor.l	d2,d1
	and.l	d5,d1
	eor.l	d1,d2
	lsl.l	#4,d1
	eor.l	d1,d3

	bra.s	.start
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	d7,(a6)+
	move.l	d1,d7			; Swap 4x1
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d1,d7

	move.l	d3,d1
	lsr.l	#4,d1
	eor.l	d2,d1
	and.l	d5,d1
	eor.l	d1,d2
	lsl.l	#4,d1
	eor.l	d1,d3
	move.l	a5,(a6)+
.start
	move.l	d3,d1			; Swap 8x2, part 2
	lsr.l	#8,d1
	eor.l	d7,d1
	and.l	d6,d1
	eor.l	d1,d7
	lsl.l	#8,d1
	eor.l	d1,d3

	move.l	d3,d1			; Swap 1x2, part 2
	lsr.l	d1
	eor.l	d7,d1
	and.l	d4,d1
	eor.l	d1,d7
	add.l	d1,d1
	eor.l	d1,d3

	lsl.l	#2,d0
	lsl.l	#2,d2
	move.l	d0,a3
	move.l	d2,a4
	move.l	d3,a5

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	d7,(a1)+
	move.l	d1,d7			; Swap 4x1
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d1

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d2,d7
	and.l	d5,d7
	eor.l	d7,d2
	lsl.l	#4,d7
	eor.l	d7,d3
	move.l	a5,(a1)+

	move.l	d3,d7			; Swap 8x2, part 2
	lsr.l	#8,d7
	eor.l	d1,d7
	and.l	d6,d7
	eor.l	d7,d1
	lsl.l	#8,d7
	eor.l	d7,d3

	move.l	d3,d7			; Swap 1x2, part 2
	lsr.l	d7
	eor.l	d1,d7
	and.l	d4,d7
	eor.l	d7,d1
	move.l	d1,(a1)+
	add.l	d7,d7
	eor.l	d3,d7

	add.l	a3,d0
	add.l	a4,d2

	move.l	d2,d3
	lsr.l	#8,d3
	eor.l	d0,d3
	and.l	d6,d3
	eor.l	d3,d0
	move.l	d7,(a1)+
	lsl.l	#8,d3
	eor.l	d3,d2

	move.l	d2,d7
	lsr.l	d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	add.l	d7,d7
	eor.l	d2,d7

	move.l	d0,a5

	cmp.l	a0,a2
	bne	.x
.x2
	move.l	d7,(a6)+
	move.l	a5,(a6)+

	lea	c2p1x1_6_c3b1_030_data(pc),a2
	sf	c2p1x1_6_c3b1_030_blitfin-c2p1x1_6_c3b1_030_data(a2)
	st	c2p1x1_6_c3b1_030_blitactive-c2p1x1_6_c3b1_030_data(a2)
	lea	c2p1x1_6_c3b1_030_bltnode(pc),a1
	move.l	#c2p1x1_6_c3b1_030_41,c2p1x1_6_c3b1_030_bltroutptr-c2p1x1_6_c3b1_030_bltnode(a1)
	move.l	_GfxBase,a6
	jsr	_LVOQBlit(a6)

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

c2p1x1_6_c3b1_030_41
	move.w	#-1,bltafwm(a0)
	move.w	#-1,bltalwm(a0)
	move.l	c2p1x1_6_c3b1_030_blitbuf-c2p1x1_6_c3b1_030_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p1x1_6_c3b1_030_bplsize-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p1x1_6_c3b1_030_bplsize-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_screen-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_scroffs-c2p1x1_6_c3b1_030_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#6,bltamod(a0)
	move.w	#6,bltbmod(a0)
	move.w	#0,bltdmod(a0)
	move.w	#$cccc,bltcdat(a0)
	move.w	#$0de4,bltcon0(a0)
	move.w	#$2000,bltcon1(a0)
	move.w	c2p1x1_6_c3b1_030_pixels16+2-c2p1x1_6_c3b1_030_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_6_c3b1_030_42,c2p1x1_6_c3b1_030_bltroutptr-c2p1x1_6_c3b1_030_bltnode(a1)
	rts

c2p1x1_6_c3b1_030_42
	move.l	c2p1x1_6_c3b1_030_blitbuf-c2p1x1_6_c3b1_030_bltnode(a1),d0
	addq.l	#4,d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p1x1_6_c3b1_030_bplsize-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p1x1_6_c3b1_030_screen-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_scroffs-c2p1x1_6_c3b1_030_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p1x1_6_c3b1_030_pixels16+2-c2p1x1_6_c3b1_030_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_6_c3b1_030_43,c2p1x1_6_c3b1_030_bltroutptr-c2p1x1_6_c3b1_030_bltnode(a1)
	rts

c2p1x1_6_c3b1_030_43
	move.l	c2p1x1_6_c3b1_030_blitbuf-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_pixels2-c2p1x1_6_c3b1_030_bltnode(a1),d0
	subq.l	#8,d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p1x1_6_c3b1_030_bplsize-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_screen-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_scroffs2-c2p1x1_6_c3b1_030_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$2de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p1x1_6_c3b1_030_pixels16+2-c2p1x1_6_c3b1_030_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_6_c3b1_030_44,c2p1x1_6_c3b1_030_bltroutptr-c2p1x1_6_c3b1_030_bltnode(a1)
	rts

c2p1x1_6_c3b1_030_44
	move.l	c2p1x1_6_c3b1_030_blitbuf-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_pixels2-c2p1x1_6_c3b1_030_bltnode(a1),d0
	subq.l	#4,d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p1x1_6_c3b1_030_screen-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_scroffs2-c2p1x1_6_c3b1_030_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p1x1_6_c3b1_030_pixels16+2-c2p1x1_6_c3b1_030_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_6_c3b1_030_45a,c2p1x1_6_c3b1_030_bltroutptr-c2p1x1_6_c3b1_030_bltnode(a1)
	rts

c2p1x1_6_c3b1_030_45a
	move.l	c2p1x1_6_c3b1_030_blitbuf-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_pixels2-c2p1x1_6_c3b1_030_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p1x1_6_c3b1_030_bplsize-c2p1x1_6_c3b1_030_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p1x1_6_c3b1_030_screen-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_scroffs-c2p1x1_6_c3b1_030_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#2,bltdmod(a0)
	move.w	#$0de4,bltcon0(a0)
	move.w	#$2000,bltcon1(a0)
	move.w	c2p1x1_6_c3b1_030_pixels32+2-c2p1x1_6_c3b1_030_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_6_c3b1_030_46a,c2p1x1_6_c3b1_030_bltroutptr-c2p1x1_6_c3b1_030_bltnode(a1)
	rts

c2p1x1_6_c3b1_030_46a
	move.l	c2p1x1_6_c3b1_030_blitbuf-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_pixels2-c2p1x1_6_c3b1_030_bltnode(a1),d0
	addq.l	#4,d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p1x1_6_c3b1_030_bplsize-c2p1x1_6_c3b1_030_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p1x1_6_c3b1_030_bplsize-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_screen-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_scroffs-c2p1x1_6_c3b1_030_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p1x1_6_c3b1_030_pixels32+2-c2p1x1_6_c3b1_030_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_6_c3b1_030_45b,c2p1x1_6_c3b1_030_bltroutptr-c2p1x1_6_c3b1_030_bltnode(a1)
	rts

c2p1x1_6_c3b1_030_45b
	move.l	c2p1x1_6_c3b1_030_blitbuf-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_pixels2-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_pixels4-c2p1x1_6_c3b1_030_bltnode(a1),d0
	subq.l	#8,d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p1x1_6_c3b1_030_bplsize-c2p1x1_6_c3b1_030_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p1x1_6_c3b1_030_screen-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_scroffs2-c2p1x1_6_c3b1_030_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$2de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p1x1_6_c3b1_030_pixels32+2-c2p1x1_6_c3b1_030_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_6_c3b1_030_46b,c2p1x1_6_c3b1_030_bltroutptr-c2p1x1_6_c3b1_030_bltnode(a1)
	rts

c2p1x1_6_c3b1_030_46b
	move.l	c2p1x1_6_c3b1_030_blitbuf-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_pixels2-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_pixels4-c2p1x1_6_c3b1_030_bltnode(a1),d0
	subq.l	#4,d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p1x1_6_c3b1_030_bplsize-c2p1x1_6_c3b1_030_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p1x1_6_c3b1_030_bplsize-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_screen-c2p1x1_6_c3b1_030_bltnode(a1),d0
	add.l	c2p1x1_6_c3b1_030_scroffs2-c2p1x1_6_c3b1_030_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p1x1_6_c3b1_030_pixels32+2-c2p1x1_6_c3b1_030_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_6_c3b1_030_41,c2p1x1_6_c3b1_030_bltroutptr-c2p1x1_6_c3b1_030_bltnode(a1)
	moveq	#0,d0
	rts


c2p1x1_6_c3b1_030_copyinitblock
	movem.l	a0-a1,-(sp)
	lea	c2p1x1_6_c3b1_030_datanew,a0
	lea	c2p1x1_6_c3b1_030_data,a1
	moveq	#16-1,d0
.copy	move.l	(a0)+,(a1)+
	dbf	d0,.copy
	movem.l	(sp)+,a0-a1
	rts

	cnop 0,4
c2p1x1_6_c3b1_030_bltnode
	dc.l	0
c2p1x1_6_c3b1_030_bltroutptr
	dc.l	0
	dc.b	$40,0
	dc.l	0
c2p1x1_6_c3b1_030_bltroutcleanup
	dc.l	c2p1x1_6_c3b1_030_blitcleanup
c2p1x1_6_c3b1_030_blitfin dc.b 0
c2p1x1_6_c3b1_030_blitactive dc.b 0

	cnop	0,4

c2p1x1_6_c3b1_030_data
c2p1x1_6_c3b1_030_screen dc.l	0
c2p1x1_6_c3b1_030_scroffs dc.l 0
c2p1x1_6_c3b1_030_scroffs2 dc.l 0
c2p1x1_6_c3b1_030_bplsize dc.l 0
c2p1x1_6_c3b1_030_pixels dc.l 0
c2p1x1_6_c3b1_030_pixels2 dc.l 0
c2p1x1_6_c3b1_030_pixels4 dc.l 0
c2p1x1_6_c3b1_030_pixels16 dc.l 0
c2p1x1_6_c3b1_030_pixels32 dc.l 0
c2p1x1_6_c3b1_030_chunkyy dc.w 0
c2p1x1_6_c3b1_030_rowmod dc.w	0
c2p1x1_6_c3b1_030_blitbuf dc.l 0
	ds.l	16

	cnop 0,4
c2p1x1_6_c3b1_030_datanew
	ds.l	16
