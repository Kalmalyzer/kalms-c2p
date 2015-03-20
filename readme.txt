
		Mikael Kalms' C2P collection
		----------------------------
		mikael@kalms.org
		
Introduction:

Here is a fairly complete set of c2p routines, almost one routine for
every occasion! The main aim is towards 68030-68060 processors, using
CPU-only conversion, although you can find the occasional oddity in some
darker corners of the archive.

The main aim of this archive is to provide a fairly broad range of fast and
easy-to-use c2p routines, so all other programmers need not re-invent the
wheel.
When making these routines, there is always the question of how the balance
between usability and speed should be weighted. In several cases, minor
performance degradations have been paid in order to retain the flexibility
of the routines. Every single one of these cases have been carefully
considered though, so you can rest assured that the speed tradeoffs are very
tiny.
[Because of this, these routines aren't necessarily the fastest around; other
people who consider speed to be of the ultimate essence will have slightly
faster solutions. That usually comes to the price of having slightly scrambled
chunky-data layout, restrictions on screen size, or slightly degraded
performance on some accelerator boards where the routine ought to do better.]



Overview of the collection:

bitmap/	Converters which output to arbitrary AmigaOS BitMaps
ham8/	15/16/32bpp source, ham8 destination. Gives easily AGA support to
	games/demos which so far only support hicolor/truecolour modes and
	therefore only run on graphics cards!
	[Notice that the resolution is vastly lower, though]
normal/	1-8bpl converters, all the range from 020 to 060. CPU-only
	as well as cpu+blitter
old/	Routines which no longer are of interest
special/ Routines which don't really fit into any other categories



Legal:

All files except in the "others" directory are Public Domain: Anyone can
do as they please with the code, feel free to use it for non-commercial
as well as commercial purposes, change and redistribute the contents
as you please.
All files in the "others" directory are subject to the respective copyright
notices of the authors; the respective authors have given the right to
distribute the files with this package, though.
If nothing else is stated, the autors reserve all rights to their material
but allow it to be freely spread and used.

I take no responsibility for the validity of this code nor the effects it
has on your hardware/software, directly or indirectly.
