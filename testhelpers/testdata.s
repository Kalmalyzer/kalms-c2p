
		section	data,data

		XDEF	random_160x256x6bpl_chunky
		XDEF	_random_160x256x6bpl_chunky
random_160x256x6bpl_chunky
_random_160x256x6bpl_chunky
		incbin	random_160x256x6bpl_chunky.dat

		XDEF	random_160x256x8bpl_chunky
		XDEF	_random_160x256x8bpl_chunky
random_160x256x8bpl_chunky
_random_160x256x8bpl_chunky
		incbin	random_160x256x8bpl_chunky.dat

		XDEF	random_320x256x2bpl_chunky
		XDEF	_random_320x256x2bpl_chunky
random_320x256x2bpl_chunky
_random_320x256x2bpl_chunky
		incbin	random_320x256x2bpl_chunky.dat

		XDEF	random_320x256x4bpl_chunky
		XDEF	_random_320x256x4bpl_chunky
random_320x256x4bpl_chunky
_random_320x256x4bpl_chunky
		incbin	random_320x256x4bpl_chunky.dat

		XDEF	random_320x256x5bpl_chunky
		XDEF	_random_320x256x5bpl_chunky
random_320x256x5bpl_chunky
_random_320x256x5bpl_chunky
		incbin	random_320x256x5bpl_chunky.dat

		XDEF	random_320x256x6bpl_chunky
		XDEF	_random_320x256x6bpl_chunky
random_320x256x6bpl_chunky
_random_320x256x6bpl_chunky
		incbin	random_320x256x6bpl_chunky.dat

		XDEF	random_320x256x8bpl_chunky
		XDEF	_random_320x256x8bpl_chunky
random_320x256x8bpl_chunky
_random_320x256x8bpl_chunky
		incbin	random_320x256x8bpl_chunky.dat

		XDEF	random_320x256x8bpl_planar
		XDEF	_random_320x256x8bpl_planar
random_320x256x8bpl_planar
_random_320x256x8bpl_planar
		incbin	random_320x256x8bpl_planar.dat

		XDEF	random_320x256x8bpl_2x1_planar
		XDEF	_random_320x256x8bpl_2x1_planar
random_320x256x8bpl_2x1_planar
_random_320x256x8bpl_2x1_planar
		incbin	random_320x256x8bpl_2x1_planar.dat

		section	bss,bss

		XDEF	tempbuf
		XDEF	_tempbuf
tempbuf
_tempbuf
		ds.b	256*256*4
