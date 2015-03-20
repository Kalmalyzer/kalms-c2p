; 1x1 6BPL CPU3BLIT1 C2P  (030 optimized)
; Release date: 2 Sep 96
; 6bpl-version C2P.
;
; An example of how to use this routine:
;
;	move.w	#320,d0
;	move.w	#256,d1
;	clr.w	d3
;	move.l	#10240,d5
;	bsr	c2p1x1_64_cpu3blit1_queue_init
;	...
;main:
;	lea	chunkyscreen,a0
;	move.l	screenptr,a1
;	bsr	c2p1x1_64_cpu3blit1_queue
;	bsr	effect
;	btst	#6,$bfe001
;	bne.s	main
;
; The screenswapping should be done in the c2p_waitblit routine,
; which is called by the C2P rout.
;
; I hope I didn't forget anything... :)
;

	IFND	C2P_DOUBLEBUFFER
C2P_DOUBLEBUFFER EQU 1
	ENDC
	IFND	CHUNKYXMAX
CHUNKYXMAX EQU	320
	ENDC
	IFND	CHUNKYYMAX
CHUNKYYMAX EQU	256
	ENDC

	section	c2p,code

;qblit
; Use this or put your own queue-handler here
	move.l	a6,-(sp)
	move.l	gfxbase,a6
	jsr	_LVOQBlit(a6)
	move.l	(sp)+,a6
	rts

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d3.w	scroffsy [screen-pixels]
; d5.l	bplsize [bytes] -- offset between one row in one bpl and the next bpl

c2p1x1_64_cpu3blit1_queue_init
	movem.l	d2-d3,-(sp)
	lea	c2p_datanew(pc),a0
	andi.l	#$ffff,d0
	andi.l	#$ffff,d2
	move.l	d5,c2p_bplsize-c2p_data(a0)
	move.w	d1,c2p_chunkyy-c2p_data(a0)
	add.w	d3,d1
	mulu.w	d0,d1
	lsr.l	#3,d1
	subq.l	#2,d1
	move.l	d1,c2p_scroffs2-c2p_data(a0)
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p_scroffs-c2p_data(a0)
	move.w	c2p_chunkyy-c2p_data(a0),d1
	mulu.w	d0,d1
	move.l	d1,c2p_pixels-c2p_data(a0)
	move.l	d1,d2
	add.l	d2,d2
	add.l	d1,d2
	lsr.l	#2,d2
	move.l	d2,c2p_pixels34-c2p_data(a0)
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
.n
; This is where you would add your swap-screens-code.
	rts

; a0	c2pscreen
; a1	bitplanes

c2p1x1_64_cpu3blit1_queue
	movem.l	d2-d7/a2-a6,-(sp)

	IFEQ	C2P_DOUBLEBUFFER
	bsr.s	c2p_waitblit
	ENDC

	lea	c2p_datanew(pc),a2
	move.l	a1,c2p_screen-c2p_data(a2)

	move.l	#$0f0f0f0f,a4
	move.l	#$00ff00ff,a5
	move.l	#$55555555,a6

	move.l	c2p_bufptrs,a1
	move.l	c2p_pixels-c2p_data(a2),a2
	add.l	a0,a2
	cmpa.l	a0,a2
	beq	.none

	move.l	(a0)+,d0
	move.l	(a0)+,d6
	move.l	(a0)+,a3
	move.l	(a0)+,d7
	move.l	a4,d5
	move.l	d6,d1			; Swap 4x1
	lsr.l	#4,d1
	eor.l	d0,d1
	and.l	d5,d1
	eor.l	d1,d0
	lsl.l	#4,d1
	eor.l	d6,d1

	move.l	a3,d6
	move.l	d7,d4
	lsr.l	#4,d4
	eor.l	d6,d4
	and.l	d5,d4
	eor.l	d4,d6
	lsl.l	#4,d4
	eor.l	d4,d7

	move.l	a5,d5
	move.l	d6,d2			; Swap 8x2, part 1
	lsr.l	#8,d2
	eor.l	d0,d2
	and.l	d5,d2
	eor.l	d2,d0
	lsl.l	#8,d2
	eor.l	d6,d2

	bra.s	.start
.x
	move.l	(a0)+,d0
	move.l	(a0)+,d6
	move.l	(a0)+,a3
	move.l	(a0)+,d7
	move.l	d1,(a1)+
	move.l	a4,d5
	move.l	d6,d1			; Swap 4x1
	lsr.l	#4,d1
	eor.l	d0,d1
	and.l	d5,d1
	eor.l	d1,d0
	lsl.l	#4,d1
	eor.l	d6,d1

	move.l	a3,d6
	move.l	d7,d4
	lsr.l	#4,d4
	eor.l	d6,d4
	and.l	d5,d4
	eor.l	d4,d6
	lsl.l	#4,d4
	eor.l	d4,d7

	move.l	a5,d5
	move.l	d6,d2			; Swap 8x2, part 1
	move.l	d3,(a1)+
	lsr.l	#8,d2
	eor.l	d0,d2
	and.l	d5,d2
	eor.l	d2,d0
	lsl.l	#8,d2
	eor.l	d6,d2
.start
	move.l	a6,d4
	move.l	d2,d3			; Swap 1x2, part 1
	lsr.l	d3
	eor.l	d0,d3
	and.l	d4,d3
	eor.l	d3,d0
	add.l	d3,d3
	eor.l	d3,d2
	lsl.l	#2,d0
	or.l	d2,d0

	move.l	d7,d3			; Swap 8x2, part 2
	lsr.l	#8,d3
	move.l	d0,(a1)+
	eor.l	d1,d3
	and.l	d5,d3
	eor.l	d3,d1
	lsl.l	#8,d3
	eor.l	d7,d3

	move.l	d3,d6			; Swap 1x2, part 2
	lsr.l	d6
	eor.l	d1,d6
	and.l	d4,d6
	eor.l	d6,d1
	add.l	d6,d6
	eor.l	d6,d3

	move.l	(a0)+,d0
	move.l	(a0)+,d6
	move.l	(a0)+,a3
	move.l	(a0)+,d7
	move.l	d1,(a1)+
	move.l	a4,d5
	move.l	d6,d1			; Swap 4x1
	lsr.l	#4,d1
	eor.l	d0,d1
	and.l	d5,d1
	eor.l	d1,d0
	lsl.l	#4,d1
	eor.l	d6,d1

	move.l	a3,d6
	move.l	d7,d4
	lsr.l	#4,d4
	eor.l	d6,d4
	and.l	d5,d4
	eor.l	d4,d6
	lsl.l	#4,d4
	eor.l	d4,d7

	move.l	a5,d5
	move.l	d6,d2			; Swap 8x2, part 1
	lsr.l	#8,d2
	move.l	d3,(a1)+
	eor.l	d0,d2
	and.l	d5,d2
	eor.l	d2,d0
	lsl.l	#8,d2
	eor.l	d6,d2
	move.l	a6,d4

	move.l	d2,d3			; Swap 1x2, part 1
	lsr.l	d3
	eor.l	d0,d3
	and.l	d4,d3
	eor.l	d3,d0
	add.l	d3,d3
	eor.l	d3,d2
	lsl.l	#2,d0
	or.l	d2,d0


	move.l	d7,d3			; Swap 8x2, part 2
	lsr.l	#8,d3
	move.l	d0,(a1)+
	eor.l	d1,d3
	and.l	d5,d3
	eor.l	d3,d1
	lsl.l	#8,d3
	eor.l	d7,d3

	move.l	d3,d6			; Swap 1x2, part 2
	lsr.l	d6
	eor.l	d1,d6
	and.l	d4,d6
	eor.l	d6,d1
	add.l	d6,d6
	eor.l	d6,d3

	cmp.l	a0,a2
	bne	.x
.x2
	move.l	d1,(a1)+
	move.l	d3,(a1)+

	IFNE	C2P_DOUBLEBUFFER
	bsr	c2p_waitblit
	move.l	c2p_bufptrs,d0
	move.l	c2p_bufptrs+4,c2p_bufptrs
	move.l	d0,c2p_bufptrs+4
	ENDC

	bsr	c2p_copyinitblock

	lea	c2p_data(pc),a2
	sf	c2p_blitfin-c2p_data(a2)
	st	c2p_blitactive-c2p_data(a2)
	lea	c2p_bltnode(pc),a1
	move.l	#c2p1x1_64_cpu3blit1_queue_41,c2p_bltroutptr-c2p_bltnode(a1)
	jsr	qblit

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

c2p1x1_64_cpu3blit1_queue_41		; Pass 4, subpass 1, ascending
	move.w	#-1,bltafwm(a0)
	move.w	#-1,bltalwm(a0)
	move.l	c2p_bufptrs+4,d0
	addq.l	#8,d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#10,bltamod(a0)
	move.w	#10,bltbmod(a0)
	move.w	#0,bltdmod(a0)
	move.w	#$cccc,bltcdat(a0)
	move.w	#$0de4,bltcon0(a0)
	move.w	#$2000,bltcon1(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_64_cpu3blit1_queue_42,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p1x1_64_cpu3blit1_queue_42		; Pass 4, subpass 2, ascending
	move.l	c2p_bufptrs+4,d0
	addq.l	#4,d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	d0,d0
	add.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_64_cpu3blit1_queue_43,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p1x1_64_cpu3blit1_queue_43		; Pass 4, subpass 3, ascending
	move.l	c2p_bufptrs+4,d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_64_cpu3blit1_queue_44,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p1x1_64_cpu3blit1_queue_44		; Pass 4, subpass 4, descending
	move.l	c2p_bufptrs+4,d0
	subq.l	#4,d0
	add.l	c2p_pixels34-c2p_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs2-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	#$2de4,bltcon0(a0)
	move.w	#$0002,bltcon1(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_64_cpu3blit1_queue_45,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p1x1_64_cpu3blit1_queue_45		; Pass 4, subpass 5, descending
	move.l	c2p_bufptrs+4,d0
	subq.l	#8,d0
	add.l	c2p_pixels34-c2p_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs2-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
	move.l	#c2p1x1_64_cpu3blit1_queue_46,c2p_bltroutptr-c2p_bltnode(a1)
	rts

c2p1x1_64_cpu3blit1_queue_46		; Pass 4, subpass 6, descending
	move.l	c2p_bufptrs+4,d0
	sub.l	#12,d0
	add.l	c2p_pixels34-c2p_bltnode(a1),d0
	move.l	d0,bltapt(a0)
	addq.l	#2,d0
	move.l	d0,bltbpt(a0)
	move.l	c2p_bplsize-c2p_bltnode(a1),d0
	lsl.l	#2,d0
	add.l	c2p_screen-c2p_bltnode(a1),d0
	add.l	c2p_scroffs2-c2p_bltnode(a1),d0
	move.l	d0,bltdpt(a0)
	move.w	c2p_pixels16+2-c2p_bltnode(a1),bltsizv(a0)
	move.w	#1,bltsizh(a0)
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
c2p_pixels16 dc.l 0
c2p_pixels34 dc.l 0
c2p_chunkyy dc.w 0
	ds.l	16

	cnop 0,4
c2p_datanew
	ds.l	16

c2p_bufptrs
	dc.l	c2p_blitbuf
	IFEQ	C2P_DOUBLEBUFFER
	dc.l	c2p_blitbuf
	ELSE
	dc.l	c2p_blitbuf+CHUNKYXMAX*CHUNKYYMAX*3/4
	ENDC

	section	bss_c,bss_c

	even	bss_cbegin,4
c2p_blitbuf
	ds.b	CHUNKYXMAX*CHUNKYYMAX*3/4
	IFNE	C2P_DOUBLEBUFFER
	ds.b	CHUNKYXMAX*CHUNKYYMAX*3/4
	ENDC
