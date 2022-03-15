
; c2p2x1_8_c4b1_gen

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

	XDEF	_GfxBase

	section	c2p,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	bplsize [bytes] -- offset between one row in one bpl and the next bpl

	XDEF	_c2p2x1_8_c4b1_gen_init
	XDEF	c2p2x1_8_c4b1_gen_init
_c2p2x1_8_c4b1_gen_init
c2p2x1_8_c4b1_gen_init
	movem.l	d2-d3,-(sp)
	lea	c2p2x1_8_c4b1_gen_datanew(pc),a0
	andi.l	#$ffff,d0
	move.l	d5,c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_data(a0)
	move.w	d3,d2
	mulu.w	d0,d2
	lsr.l	#2,d2
	move.l	d2,c2p2x1_8_c4b1_gen_scroffs-c2p2x1_8_c4b1_gen_data(a0)
	add.w	d1,d3
	mulu.w	d0,d3
	lsr.l	#2,d3
	subq.w	#2,d3
	move.l	d3,c2p2x1_8_c4b1_gen_scroffs2-c2p2x1_8_c4b1_gen_data(a0)
	mulu.w	d0,d1
	move.l	d1,c2p2x1_8_c4b1_gen_pixels-c2p2x1_8_c4b1_gen_data(a0)
	lsr.l	#4,d1
	move.l	d1,c2p2x1_8_c4b1_gen_pixels16-c2p2x1_8_c4b1_gen_data(a0)
	movem.l	(sp)+,d2-d3
	rts

c2p2x1_8_c4b1_gen_blitcleanup
	st	c2p2x1_8_c4b1_gen_blitfin-c2p2x1_8_c4b1_gen_bltnode(a1)
	sf	c2p2x1_8_c4b1_gen_blitactive-c2p2x1_8_c4b1_gen_bltnode(a1)
	rts

	XDEF	_c2p2x1_8_c4b1_gen_waitblit
	XDEF	c2p2x1_8_c4b1_gen_waitblit
_c2p2x1_8_c4b1_gen_waitblit
c2p2x1_8_c4b1_gen_waitblit
	tst.b	c2p2x1_8_c4b1_gen_blitactive(pc)
	beq.s	.n
.y	tst.b	c2p2x1_8_c4b1_gen_blitfin(pc)
	beq.s	.y
.n	rts

; a0	c2pscreen
; a1	bitplanes

	XDEF	_c2p2x1_8_c4b1_gen
	XDEF	c2p2x1_8_c4b1_gen
_c2p2x1_8_c4b1_gen
c2p2x1_8_c4b1_gen
	movem.l	d2-d7/a2-a6,-(sp)

	bsr.s	c2p2x1_8_c4b1_gen_waitblit
	bsr	c2p2x1_8_c4b1_gen_copyinitblock

	lea	c2p2x1_8_c4b1_gen_data(pc),a3
	move.l	a1,c2p2x1_8_c4b1_gen_screen-c2p2x1_8_c4b1_gen_data(a3)
	move.l	a2,c2p2x1_8_c4b1_gen_blitbuf-c2p2x1_8_c4b1_gen_data(a3)
	move.l	a2,a1
	move.l	a3,a2

	move.l	#$0f0f0f0f,d5
	move.l	#$00ff00ff,a6

	move.l	c2p2x1_8_c4b1_gen_pixels-c2p2x1_8_c4b1_gen_data(a2),a2
	add.l	a0,a2
	cmpa.l	a0,a2
	beq	.none

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

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

	move.l	d2,d6			; Swap 4x2
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	d5,d6
	and.l	d5,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	a6,d4
	move.l	d1,d6			; Swap 8x1
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d1
	eor.l	d7,d3

	move.l	#$33333333,d4
	move.l	d1,d6			; Swap 2x1
	move.l	d3,d7

	bra.s	.start
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	d7,(a1)+

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

	move.l	d2,d6			; Swap 4x2
	move.l	d3,d7
	move.l	a3,(a1)+
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	d5,d6
	and.l	d5,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d2
	eor.l	d7,d3

	move.l	a6,d4
	move.l	d1,d6			; Swap 8x1
	move.l	d3,d7
	move.l	a4,(a1)+
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d1
	eor.l	d7,d3

	move.l	#$33333333,d4
	move.l	d1,d6			; Swap 2x1
	move.l	d3,d7
	move.l	a5,(a1)+
.start
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	d4,d6
	and.l	d4,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#2,d7
	lsl.l	#2,d6
	eor.l	d6,d1
	eor.l	d3,d7

	move.l	d0,a3
	move.l	d1,a4
	move.l	d2,a5

	cmp.l	a0,a2
	bne	.x
.x2
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	move.l	a4,(a1)+
	move.l	a5,(a1)+

	lea	c2p2x1_8_c4b1_gen_data(pc),a2
	sf	c2p2x1_8_c4b1_gen_blitfin-c2p2x1_8_c4b1_gen_data(a2)
	st	c2p2x1_8_c4b1_gen_blitactive-c2p2x1_8_c4b1_gen_data(a2)
	lea	c2p2x1_8_c4b1_gen_bltnode(pc),a1
	move.l	#c2p2x1_8_c4b1_gen_51,c2p2x1_8_c4b1_gen_bltroutptr-c2p2x1_8_c4b1_gen_bltnode(a1)
	move.l	_GfxBase,a6
	jsr	_LVOQBlit(a6)
.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

c2p2x1_8_c4b1_gen_51
	move.w	#-1,bltafwm(a0)
	move.w	#-1,bltalwm(a0)
	move.l	c2p2x1_8_c4b1_gen_blitbuf-c2p2x1_8_c4b1_gen_bltnode(a1),bltapt(a0)
	move.l	c2p2x1_8_c4b1_gen_blitbuf-c2p2x1_8_c4b1_gen_bltnode(a1),bltbpt(a0)
	move.l	c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_screen-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_scroffs-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#12,bltamod(a0)
	move.w	#12,bltbmod(a0)
	move.w	#0,bltdmod(a0)
	move.w	#$aaaa,bltcdat(a0)
	move.w	#$0de4,bltcon0(a0)
	move.w	#$1000,bltcon1(a0)
	move.w	c2p2x1_8_c4b1_gen_pixels16+2-c2p2x1_8_c4b1_gen_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_8_c4b1_gen_52,c2p2x1_8_c4b1_gen_bltroutptr-c2p2x1_8_c4b1_gen_bltnode(a1)
	rts

c2p2x1_8_c4b1_gen_52
	move.l	c2p2x1_8_c4b1_gen_blitbuf-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	#12,d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_screen-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_scroffs-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p2x1_8_c4b1_gen_pixels16+2-c2p2x1_8_c4b1_gen_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_8_c4b1_gen_53,c2p2x1_8_c4b1_gen_bltroutptr-c2p2x1_8_c4b1_gen_bltnode(a1)
	rts

c2p2x1_8_c4b1_gen_53
	move.l	c2p2x1_8_c4b1_gen_blitbuf-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	addq.l	#8,d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_screen-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_scroffs-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p2x1_8_c4b1_gen_pixels16+2-c2p2x1_8_c4b1_gen_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_8_c4b1_gen_54,c2p2x1_8_c4b1_gen_bltroutptr-c2p2x1_8_c4b1_gen_bltnode(a1)
	rts

c2p2x1_8_c4b1_gen_54
	move.l	c2p2x1_8_c4b1_gen_blitbuf-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	addq.l	#4,d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	lsl.l	#3,d0
	sub.l	c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_screen-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_scroffs-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p2x1_8_c4b1_gen_pixels16+2-c2p2x1_8_c4b1_gen_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_8_c4b1_gen_55,c2p2x1_8_c4b1_gen_bltroutptr-c2p2x1_8_c4b1_gen_bltnode(a1)
	rts

c2p2x1_8_c4b1_gen_55
	move.l	c2p2x1_8_c4b1_gen_blitbuf-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	sub.l	#14,d0
	add.l	c2p2x1_8_c4b1_gen_pixels-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p2x1_8_c4b1_gen_screen-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_scroffs2-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$1de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p2x1_8_c4b1_gen_pixels16+2-c2p2x1_8_c4b1_gen_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_8_c4b1_gen_56,c2p2x1_8_c4b1_gen_bltroutptr-c2p2x1_8_c4b1_gen_bltnode(a1)
	rts

c2p2x1_8_c4b1_gen_56
	move.l	c2p2x1_8_c4b1_gen_blitbuf-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	subq.l	#2,d0
	add.l	c2p2x1_8_c4b1_gen_pixels-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p2x1_8_c4b1_gen_screen-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_scroffs2-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$1de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p2x1_8_c4b1_gen_pixels16+2-c2p2x1_8_c4b1_gen_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_8_c4b1_gen_57,c2p2x1_8_c4b1_gen_bltroutptr-c2p2x1_8_c4b1_gen_bltnode(a1)
	rts

c2p2x1_8_c4b1_gen_57
	move.l	c2p2x1_8_c4b1_gen_blitbuf-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	subq.l	#6,d0
	add.l	c2p2x1_8_c4b1_gen_pixels-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p2x1_8_c4b1_gen_screen-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_scroffs2-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$1de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p2x1_8_c4b1_gen_pixels16+2-c2p2x1_8_c4b1_gen_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_8_c4b1_gen_58,c2p2x1_8_c4b1_gen_bltroutptr-c2p2x1_8_c4b1_gen_bltnode(a1)
	rts

c2p2x1_8_c4b1_gen_58
	move.l	c2p2x1_8_c4b1_gen_blitbuf-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	sub.l	#10,d0
	add.l	c2p2x1_8_c4b1_gen_pixels-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p2x1_8_c4b1_gen_bplsize-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p2x1_8_c4b1_gen_screen-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	add.l	c2p2x1_8_c4b1_gen_scroffs2-c2p2x1_8_c4b1_gen_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$1de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p2x1_8_c4b1_gen_pixels16+2-c2p2x1_8_c4b1_gen_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_8_c4b1_gen_51,c2p2x1_8_c4b1_gen_bltroutptr-c2p2x1_8_c4b1_gen_bltnode(a1)
	moveq	#0,d0
	rts

c2p2x1_8_c4b1_gen_copyinitblock
	movem.l	a0-a1,-(sp)
	lea	c2p2x1_8_c4b1_gen_datanew,a0
	lea	c2p2x1_8_c4b1_gen_data,a1
	moveq	#16-1,d0
.copy	move.l	(a0)+,(a1)+
	dbf	d0,.copy
	movem.l	(sp)+,a0-a1
	rts

	cnop 0,4
c2p2x1_8_c4b1_gen_bltnode
	dc.l	0
c2p2x1_8_c4b1_gen_bltroutptr
	dc.l	0
	dc.b	$40,0
	dc.l	0
c2p2x1_8_c4b1_gen_bltroutcleanup
	dc.l	c2p2x1_8_c4b1_gen_blitcleanup
c2p2x1_8_c4b1_gen_blitfin dc.b 0
c2p2x1_8_c4b1_gen_blitactive dc.b 0

	cnop	0,4
c2p2x1_8_c4b1_gen_data
c2p2x1_8_c4b1_gen_screen dc.l	0
c2p2x1_8_c4b1_gen_scroffs dc.l 0
c2p2x1_8_c4b1_gen_scroffs2 dc.l 0
c2p2x1_8_c4b1_gen_bplsize dc.l 0
c2p2x1_8_c4b1_gen_pixels dc.l 0
c2p2x1_8_c4b1_gen_pixels16 dc.l 0
c2p2x1_8_c4b1_gen_blitbuf dc.l 0
	ds.l	16

	cnop 0,4
c2p2x1_8_c4b1_gen_datanew
	ds.l	16
