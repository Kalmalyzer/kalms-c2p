
Converters which read in standard 15/16/32bpp graphics formats,
and output 555 or 666 ham8 graphics.

Notice that the screen pointer supplied to the routines should be
the base address of the first bitplane to be written -- which is
plane #0 out of the BitMap of an OS screen, or bpl2 if you're setting
up the ham8 mode through direct hardware access.

