;		mc68020
;		multipass
		section	text,code

;		opt	0	; PhxAss optimisations break this routine

*
*   c2p8_040_amlaukka.s - chunky to planar for bytes
*   by Aki Laukkanen <amlaukka@cc.helsinki.fi>
*
*   This file is public domain.
*

;	incdir	"INCLUDE:"
;	include "exec/types.i"
	include "exec/memory.i"
;	include "exec/libraries.i"
;	include "exec/exec_lib.i"
;	include "graphics/gfx.i"

	XDEF    _c2p8
	XDEF    @c2p8
	XDEF    _c2p8_reloc
	XDEF    @c2p8_reloc
	XDEF    _c2p8_deinit
	XDEF    @c2p8_deinit

patch	macro
;;;	move.l	d1,(\1-_c2p8+4,a0)	; This fails because of bug in PhxAss
	movea.l	#\1-_c2p8,a1		; so try this way instead.
	move.l	d1,(4,a0,a1.l)
	endm

	cnop    0,16

*
* void __asm *c2p8_reloc(register __a0 void *chunky,
*                        register __a1 struct BitMap *bitmap,
*                        register __a6 struct ExecBase *SysBase);
*

_c2p8_reloc
@c2p8_reloc
	movem.l a2/a3,-(sp)
	move.l  a0,a2
	move.l  a1,a3
	move.l  #_c2p8_end-_c2p8+15,d0
	move.l  #MEMF_FAST,d1
	jsr     (_LVOAllocVec,a6)
	tst.l   d0
	beq     .fail
	lea	(_c2p8_buf,pc),a0
	move.l	d0,(a0)			;store
	add.l	#15,d0
	and.l	#$fffffff0,d0		;align to 16 bytes (cache line size)
	move.l  d0,a0                   ; FIXME: align by cache line size (fixed by Andry)
					; and make changes to the c2p too.
	lea     (_c2p8,pc),a1
	move.w  #_c2p8_end-_c2p8-1,d1
.loop
	move.b  (a1)+,(a0)+
	subq.w	#1,d1
	bpl.s	.loop

	move.l  d0,a0
	move.l  (bm_Planes+4,a3),d1
	sub.l   (bm_Planes,a3),d1
	patch	c2p8_p1_1
	patch	c2p8_p1_2
	move.l  (bm_Planes+8,a3),d1
	sub.l   (bm_Planes,a3),d1
	patch	c2p8_p2_1
	patch	c2p8_p2_2
	move.l  (bm_Planes+12,a3),d1
	sub.l   (bm_Planes,a3),d1
	patch	c2p8_p3_1
	patch	c2p8_p3_2
	move.l  (bm_Planes+16,a3),d1
	sub.l   (bm_Planes,a3),d1
	patch	c2p8_p4_1
	patch	c2p8_p4_2
	move.l  (bm_Planes+20,a3),d1
	sub.l   (bm_Planes,a3),d1
	patch	c2p8_p5_1
	patch	c2p8_p5_2
	move.l  (bm_Planes+24,a3),d1
	sub.l   (bm_Planes,a3),d1
	patch	c2p8_p6_1
	patch	c2p8_p6_2
	move.l  (bm_Planes+28,a3),d1
	sub.l   (bm_Planes,a3),d1
	patch	c2p8_p7_1
	patch	c2p8_p7_2

	move.l  d0,a2
	jsr     (_LVOCacheClearU,a6)
	move.l  a2,d0

.fail
	movem.l (sp)+,a2/a3
	rts

_c2p8_buf	dc.l	0

	cnop    0,16

*
*   void __asm c2p8_deinit(register __a6 struct ExecBase *SysBase);
*

_c2p8_deinit
@c2p8_deinit
	move.l  (_c2p8_buf,pc),a1
	jsr     (_LVOFreeVec,a6)
	rts

*
*   void __asm c2p8(register __a0 const void *chunky,
*                   register __a1 void *chip,
*                   register __a2 const void *chunky_end);
*

_c2p8
@c2p8
	movem.l d2-d7/a2-a6,-(sp)
	move.l  a0,a6
	move.l  a2,a3
	move.l  a1,a2
c2p8_start
; a6 - chunky
; a2 - bitplanes
; a3 - chunky end

	move.l  (a6)+,d0
	move.l  (a6)+,d1
	move.l  (a6)+,d2
	move.l  (a6)+,d3
	move.l  (a6)+,d4
	move.l  (a6)+,d5
	move.l  (a6)+,d6
	move.l  (a6)+,a0

; 16x4: (d0,d4),(d2,d6),(d1,d5)
; 2x4: (d0,d4),(d2,d6),(d1,d5)
; 16x4: (d3,d7)
; 2x4: (d3,d7)
; 8x2: (d0,d2),(d1,d3)
; 1x2: (d0,d2),(d1,d3)
; 4x1: (d0,d1)
; write d0
; 4x1: (d2,d3)
; 8x2: (d4,d6),(d5,d7)
; 1x2: (d4,d6),(d5,d7)
; 4x1: (d4,d5),(d6,d7)

; 16x4: (d0,d4),(d1,d5),(d2,d6)
	swap    d4
	swap    d5
	swap    d6
	eor.w   d4,d0
	eor.w   d5,d1
	eor.w   d6,d2
	eor.w   d0,d4
	eor.w   d1,d5
	eor.w   d2,d6
	eor.w   d4,d0
	eor.w   d5,d1
	eor.w   d6,d2
	swap    d4
	swap    d5
	swap    d6

; 2x4: (d0,d4),(d1,d5),(d2,d6)
	move.l  d4,d7
	lsr.l   #2,d7
	eor.l   d0,d7
	and.l   #$33333333,d7
	eor.l   d7,d0
	lsl.l   #2,d7
	eor.l   d7,d4

	move.l  d5,d7
	lsr.l   #2,d7
	eor.l   d1,d7
	and.l   #$33333333,d7
	eor.l   d7,d1
	lsl.l   #2,d7
	eor.l   d7,d5

	move.l  d6,d7
	lsr.l   #2,d7
	eor.l   d2,d7
	and.l   #$33333333,d7
	eor.l   d7,d2
	lsl.l   #2,d7
	eor.l   d7,d6

	exg     a0,d6           ; d7 -> d6
							; d6 -> a2

; 16x4: (d3,d7)

	swap    d6
	eor.w   d6,d3
	eor.w   d3,d6
	eor.w   d6,d3
	swap    d6

; 2x4 (d3,d7)

	move.l  d6,d7
	lsr.l   #2,d7
	eor.l   d3,d7
	and.l   #$33333333,d7
	eor.l   d7,d3
	lsl.l   #2,d7
	eor.l   d7,d6

; 8x2: (d0,d2),(d1,d3)

	move.l  d2,d7
	lsr.l   #8,d7
	eor.l   d0,d7
	and.l   #$00ff00ff,d7
	eor.l   d7,d0
	lsl.l   #8,d7
	eor.l   d7,d2

	move.l  d3,d7
	lsr.l   #8,d7
	eor.l   d1,d7
	and.l   #$00ff00ff,d7
	eor.l   d7,d1
	lsl.l   #8,d7
	eor.l   d7,d3

; 1x2: (d0,d2),(d1,d3)

	move.l  d2,d7
	lsr.l   #1,d7
	eor.l   d0,d7
	and.l   #$55555555,d7
	eor.l   d7,d0
	add.l   d7,d7
	eor.l   d7,d2

	move.l  d3,d7
	lsr.l   #1,d7
	eor.l   d1,d7
	and.l   #$55555555,d7
	eor.l   d7,d1
	add.l   d7,d7
	eor.l   d7,d3

; 4x1: (d0,d1)

	move.l  d1,d7
	lsr.l   #4,d7
	eor.l   d0,d7
	and.l   #$0f0f0f0f,d7
	eor.l   d7,d0
c2p8_p7_1
	move.l  d0,($12341234.l,a2)
	lsl.l   #4,d7
	eor.l   d7,d1

; 4x1: (d2,d3)

	move.l  d3,d7
	lsr.l   #4,d7
	eor.l   d2,d7
	and.l   #$0f0f0f0f,d7
	eor.l   d7,d2
	lsl.l   #4,d7
	eor.l   d7,d3

	move.l  a0,d0               ; d6 -> d0

; 8x2: (d4,d6),(d5,d7)

	move.l  d0,d7
	lsr.l   #8,d7
	eor.l   d4,d7
	and.l   #$00ff00ff,d7
c2p8_p3_1
	move.l  d1,($12341234.l,a2)
	eor.l   d7,d4
	lsl.l   #8,d7
	eor.l   d7,d0

	move.l  d6,d7
	lsr.l   #8,d7
	eor.l   d5,d7
	and.l   #$00ff00ff,d7
	eor.l   d7,d5
	lsl.l   #8,d7
	eor.l   d7,d6

; 1x2: (d4,d6),(d5,d7)

	move.l  d0,d7
	lsr.l   #1,d7
	eor.l   d4,d7
	and.l   #$55555555,d7
c2p8_p6_1
	move.l  d2,($12341234.l,a2)
	eor.l   d7,d4
	add.l   d7,d7
	eor.l   d7,d0

	move.l  d6,d7
	lsr.l   #1,d7
	eor.l   d5,d7
	and.l   #$55555555,d7
	eor.l   d7,d5

	add.l   d7,d7
	eor.l   d7,d6

; 4x1: (d4,d5),(d6,d7)

	move.l  d5,d7
	lsr.l   #4,d7
	eor.l   d4,d7
	and.l   #$0f0f0f0f,d7
c2p8_p2_1
	move.l  d3,($12341234.l,a2)
	eor.l   d7,d4
	lsl.l   #4,d7
	eor.l   d7,d5

	move.l  d6,d7
	lsr.l   #4,d7
	eor.l   d0,d7
	and.l   #$0f0f0f0f,d7
	eor.l   d7,d0
	lsl.l   #4,d7
	eor.l   d7,d6

	move.l  d4,d7
	move.l  d5,a4
	move.l  d0,a5
	move.l  d6,a1

	cmp.l   a3,a6
	beq     c2p8_end
c2p8_x1
	move.l  (a6)+,d0
	move.l  (a6)+,d1
	move.l  (a6)+,d2
	move.l  (a6)+,d3
	move.l  (a6)+,d4
	move.l  (a6)+,d5
	move.l  (a6)+,d6
	move.l  (a6)+,a0

c2p8_p5_1
	move.l  d7,($12341234.l,a2)

; 16x4: (d0,d4),(d1,d5),(d2,d6)
	swap    d4
	swap    d5
	swap    d6
	eor.w   d4,d0
	eor.w   d5,d1
	eor.w   d6,d2
	eor.w   d0,d4
	eor.w   d1,d5
	eor.w   d2,d6
	eor.w   d4,d0
	eor.w   d5,d1
	eor.w   d6,d2
	swap    d4
	swap    d5
	swap    d6
; 2x4: (d0,d4),(d1,d5),(d2,d6)
	move.l  d4,d7
	lsr.l   #2,d7
	eor.l   d0,d7
c2p8_p1_1
	move.l  a4,($12341234.l,a2)
	and.l   #$33333333,d7
	eor.l   d7,d0
	lsl.l   #2,d7
	eor.l   d7,d4

	move.l  d5,d7
	lsr.l   #2,d7
	eor.l   d1,d7
	and.l   #$33333333,d7
	eor.l   d7,d1
	lsl.l   #2,d7
	eor.l   d7,d5

	move.l  d6,d7
	lsr.l   #2,d7
	eor.l   d2,d7
	and.l   #$33333333,d7
	eor.l   d7,d2
	lsl.l   #2,d7
	eor.l   d7,d6
	exg     a0,d6           ; d7 -> d6
							; d6 -> a2
; 16x4: (d3,d7)

	swap    d6
c2p8_p4_1
	move.l  a5,($12341234.l,a2)
	eor.w   d6,d3
	eor.w   d3,d6
	eor.w   d6,d3
	swap    d6

; 2x4 (d3,d7)

	move.l  d6,d7
	lsr.l   #2,d7
	eor.l   d3,d7
	and.l   #$33333333,d7
	eor.l   d7,d3
	lsl.l   #2,d7
	eor.l   d7,d6

; 8x2: (d0,d2),(d1,d3)

	move.l  d2,d7
	lsr.l   #8,d7
	eor.l   d0,d7
	and.l   #$00ff00ff,d7
	eor.l   d7,d0
	lsl.l   #8,d7
	eor.l   d7,d2

	move.l  d3,d7
	lsr.l   #8,d7
	eor.l   d1,d7
	and.l   #$00ff00ff,d7
	move.l  a1,(a2)+
	eor.l   d7,d1
	lsl.l   #8,d7
	eor.l   d7,d3

; 1x2: (d0,d2),(d1,d3)

	move.l  d2,d7
	lsr.l   #1,d7
	eor.l   d0,d7
	and.l   #$55555555,d7
	eor.l   d7,d0
	add.l   d7,d7
	eor.l   d7,d2

	move.l  d3,d7
	lsr.l   #1,d7
	eor.l   d1,d7
	and.l   #$55555555,d7
	eor.l   d7,d1
	add.l   d7,d7
	eor.l   d7,d3

; 4x1: (d0,d1)

	move.l  d1,d7
	lsr.l   #4,d7
	eor.l   d0,d7
	and.l   #$0f0f0f0f,d7
	eor.l   d7,d0
c2p8_p7_2
	move.l  d0,($12341234.l,a2)
	lsl.l   #4,d7
	eor.l   d7,d1

; 4x1: (d2,d3)

	move.l  d3,d7
	lsr.l   #4,d7
	eor.l   d2,d7
	and.l   #$0f0f0f0f,d7
	eor.l   d7,d2
	lsl.l   #4,d7
	eor.l   d7,d3

	move.l  a0,d0               ; d6 -> d0

; 8x2: (d4,d6),(d5,d7)

	move.l  d0,d7
	lsr.l   #8,d7
	eor.l   d4,d7
	and.l   #$00ff00ff,d7
c2p8_p3_2
	move.l  d1,($12341234.l,a2)
	eor.l   d7,d4
	lsl.l   #8,d7
	eor.l   d7,d0

	move.l  d6,d7
	lsr.l   #8,d7
	eor.l   d5,d7
	and.l   #$00ff00ff,d7
	eor.l   d7,d5
	lsl.l   #8,d7
	eor.l   d7,d6

; 1x2: (d4,d6),(d5,d7)

	move.l  d0,d7
	lsr.l   #1,d7
	eor.l   d4,d7
	and.l   #$55555555,d7
c2p8_p6_2
	move.l  d2,($12341234.l,a2)
	eor.l   d7,d4
	add.l   d7,d7
	eor.l   d7,d0

	move.l  d6,d7
	lsr.l   #1,d7
	eor.l   d5,d7
	and.l   #$55555555,d7
	eor.l   d7,d5
	add.l   d7,d7
	eor.l   d7,d6

; 4x1: (d4,d5),(d6,d7)

	move.l  d5,d7
	lsr.l   #4,d7
	eor.l   d4,d7
	and.l   #$0f0f0f0f,d7
c2p8_p2_2
	move.l  d3,($12341234.l,a2)
	eor.l   d7,d4
	lsl.l   #4,d7
	eor.l   d7,d5

	move.l  d6,d7
	lsr.l   #4,d7
	eor.l   d0,d7
	and.l   #$0f0f0f0f,d7
	eor.l   d7,d0
	lsl.l   #4,d7
	eor.l   d7,d6

	move.l  d4,d7
	move.l  d5,a4
	move.l  d0,a5
	move.l  d6,a1

	cmp.l   a3,a6
	bne     c2p8_x1
c2p8_end
c2p8_p5_2
	move.l  d7,($12341234.l,a2)
c2p8_p1_2
	move.l  a4,($12341234.l,a2)
c2p8_p4_2
	move.l  a5,($12341234.l,a2)
	move.l  a1,(a2)

	movem.l (sp)+,d2-d7/a2-a6
	rts
_c2p8_end

	end
