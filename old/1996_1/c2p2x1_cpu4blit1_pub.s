;				modulo	max res	fscreen	compu
; c2p2x1_cpu4blit1		no	320x256?  no	030

; 2x1 CPU4BLIT1 C2P (030 optimized)
; Date: 18 Sep 96
; Do not distribute under original name in modified form, please
;
; Here is a 2x1 C2P by Scout/C-Lous using the 18-cycle merge-op.
; It might very well be possible to improve the algo within (removing the
; 16-bit swapping), but I'm too tired to think about that now.
;
; On a Blizzard 030-50, a 160x128 conversion takes 87 scanlines CPU-
; processing, and approx. one frame Blitter processing.
;
; It is used like this:
;
;	move.w	#160,d0
;	move.w	#128,d1
;	moveq	#0,d3
;	move.l	#5120,d5
;	jsr	c2p2x1_cpu4blit1_init
;main:
;	lea	chunkybuf,a0
;	move.l	screenptr,a1
;	jsr	c2p2x1_cpu4blit1
;	bsr	draweffects
;	jsr	c2p_waitblit
;	bsr	swapscreens
;	bsr	vsync
;	btst	#6,$bfe001
;	bne.s	main
;
; Oh, and DON'T KILL THE WHOLE SYSTEM! For instance, if you do a
; move.w #$7fff,$dff09a, the QBlit() call won't work properly,
; and the c2p_waitblit call will then go into an infinite loop...
;
; The blit-wait should really use signals instead of busy-waiting,
; as the busy-waiting doesn't release any timeslices to the other
; running tasks, and if the chunkyscreen is small (which gives
; small blits) there is a slight chance of a deadlock. This only
; happens if you use the graphics.library/QBlit().
; <The window must be VERY small for that to happen, though...>
;
; Well, I think that's it...

	incdir	"include:"
	include	"graphics/graphics_lib.i"
	include	"hardware/custom.i"

	IFND	BPLX
BPLX	EQU	320
	ENDC
	IFND	BPLY
BPLY	EQU	128
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

	XREF	_GfxBase

	;section	c2p,code

qblit
; Use this or put your own queue-handler here
	move.l	a6,-(sp)
	move.l	_GfxBase,a6
	jsr	_LVOQBlit(a6)
	move.l	(sp)+,a6
	rts

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	bplsize [bytes] -- offset between one row in one bpl and the next bpl

c2p2x1_cpu4blit1_init
	movem.l	d2-d3,-(sp)
	lea	c2p_datanew(pc),a0
	andi.l	#$ffff,d0
	move.l	d5,c2p_bplsize-c2p_data(a0)
	move.w	d3,d2
	mulu.w	d0,d2
	lsr.l	#2,d2
	move.l	d2,c2p_scroffs-c2p_data(a0)
	add.w	d1,d3
	mulu.w	d0,d3
	lsr.l	#2,d3
	subq.w	#2,d3
	move.l	d3,c2p_scroffs2-c2p_data(a0)
	mulu.w	d0,d1
	move.l	d1,c2p_pixels-c2p_data(a0)
	lsr.l	#4,d1
	move.l	d1,c2p_pixels16-c2p_data(a0)
	movem.l	(sp)+,d2-d3
	rts

c2p_blitcleanup
	st	c2p_blitfin-c2p_bltnode(a1)
	sf	c2p_blitactive-c2p_bltnode(a1)
	rts

c2p_waitblit
	tst.b	c2p_blitactive(pc)
	beq.s	.n
.y	tst.b	c2p_blitfin(pc)
	beq.s	.y
.n	rts

; a0	c2pscreen
; a1	bitplanes

c2p2x1_cpu4blit1
	movem.l	d2-d7/a2-a6,-(sp)

	move.w	#.x2-.x,d0
	bsr.s	c2p_waitblit
	bsr	c2p_copyinitblock

	lea	c2p_data(pc),a2
	move.l	a1,c2p_screen-c2p_data(a2)

	lea	c2p_blitbuf,a1

	move.l	#$33333333,d4
	move.l	#$0f0f0f0f,d5
	move.l	#$00ff00ff,d6

	move.l	c2p_pixels-c2p_data(a2),a2
	add.l	a0,a2
	cmpa.l	a0,a2
	beq	.none

	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3

	swap	d2			; Swap 16x2
	move.w	d0,d7
	move.w	d2,d0
	move.w	d7,d2
	swap	d2

	swap	d3
	move.w	d1,d7
	move.w	d3,d1
	move.w	d7,d3
	swap	d3

	move.l	d2,d7			; Swap 4x2
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3

	bra.s	.start
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	move.l	d7,(a1)+

	swap	d2			; Swap 16x2
	move.w	d0,d7
	move.w	d2,d0
	move.w	d7,d2
	swap	d2

	swap	d3
	move.w	d1,d7
	move.w	d3,d1
	move.w	d7,d3
	swap	d3
	move.l	a3,(a1)+

	move.l	d2,d7			; Swap 4x2
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d5,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d5,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3
	move.l	a4,(a1)+
.start

	move.l	d1,d7			; Swap 8x1, part 1
	lsr.l	#8,d7
	eor.l	d0,d7
	and.l	d6,d7
	eor.l	d7,d0
	lsl.l	#8,d7
	eor.l	d7,d1

	move.l	d1,d7			; Swap 2x1, part 1
	lsr.l	#2,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#2,d7
	eor.l	d1,d7
	move.l	d0,(a1)+

	move.l	d3,d1			; Swap 8x1, part 2
	lsr.l	#8,d1
	eor.l	d2,d1
	and.l	d6,d1
	eor.l	d1,d2
	lsl.l	#8,d1
	eor.l	d1,d3

	move.l	d3,d1			; Swap 2x1, part 2
	lsr.l	#2,d1
	eor.l	d2,d1
	and.l	d4,d1
	eor.l	d1,d2
	lsl.l	#2,d1
	eor.l	d1,d3
	move.l	d2,a3
	move.l	d3,a4

	cmp.l	a0,a2
	bne.s	.x
.x2
	move.l	d7,(a1)+
	move.l	a3,(a1)+
	move.l	a4,(a1)+

;	lea	c2p_data(pc),a2
;	sf	c2p_blitfin-c2p_data(a2)
;	st	c2p_blitactive-c2p_data(a2)
;	lea	c2p_bltnode(pc),a1
;	move.l	#c2p2x1_cpu4blit1_queue_51,c2p_bltroutptr-c2p_bltnode(a1)
;	jsr	qblit

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

c2p2x1_cpu4blit1_queue_51
	move.w	#-1,bltafwm(a0)
	move.w	#-1,bltalwm(a0)
	move.l	#c2p_blitbuf+12,bltapt(a0)
	move.l	#c2p_blitbuf+12,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#12,bltamod(a0)
	move.w	#12,bltbmod(a0)
	move.w	#0,bltdmod(a0)
	move.w	#$aaaa,bltcdat(a0)
	move.w	#$0de4,bltcon0(a0)
	move.w	#$1000,bltcon1(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_cpu4blit1_queue_52,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_cpu4blit1_queue_52
	move.l	#c2p_blitbuf+8,bltapt(a0)
	move.l	#c2p_blitbuf+8,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_cpu4blit1_queue_53,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_cpu4blit1_queue_53
	move.l	#c2p_blitbuf+4,bltapt(a0)
	move.l	#c2p_blitbuf+4,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_cpu4blit1_queue_54,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_cpu4blit1_queue_54
	move.l	#c2p_blitbuf,bltapt(a0)
	move.l	#c2p_blitbuf,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	lsl.l	#3,d0
	sub.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_cpu4blit1_queue_55,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_cpu4blit1_queue_55
	move.l	#c2p_blitbuf-2,d0
	add.l	c2p_pixels-c2p_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs2-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$1de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_cpu4blit1_queue_56,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_cpu4blit1_queue_56
	move.l	#c2p_blitbuf-6,d0
	add.l	c2p_pixels-c2p_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs2-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$1de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_cpu4blit1_queue_57,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_cpu4blit1_queue_57
	move.l	#c2p_blitbuf-10,d0
	add.l	c2p_pixels-c2p_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs2-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$1de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_cpu4blit1_queue_58,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p2x1_cpu4blit1_queue_58
	move.l	#c2p_blitbuf-14,d0
	add.l	c2p_pixels-c2p_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	move.l	d0,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs2-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$1de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#2,bltsizh(a0)
	move.l	#c2p2x1_cpu4blit1_queue_51,c2p_bltroutptr-c2p_bltnode(a1)
	moveq	#0,d0
	rts

c2p_copyinitblock
	movem.l	a0-a1,-(sp)
	lea	c2p_datanew,a0
	lea	c2p_data,a1
	moveq	#16-1,d0
.copy	move.l	(a0)+,(a1)+
	dbf	d0,.copy
	movem.l	(sp)+,a0-a1
	rts

	cnop 0,4
c2p_bltnode
	dc.l	0
c2p_bltroutptr
	dc.l	0
	dc.b	$40,0
	dc.l	0
c2p_bltroutcleanup
	dc.l	c2p_blitcleanup
c2p_blitfin dc.b 0
c2p_blitactive dc.b 0

	cnop	0,4
c2p_data
c2p_screen dc.l	0
c2p_scroffs dc.l 0
c2p_scroffs2 dc.l 0
c2p_bplsize dc.l 0
c2p_pixels dc.l 0
c2p_pixels2 dc.l 0
c2p_pixels4 dc.l 0
c2p_pixels8 dc.l 0
c2p_pixels16 dc.l 0
c2p_chunkyx16 dc.w 0
c2p_chunkyx32 dc.w 0
c2p_chunkyy dc.w 0
c2p_rowmod dc.w	0
	ds.l	16

	cnop 0,4
c2p_datanew
	ds.l	16

	section	bss_c,bss_c

c2p_blitbuf
	ds.b	CHUNKYXMAX*CHUNKYYMAX
