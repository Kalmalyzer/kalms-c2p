
		section	data,data

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

		section	bss,bss

		XDEF	tempbuf
		XDEF	_tempbuf
tempbuf
_tempbuf
		ds.b	256*256*4