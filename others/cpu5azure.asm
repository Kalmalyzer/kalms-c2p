
;---------------------------------------------------------------------------
;5 pass cpu only c2p for 040/060 - 
;
;  ~13820us for 320x256 (216 rasterlines)
;  with no dma activated. 
;  (usual copyspeed is ~13960 us)
;
;(W) Mai 1998 by Tim Böscke aka. Azure
;
; azure@gmx.net
;
;This Chunky to Planar converter is converting/writing faster than
;a usual longword loop is copying from chipmem to fastmem. (Copyspeed)
;
;The barrier is broken .. :)
;
;This is possible due to some caching-tricks. 
;
;The trick is currently only tested on my 060/50. I have no idea, 
;whether it also works on 040/40. But this c2p should also be 
;copyspeed there. 
;
;Its probably still possible to improve the speed by about ~100us , since
;I was able to perform a fast to chip copy in about ~13725us.         
;This c2p was originally written about two years ago. It isnt the
;best c2p I have done, but it has a nice and compact code. So I choosed
;it to demonstrate this trick.  
; 
;
;---------------------------------------------------------------------------
;
;IN:
;
;	a0   =source
;	a1   =target
;
;----------------------------------------------------------------------------

	cnop	0,8
		
;MERGE		d1,d2,tmp,mask,shift

MERGE		MACRO	

	        move.l   \2,\3
	        lsr.l   #\5,\3
      	        eor.l    \1,\3
                and.l    \4,\3
                eor.l    \3,\1
                lsl.l   #\5,\3
                eor.l    \3,\2
		ENDM

MERGE1		MACRO	

	        move.l   \2,\3
	        lsr.l    #1,\3
      	        eor.l    \1,\3
                and.l    \4,\3
                eor.l    \3,\1
                add.l	 \3,\3
                eor.l    \3,\2
		ENDM
		
MERGEw		MACRO
		swap	\2
		eor.w	\1,\2
		eor.w	\2,\1
		eor.w	\1,\2
		swap	\2
		ENDM

a	
_chunky2planar:

.screensize=320*256
.plane=.screensize/8

		movem.l	d0-a6,-(a7)
		move.l	#.screensize,d0
	
		lea	(a0,d0.l),a2	
		move.l	a2,.smc+2

		movem.l	a0/a1/a6,-(a7)
		move.l	$4.w,a6
		jsr	-636(a6)	;flush caches	
		movem.l	(a7)+,a0/a1/a6

    		move.l	(a0),d0
		move.l	2*4+0(a0),d2
		move.l	4*4+0(a0),d4
		move.l	6*4+0(a0),d6

		MERGEw 	d0,d4
		MERGEw	d2,d6
		
		MERGE	d0,d2,d3,#$00FF00FF,8
		MERGE	d4,d6,d3,#$00FF00FF,8
		
    		move.l	1*4(a0),d1
		move.l  3*4(a0),d3
		move.l	5*4(a0),d5
		move.l	7*4(a0),d7

		adda.w	#32,a0
		move.l	d4,a6		;  d3->a6

		MERGEw	d1,d5
		add.l	#(.screensize/4)*1,a1
		MERGEw	d3,d7
		MERGE	d5,d7,d4,#$00FF00FF,8
		MERGE	d1,d3,d4,#$00FF00FF,8
		MERGE	d0,d1,d4,#$0F0F0F0F,4
		MERGE	d2,d3,d4,#$0F0F0F0F,4
		MERGE	d6,d7,d4,#$0F0F0F0F,4
		exg.l	d1,a6		;d4-> a6
		MERGE	d1,d5,d4,#$0F0F0F0F,4
		add.l	#(.screensize/4)*1,a1
		MERGE	d0,d1,d4,#$33333333,2
		MERGE	d2,d6,d4,#$33333333,2
		add.l	#(.screensize/4)*1+4,a1
		MERGE	d3,d7,d4,#$33333333,2
		exg.l	d1,a6		;d4=a6
		MERGE1	d0,d2,d4,#$55555555
		move.l	d0,.plane(a1)	;->Plane 7	
		exg.l	d0,a6
		MERGE	d1,d5,d4,#$33333333,2
		MERGE1	d0,d6,d4,#$55555555
		move.l	d0,a5
		MERGE1	d1,d3,d4,#$55555555
		move.l	d2,(a1)
		move.l	d6,a4
		move.l	d1,a3
		sub.l	#(.screensize/4)*3,a1
		MERGE1	d5,d7,d4,#$55555555
		move.l	d7,a6
		move.l	d3,a2
.loop
		tst.w	0*16+6(a0)
		tst.w	1*16+6(a0)
		tst.w	2*16+6(a0)
		tst.w	3*16+6(a0)

		tst.w	4*16+6(a0)
		tst.w	5*16+6(a0)
		tst.w	6*16+6(a0)
		tst.w	7*16+6(a0)	;this is the tricky part

		REPT	3

    		move.l	(a0),d0
		move.l	2*4+0(a0),d2
		move.l	4*4+0(a0),d4
		move.l	6*4+0(a0),d6

		move.l	d5,.plane(a1)	;  Plane 1

		MERGEw 	d0,d4
		MERGEw	d2,d6
		
		MERGE	d0,d2,d3,#$00FF00FF,8
		MERGE	d4,d6,d3,#$00FF00FF,8
		
    		move.l	1*4(a0),d1
		move.l  3*4(a0),d3
		move.l	5*4(a0),d5
		move.l	7*4(a0),d7

		adda.l	#32,a0
		move.l	a6,(a1)		;  Plane 0
		move.l	d4,a6		;  d3->a6

		MERGEw	d1,d5
		add.l	#(.screensize/4)*1,a1
		MERGEw	d3,d7

		move.l	a3,.plane(a1)	;	3

		MERGE	d5,d7,d4,#$00FF00FF,8
		MERGE	d1,d3,d4,#$00FF00FF,8
		MERGE	d0,d1,d4,#$0F0F0F0F,4
		MERGE	d2,d3,d4,#$0F0F0F0F,4
		move.l	a2,(a1)		;	2
		MERGE	d6,d7,d4,#$0F0F0F0F,4
		exg.l	d1,a6		;d4-> a6
		MERGE	d1,d5,d4,#$0F0F0F0F,4
		add.l	#(.screensize/4)*1,a1
		move.l	a5,.plane(a1)	;	5	
		
		MERGE	d0,d1,d4,#$33333333,2
		MERGE	d2,d6,d4,#$33333333,2
		move.l	a4,(a1)		;	4
		add.l	#(.screensize/4)*1+4,a1
		MERGE	d3,d7,d4,#$33333333,2
		exg.l	d1,a6		;d4=a6

		MERGE1	d0,d2,d4,#$55555555

		move.l	d0,.plane(a1)	;->Plane 7	
		
		exg.l	d0,a6

		MERGE	d1,d5,d4,#$33333333,2
		MERGE1	d0,d6,d4,#$55555555
		move.l	d0,a5
		MERGE1	d1,d3,d4,#$55555555
		move.l	d2,(a1)
		move.l	d6,a4
		move.l	d1,a3
		sub.l	#(.screensize/4)*3,a1
		MERGE1	d5,d7,d4,#$55555555
		move.l	d7,a6
		move.l	d3,a2

		ENDR
.smc
		cmp.l	#$0BADC0DE,a0
		bge.w	.quit

    		move.l	(a0),d0
		move.l	2*4+0(a0),d2
		move.l	4*4+0(a0),d4
		move.l	6*4+0(a0),d6

		move.l	d5,.plane(a1)	;  Plane 1

		MERGEw 	d0,d4
		MERGEw	d2,d6
		
		MERGE	d0,d2,d3,#$00FF00FF,8
		MERGE	d4,d6,d3,#$00FF00FF,8
		
    		move.l	1*4(a0),d1
		move.l  3*4(a0),d3
		move.l	5*4(a0),d5
		move.l	7*4(a0),d7

		adda.w	#32,a0
		move.l	a6,(a1)		;  Plane 0
		move.l	d4,a6		;  d3->a6

		MERGEw	d1,d5
		add.l	#(.screensize/4)*1,a1

		MERGEw	d3,d7
		
		move.l	a3,.plane(a1)	;	3
		MERGE	d5,d7,d4,#$00FF00FF,8
		MERGE	d1,d3,d4,#$00FF00FF,8
		MERGE	d0,d1,d4,#$0F0F0F0F,4
		move.l	a2,(a1)		;	2
		MERGE	d2,d3,d4,#$0F0F0F0F,4
		MERGE	d6,d7,d4,#$0F0F0F0F,4
		exg.l	d1,a6		;d4-> a6
		MERGE	d1,d5,d4,#$0F0F0F0F,4
		add.l	#(.screensize/4)*1,a1
		
		move.l	a5,.plane(a1)	;	5	
		
		MERGE	d0,d1,d4,#$33333333,2
		MERGE	d2,d6,d4,#$33333333,2
		move.l	a4,(a1)		;	4
		add.l	#(.screensize/4)*1+4,a1
		MERGE	d3,d7,d4,#$33333333,2
		exg.l	d1,a6		;d4=a6
		MERGE1	d0,d2,d4,#$55555555
		
		move.l	d0,.plane(a1)	;->Plane 7	

		exg.l	d0,a6
		MERGE	d1,d5,d4,#$33333333,2
		MERGE1	d0,d6,d4,#$55555555
		move.l	d0,a5
		MERGE1	d1,d3,d4,#$55555555
		move.l	d2,(a1)
		move.l	d6,a4
		move.l	d1,a3
		sub.l	#(.screensize/4)*3,a1
		MERGE1	d5,d7,d4,#$55555555
		move.l	d7,a6
		move.l	d3,a2

		bra.w	.loop
.quit		
		move.l	d5,.plane(a1)
		move.l	a6,(a1)		
		add.l	#(.screensize/4)*1,a1
		move.l	a3,.plane(a1)
		move.l	a2,(a1)	
		add.l	#(.screensize/4)*1,a1
		move.l	a5,.plane(a1)	
		move.l	a4,(a1)

		movem.l	(a7)+,d0-a6
		rts
		
b

