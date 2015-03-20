;---------------------------------------------------------------------------
;5 Pass CPU Chunky to Planar Converter for 68040/60
;
; This c2p is enhanced for slow 060-boards like the Blizzard 1260 and
; Apollo 1260.
;
; Tested: Copyspeed on Apollo 1240/40, Apollo 4040/40 , Apollo 1260/50
;         its probably copyspeed on all 4060 boards, all 1240/40 boards and
;         all 4040/40 boards. On slower 040 boards it should perform well,
;         too. I hope it is copyspeed on Blizzard 1260/50,too.
;
;(W) and (C) 6-7.5.1997 by Tim Boescke
;                       Azure/Artwork
;
;
;This converter is using enhanced and paired mergeops (rot-merges) taking  
;3 cycles per merge on 060, 8 cycles per merge on 040. Plus a little overhead
;for final rot-correction. The disadvantage is, that the 16bit merge is slighty
;slower now on 040.
;
;Effective cycles taken for 8lw c2p:
;
;                               040               060
;       
;rot paired       merge         169               61.5  
;normal paired    merge         168               68
;non paired       merge         168              ~132-152       
;                               
;
;IN:
;
;       a0   =source
;       a1   =target
;
;NOTE!!!! : Dont use any optimizations when assembling this! Especially
;           not with PHXass. The generated code might not work otherwise.
;---------------------------------------------------------------------------


        opt l+
        machine mc68020

        XDEF _chunky2planarcpu5

_chunky2planarcpu5:

USEA7   equ     0       ;1 = use a7 ,0 = dont use a7
                        ;NoA7 uses selfmodifying code with cacheflush
                        ;its applied every time you change the chunkybuffers
                        ;location. (a0=source) So changing it a lot of times
                        ;could slow the c2p down a bit.
                        
.screensize=320*200
.plane=320*240/8

                movem.l d0-d7/a2-a6,-(a7)
                tst.l   .firsttime
                bne.w   .norealign
                bsr.w   .realign
.norealign:             
                move.l  #.screensize,d0
                lea     (a0,d0.l),a2    ;a7=endpointer

                add.l   #5*.plane-4,a1
        ifeq  (1-USEA7)

                move.l  a7,.a7save
                move.l  a2,a7
        else
                move.l  .smchere(pc),a3
                cmp.l   (a3),a2
                beq.s   .nomod
                move.l  a2,(a3)

                movem.l a0/a1,-(a7)
                move.l  4.w,a6
                jsr     -636(a6)          ;cacheflush
                movem.l (a7)+,a0/a1
.nomod                                          
        endc

                move.l  (a0)+,d0
                move.l  (a0)+,d1
                move.l  (a0)+,d2
                move.l  (a0)+,d3
                move.l  (a0)+,d4
                move.l  (a0)+,a3
                move.l  (a0)+,d6
                move.l  (a0)+,a2
                swap    d4              
                swap    d6              
                eor.w   d0,d4           
                eor.w   d2,d6           
                eor.w   d4,d0           
                eor.w   d6,d2                   
                eor.w   d0,d4           
                eor.w   d2,d6           
                ror.l   #8,d2           
                rol.l   #8,d4           
                move.l  d6,d7           
                move.l  d2,d5                   
                eor.l   d4,d7           
                eor.l   d0,d5           
                and.l   #$00FF00FF,d5   
                and.l   #$FF00FF00,d7   
                eor.l   d5,d0           
                eor.l   d7,d4           
                eor.l   d5,d2           
                eor.l   d7,d6           
                rol.l   #6,d4           
                rol.l   #6,d6           
                move.l  d4,d5
                move.l  d6,d7
                eor.l   d0,d5
                eor.l   d2,d7
                and.l   #$33333333,d5   
                and.l   #$33333333,d7
                eor.l   d5,d0
                eor.l   d7,d2
                eor.l   d5,d4 
                eor.l   d7,d6
                rol.l   #4,d2
                rol.l   #4,d6
                move.l  a2,d7
                move.l  a3,d5           
                move.l  d6,a2
                move.l  d4,a3
                swap    d5              
                swap    d7              
                eor.w   d1,d5           
                eor.w   d3,d7           
                eor.w   d5,d1           
                eor.w   d7,d3                   
                eor.w   d1,d5           
                eor.w   d3,d7           
                ror.l   #8,d3
                rol.l   #8,d5
                move.l  d7,d6           
                move.l  d3,d4           
                eor.l   d5,d6           
                eor.l   d1,d4
                and.l   #$00FF00FF,d4   
                and.l   #$FF00FF00,d6
                eor.l   d4,d1
                eor.l   d6,d5
                eor.l   d4,d3
                eor.l   d6,d7           
                rol.l   #6,d5
                rol.l   #6,d7
                move.l  d5,d4
                move.l  d7,d6
                eor.l   d1,d4
                eor.l   d3,d6
                and.l   #$33333333,d4   
                and.l   #$33333333,d6
                eor.l   d4,d1
                eor.l   d6,d3
                eor.l   d4,d5 
                eor.l   d6,d7
                ror.l   #4,d1
                ror.l   #4,d5

        move.l  a2,d6
        move.l  d5,a2

                REPT    4       ;space for realigning
                move.l  a1,a1   ;pipelined/superscalar nop
                move.l  a2,a2   ;(Note: the real NOP is more than a
                                ; No-Operation. It does Pipeline-Sync and
                                ; is dead slow that way)
                                ;asm-one isnt assembling trapf
                ENDR
.alignhere
                bra.w   .enter_here
                rept    3       
                move.l  a1,a1
                move.l  a2,a2
                endr
.loop
        move.l  (a0)+,d0
        move.l  (a0)+,d1
        move.l  (a0)+,d2
        move.l  (a0)+,d3
        move.l  (a0)+,d4
        move.l  (a0)+,a3
        move.l  (a0)+,d6
        move.l  (a0)+,a2
        move.l  d7,(a1)
                swap    d4      
                swap    d6
                eor.w   d0,d4
                eor.w   d2,d6           
                eor.w   d4,d0           
                eor.w   d6,d2                   
                eor.w   d0,d4           
                eor.w   d2,d6           
        add.l   #.plane,a1
                ror.l   #8,d2           
                rol.l   #8,d4           
        move.l  d5,(a1)
                move.l  d6,d7            
                move.l  d2,d5                   
                eor.l   d4,d7           
                eor.l   d0,d5           
                and.l   #$00FF00FF,d5   
                and.l   #$FF00FF00,d7   
                eor.l   d5,d0           
                eor.l   d7,d4           
                eor.l   d5,d2           
                eor.l   d7,d6           
                rol.l   #6,d4           
                rol.l   #6,d6           
        add.l   #.plane,a1
                move.l  d4,d5
                move.l  d6,d7
                eor.l   d0,d5
                eor.l   d2,d7
                and.l   #$33333333,d5    
                and.l   #$33333333,d7
                eor.l   d5,d0
                eor.l   d7,d2
                eor.l   d5,d4 
        move.l  a4,(a1)
                eor.l   d7,d6
                rol.l   #4,d2
                rol.l   #4,d6
        move.l  a2,d7
        move.l  a3,d5           
        move.l  d6,a2
        move.l  d4,a3
                swap    d5              
                swap    d7              
                eor.w   d1,d5           
                eor.w   d3,d7           
                eor.w   d5,d1           
                eor.w   d7,d3                   
                eor.w   d1,d5           
                eor.w   d3,d7           
        add.l   #2*.plane,a1
                ror.l   #8,d3
                rol.l   #8,d5
                move.l  d7,d6           
                move.l  d3,d4           
                eor.l   d5,d6           
        move.l  a5,(a1)
                eor.l   d1,d4
                and.l   #$00FF00FF,d4   
                and.l   #$FF00FF00,d6
                eor.l   d4,d1
                eor.l   d6,d5
                eor.l   d4,d3
                eor.l   d6,d7           
                rol.l   #6,d5
                rol.l   #6,d7
                move.l  d5,d4
                move.l  d7,d6
                eor.l   d1,d4
                eor.l   d3,d6
        add.w   #.plane,a1
                and.l   #$33333333,d4   
                and.l   #$33333333,d6
                eor.l   d4,d1
                eor.l   d6,d3
                eor.l   d4,d5 
                eor.l   d6,d7

                ror.l   #4,d1
                ror.l   #4,d5

        move.l  a2,d6
        move.l  d5,a2
        move.l  a6,(a1)
.enter_here
                move.l  d1,d4
                move.l  d3,d5
                eor.l   d0,d4
                eor.l   d2,d5
                and.l   #$0F0F0F0F,d4   
                and.l   #$F0F0F0F0,d5
                eor.l   d4,d0
                eor.l   d5,d2
                eor.l   d4,d1
                eor.l   d5,d3
                rol.l   #3,d2
                rol.l   #3,d3
                move.l  d2,d4
                move.l  d3,d5
                eor.l   d0,d4
                eor.l   d1,d5
                and.l   #$55555555,d4   
                and.l   #$55555555,d5
        add.l   #(2*.plane)+4,a1
                eor.l   d4,d0
                eor.l   d5,d1
        move.l  d0,(a1)
                eor.l   d4,d2
                eor.l   d5,d3
                rol.l   #4,d1
                rol.l   #1,d2
                rol.l   #5,d3
        move.l  a3,d4
        move.l  a2,d5
        move.l  d3,a4
                move.l  d5,d0
                move.l  d7,d3
                eor.l   d4,d0
                eor.l   d6,d3
        sub.l   #4*.plane,a1
                and.l   #$C3C3C3C3,d0
                and.l   #$3C3C3C3C,d3   
        move.l  d1,(a1)
                eor.l   d0,d4
                eor.l   d3,d6
                eor.l   d0,d5
                eor.l   d3,d7
                rol.l   #3,d6
                rol.l   #3,d7
                move.l  d6,d0
                move.l  d7,d3
        add.l   #3*.plane,a1
                eor.l   d4,d0
                eor.l   d5,d3
                and.l   #$55555555,d0
                and.l   #$55555555,d3   
                eor.l   d0,d4
                eor.l   d3,d5
                eor.l   d0,d6
                eor.l   d3,d7
                rol.l   #2,d4
                rol.l   #6,d5
                rol.l   #3,d6
                rol.l   #7,d7
        move.l  d2,(a1)
        move.l  d6,a5
        move.l  d4,a6
        sub.l   #6*.plane,a1

        ifeq  1-USEA7
                cmp.l   a7,a0   
        else
.endsmc
                cmp.l   #0,a0   ;smc.. 
        endc
                blt.w   .loop
                jmp     .loopend
.loopend

        move.l  d7,(a1)
        add.l   #.plane,a1
        move.l  d5,(a1)
        add.l   #.plane,a1
        move.l  a4,(a1)
        add.l   #2*.plane,a1
        move.l  a5,(a1)
        add.w   #.plane,a1
        move.l  a6,(a1)

        ifeq 1-USEA7
                move.l  .a7save,a7
        endc
.end
                movem.l (a7)+,d0-d7/a2-a6
                rts

.smchere        dc.l    0               
.a7save         dc.l    0
.firsttime      dc.l    0

;------ Align the c2p to a 16 byte-border ---

.realign
                movem.l a0/a1,-(a7)
                move.w  #(.loopend-.alignhere)/2-1,d7
                move.l  #.alignhere,d0
                and.w   #$fff0,d0
                move.l  d0,a0

        ifeq USEA7

                move.l  #(.endsmc+2)-.alignhere,d0
                lea     (a0,d0.l),a2
                move.l  a2,.smchere
        endc
                lea     .alignhere,a1
.reloop:
                move.w  (a1)+,(a0)+
                dbf     d7,.reloop

                move.l  4.w,a6
                jsr     -636(a6)          ;cacheflush
                
                addq.l  #1,.firsttime
                movem.l (a7)+,a0/a1
                rts
                
;---------------------------------------------------------------------------

