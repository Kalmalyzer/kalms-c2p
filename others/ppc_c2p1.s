# Chunky2Planar algorithm, originally by James McCoull
# Modified by Peter McGavin for variable size and depth
# and "compare buffer" (hope I didn't slow it down too much)
#
# Ported by Frank Wille (phx) <frank@phoenix.owl.de> to PowerPC (04-Jan-98).
# Using optimized merge-macro by Tim Boescke (phx,26-Jan-98)
# AGA-bug and EHB-palette-change-bug fixed (phx,31-Jan-98)
#
# 	Cpu only solution VERSION 2
#	Not optimized - directly ported from 040-source... (phx)
#	bitplanes are assumed contiguous!
#	analyse instruction offsets to check performance

#void c2p_6_ppc (__reg("r3") UBYTE *chunky_data,
#                __reg("r4") PLANEPTR raster,
#                __reg("r5") UBYTE *compare_buffer,
#                __reg("r8") UBYTE *xlate,
#                __reg("r6") ULONG plsiz,
#                __reg("r7") BOOL palette_changed)

#void c2p_8_ppc (__reg("r3") UBYTE *chunky_data,
#                __reg("r4") PLANEPTR raster,
#                __reg("r5") UBYTE *compare_buffer,
#                __reg("r6") ULONG plsiz)

# r3 -> width*height chunky pixels
# r4 -> contiguous bitplanes
# r5 -> compare buffer
# r6 = width*height/8   (width*height must be a multiple of 32)

# GNU-make has some problems with quotes (e.g. in "depth=8"), so this
# is a workaround (phx)
.ifdef	depth8
.set	depth,8
.endif
.ifdef	depth6
.set	depth,6
.endif


.macro	merge		# in1,in2,tmp3,tmp4,mask,shift
# \1 = abqr
# \2 = ijyz
	srwi	\3,\2,\6
	lis	\4,(\5&0xffff0000)>>16
	ori	\4,\4,\5&0xffff
	xor	\3,\3,\1
	and	\3,\3,\4
	xor	\1,\1,\3
	slwi	\3,\3,\6
	xor	\2,\2,\3
.endm

# translate 4 8-bit pixels to 6-bit EHB
.macro	xlate		# offs1,dest2,mem3,xlate4,tmp5
	lbz	\5,\1(\3)
	lbzx	\5,\4,\5
	rlwimi	\2,\5,24,0,7
	lbz	\5,\1+8(\3)
	lbzx	\5,\4,\5
	rlwimi	\2,\5,16,8,15
	lbz	\5,\1+16(\3)
	lbzx	\5,\4,\5
	rlwimi	\2,\5,8,16,23
	lbz	\5,\1+24(\3)
	lbzx	\5,\4,\5
	rlwimi	\2,\5,0,24,31
.endm


	.text

.ifeq	depth-8
	.global	c2p_8_ppc
c2p_8_ppc:
.else
.ifeq	depth-6
	.global	c2p_6_ppc
c2p_6_ppc:
.else
.fail	"Unsupported depth! Try 6 or 8."
.endif
.endif


	stwu	r1,-80(r1)
	stmw	r14,4(r1)		# save all non-volatile registers

.ifle depth-6
	mr	r31,r7			# video_palette_changed
	mr	r29,r8			# xlate
.endif

# r3 = chunky buffer
# r4 = output area
# r5 = compare buffer
# r6 = plsiz

	mr	r12,r6			# r12 = plsiz

	slwi	r6,r6,3
	add	r30,r3,r6		# r30 = end of chunky data

first_loop:
.ifle depth-6
	cmpwi	r31,0			# palette_changed?
	bne	first_case
.endif

	lwz	r6,0(r3)
	lwz	r7,0(r5)
	cmpw	r6,r7
	bne	first_case
	lwz	r6,4(r3)
	lwz	r7,4(r5)
	cmpw	r6,r7
	bne	first_case
	lwz	r6,8(r3)
	lwz	r7,8(r5)
	cmpw	r6,r7
	bne	first_case
	lwz	r6,12(r3)
	lwz	r7,12(r5)
	cmpw	r6,r7
	bne	first_case
	lwz	r6,16(r3)
	lwz	r7,16(r5)
	cmpw	r6,r7
	bne	first_case
	lwz	r6,20(r3)
	lwz	r7,20(r5)
	cmpw	r6,r7
	bne	first_case
	lwz	r6,24(r3)
	lwz	r7,24(r5)
	cmpw	r6,r7
	bne	first_case
	lwz	r6,28(r3)
	lwz	r7,28(r5)
	cmpw	r6,r7
	bne	first_case

	addi	r4,r4,4			# skip 32 pixels on output
	addi	r3,r3,32
	addi	r5,r5,32

	cmplw	r3,r30
	blt	first_loop
	b	exit			# exit if no changes found

first_case:
.ifgt depth-6			# depth 8 code --- no need to xlate pixels
# hint from M68k: d0-d3 -> r8-r11,  d4-d7 -> r14-r17
	lwz	r9,0(r3)
	lwz	r11,4(r3)
	lwz	r8,8(r3)
	lwz	r10,12(r3)
	lwz	r14,2(r3)
	lwz	r15,10(r3)
	lwz	r16,6(r3)
	lwz	r17,14(r3)

	stw	r9,0(r5)
	stw	r11,4(r5)
	stw	r8,8(r5)
	stw	r10,12(r5)

	lwz	r6,16(r3)
	rlwimi	r9,r6,16,16,31
	rlwimi	r14,r6,0,16,31
	lwz	r6,20(r3)
	rlwimi	r11,r6,16,16,31
	rlwimi	r16,r6,0,16,31
	lwz	r6,24(r3)
	rlwimi	r8,r6,16,16,31
	rlwimi	r15,r6,0,16,31
	lwz	r6,28(r3)
	rlwimi	r10,r6,16,16,31
	rlwimi	r17,r6,0,16,31

	sth	r9,16(r5)
	sth	r8,24(r5)
	sth	r11,20(r5)
	sth	r10,28(r5)
	sth	r14,18(r5)
	sth	r15,26(r5)
	sth	r16,22(r5)
	sth	r17,30(r5)

	merge	r9,r8,r6,r7,0x00ff00ff,8
	merge	r11,r10,r6,r7,0x00ff00ff,8
	merge	r9,r11,r6,r7,0x0f0f0f0f,4
	merge	r8,r10,r6,r7,0x0f0f0f0f,4

	merge	r14,r15,r6,r7,0x00ff00ff,8
	merge	r16,r17,r6,r7,0x00ff00ff,8
	merge	r14,r16,r6,r7,0x0f0f0f0f,4
	merge	r15,r17,r6,r7,0x0f0f0f0f,4

	merge	r11,r16,r6,r7,0x33333333,2
	merge	r10,r17,r6,r7,0x33333333,2
	merge	r11,r10,r6,r7,0x55555555,1
	merge	r16,r17,r6,r7,0x55555555,1

	mr	r18,r17			# plane0
	mr	r19,r16			# plane1
	mr	r20,r10			# plane2
	mr	r21,r11			# plane3

	merge	r9,r14,r6,r7,0x33333333,2
	merge	r8,r15,r6,r7,0x33333333,2
	merge	r9,r8,r6,r7,0x55555555,1
	merge	r14,r15,r6,r7,0x55555555,1

	mr	r22,r15			# plane4
	mr	r23,r14			# plane5
	mr	r24,r8			# plane6
	mr	r25,r9			# plane7


.else				# depth 6 code, xlate from 8-bit to 6-bit EHB
	lwz	r6,0(r3)	# copy to compare buffer
	stw	r6,0(r5)
	lwz	r6,4(r3)
	stw	r6,4(r5)
	lwz	r6,8(r3)
	stw	r6,8(r5)
	lwz	r6,12(r3)
	stw	r6,12(r5)
	lwz	r6,16(r3)
	stw	r6,16(r5)
	lwz	r6,20(r3)
	stw	r6,20(r5)
	lwz	r6,24(r3)
	stw	r6,24(r5)
	lwz	r6,28(r3)
	stw	r6,28(r5)

	xlate	0,r9,r3,r29,r7		# does 8-bit to EHB colour translate
	xlate	1,r8,r3,r29,r7		# 4 pixels at a time
	xlate	4,r11,r3,r29,r7
	xlate	5,r10,r3,r29,r7

	merge	r9,r11,r6,r7,0x0f0f0f0f,4
	merge	r8,r10,r6,r7,0x0f0f0f0f,4

	xlate	2,r14,r3,r29,r7
	xlate	3,r15,r3,r29,r7
	xlate	6,r16,r3,r29,r7
	xlate	7,r17,r3,r29,r7

	merge	r14,r16,r6,r7,0x0f0f0f0f,4
	merge	r15,r17,r6,r7,0x0f0f0f0f,4

	merge	r11,r16,r6,r7,0x33333333,2
	merge	r10,r17,r6,r7,0x33333333,2

	merge	r11,r10,r6,r7,0x55555555,1
	merge	r16,r17,r6,r7,0x55555555,1

	mr	r18,r17			# plane0
	mr	r19,r16			# plane1
	mr	r20,r10			# plane2
	mr	r21,r11			# plane3

	merge	r9,r14,r6,r7,0x33333333,2
	merge	r8,r15,r6,r7,0x33333333,2
	merge	r14,r15,r6,r7,0x55555555,1

	mr	r22,r15			# plane4
	mr	r23,r14			# plane5
.endif

	addi	r3,r3,32
	addi	r5,r5,32
	mr	r26,r4			# save output address
	addi	r4,r4,4			# skip 32 pixels on output

	cmplw	r3,r30
	bge	final_case


main_loop:
.ifle depth-6
	cmpwi	r31,0			# palette_changed?
	bne	main_case
.endif
	lwz	r6,0(r3)		# compare next 32 pixels
	lwz	r7,0(r5)
	cmpw	r6,r7
	bne	main_case
	lwz	r6,4(r3)
	lwz	r7,4(r5)
	cmpw	r6,r7
	bne	main_case
	lwz	r6,8(r3)
	lwz	r7,8(r5)
	cmpw	r6,r7
	bne	main_case
	lwz	r6,12(r3)
	lwz	r7,12(r5)
	cmpw	r6,r7
	bne	main_case
	lwz	r6,16(r3)
	lwz	r7,16(r5)
	cmpw	r6,r7
	bne	main_case
	lwz	r6,20(r3)
	lwz	r7,20(r5)
	cmpw	r6,r7
	bne	main_case
	lwz	r6,24(r3)
	lwz	r7,24(r5)
	cmpw	r6,r7
	bne	main_case
	lwz	r6,28(r3)
	lwz	r7,28(r5)
	cmpw	r6,r7
	bne	main_case

	addi	r4,r4,4			# skip 32 pixels on output
	addi	r3,r3,32
	addi	r5,r5,32

	cmplw	r3,r30
	blt	main_loop
	b	final_case		# exit if no more changes found


main_case:
.ifgt	depth-6
	lwz	r9,0(r3)
	lwz	r11,4(r3)
	lwz	r8,8(r3)
	lwz	r10,12(r3)
	lwz	r14,2(r3)
	lwz	r15,10(r3)
	lwz	r16,6(r3)
	lwz	r17,14(r3)

	stw	r9,0(r5)
	stw	r11,4(r5)
	stw	r8,8(r5)
	stw	r10,12(r5)

	lwz	r6,16(r3)
	rlwimi	r9,r6,16,16,31
	rlwimi	r14,r6,0,16,31
	lwz	r6,20(r3)
	rlwimi	r11,r6,16,16,31
	rlwimi	r16,r6,0,16,31
	lwz	r6,24(r3)
	rlwimi	r8,r6,16,16,31
	rlwimi	r15,r6,0,16,31
	lwz	r6,28(r3)
	rlwimi	r10,r6,16,16,31
	rlwimi	r17,r6,0,16,31

	sth	r9,16(r5)
	sth	r8,24(r5)
	sth	r11,20(r5)
	sth	r10,28(r5)
	sth	r14,18(r5)
	sth	r15,26(r5)
	sth	r16,22(r5)
	sth	r17,30(r5)

	sub	r26,r26,r12
	stwux	r18,r26,r12		# store plane0 (r26 += plsiz)
	merge	r9,r8,r6,r7,0x00ff00ff,8
	merge	r11,r10,r6,r7,0x00ff00ff,8

	stwux	r19,r26,r12		# store plane1 (r26 += plsiz)
	merge	r9,r11,r6,r7,0x0f0f0f0f,4
	merge	r8,r10,r6,r7,0x0f0f0f0f,4

	stwux	r20,r26,r12		# store plane2 (r26 += plsiz)
	merge	r14,r15,r6,r7,0x00ff00ff,8
	merge	r16,r17,r6,r7,0x00ff00ff,8

	stwux	r21,r26,r12		# store plane3 (r26 += plsiz)
	merge	r14,r16,r6,r7,0x0f0f0f0f,4
	merge	r15,r17,r6,r7,0x0f0f0f0f,4

	stwux	r22,r26,r12		# store plane4 (r26 += plsiz)
	merge	r11,r16,r6,r7,0x33333333,2
	merge	r10,r17,r6,r7,0x33333333,2

	stwux	r23,r26,r12		# store plane5 (r26 += plsiz)
	merge	r11,r10,r6,r7,0x55555555,1
	merge	r16,r17,r6,r7,0x55555555,1

	mr	r18,r17			# plane0
	mr	r19,r16			# plane1
	mr	r20,r10			# plane2
	mr	r21,r11			# plane3

	stwux	r24,r26,r12		# store plane6 (r26 += plsiz)
	merge	r9,r14,r6,r7,0x33333333,2
	merge	r8,r15,r6,r7,0x33333333,2

	stwux	r25,r26,r12		# store plane7 (r26 += plsiz)
	merge	r9,r8,r6,r7,0x55555555,1
	merge	r14,r15,r6,r7,0x55555555,1

	mr	r22,r15			# plane4
	mr	r23,r14			# plane5
	mr	r24,r8			# plane6
	mr	r25,r9			# plane7


.else				# depth 6 code, xlate from 8-bit to 6-bit EHB
	lwz	r6,0(r3)
	stw	r6,0(r5)
	lwz	r6,4(r3)
	stw	r6,4(r5)
	lwz	r6,8(r3)
	stw	r6,8(r5)
	lwz	r6,12(r3)
	stw	r6,12(r5)
	lwz	r6,16(r3)
	stw	r6,16(r5)
	lwz	r6,20(r3)
	stw	r6,20(r5)
	lwz	r6,24(r3)
	stw	r6,24(r5)
	lwz	r6,28(r3)
	stw	r6,28(r5)

	xlate	0,r9,r3,r29,r7		# does 8-bit to EHB colour translate
	xlate	1,r8,r3,r29,r7		# 4 pixels at a time
	xlate	4,r11,r3,r29,r7
	xlate	5,r10,r3,r29,r7

	sub	r26,r26,r12
	stwux	r18,r26,r12		# store plane0 (r26 += plsiz)
	merge	r9,r11,r6,r7,0x0f0f0f0f,4
	merge	r8,r10,r6,r7,0x0f0f0f0f,4

	xlate	2,r14,r3,r29,r7
	xlate	3,r15,r3,r29,r7
	xlate	6,r16,r3,r29,r7
	xlate	7,r17,r3,r29,r7

	stwux	r19,r26,r12		# store plane1 (r26 += plsiz)
	merge	r14,r16,r6,r7,0x0f0f0f0f,4
	merge	r15,r17,r6,r7,0x0f0f0f0f,4

	stwux	r20,r26,r12		# store plane2 (r26 += plsiz)
	merge	r11,r16,r6,r7,0x33333333,2
	merge	r10,r17,r6,r7,0x33333333,2

	stwux	r21,r26,r12		# store plane3 (r26 += plsiz)
	merge	r11,r10,r6,r7,0x55555555,1
	merge	r16,r17,r6,r7,0x55555555,1

	mr	r18,r17			# plane0
	mr	r19,r16			# plane1
	mr	r20,r10			# plane2
	mr	r21,r11			# plane3

	stwux	r22,r26,r12		# store plane4 (r26 += plsiz)
	merge	r9,r14,r6,r7,0x33333333,2

	stwux	r23,r26,r12		# store plane5 (r26 += plsiz)
	merge	r8,r15,r6,r7,0x33333333,2
	merge	r14,r15,r6,r7,0x55555555,1

	mr	r22,r15			# plane4
	mr	r23,r14			# plane5
.endif

	addi	r3,r3,32
	addi	r5,r5,32

	mr	r26,r4			# save output address
	addi	r4,r4,4			# skip 32 pixels on output

	cmplw	r3,r30
	blt	main_loop



final_case:
	sub	r26,r26,r12
	stwux	r18,r26,r12		# store plane0 (r26 += plsiz)
	stwux	r19,r26,r12		# store plane1 (r26 += plsiz)
	stwux	r20,r26,r12		# store plane2 (r26 += plsiz)
	stwux	r21,r26,r12		# store plane3 (r26 += plsiz)
	stwux	r22,r26,r12		# store plane4 (r26 += plsiz)
	stwux	r23,r26,r12		# store plane5 (r26 += plsiz)
.ifgt depth-6
	stwux	r24,r26,r12		# store plane6 (r26 += plsiz)
	stwux	r25,r26,r12		# store plane7 (r26 += plsiz)
.endif

exit:
	lmw	r14,4(r1)		# restore non-volatile registers
	addi	r1,r1,80
	blr
