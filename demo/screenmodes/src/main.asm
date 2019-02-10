	idnt	"..\src\main.c"
	machine	68060
	fpu	1
	opt	0
	opt	NQLPSMRBT
	section	"CODE",code
	public	_initDemo
	cnop	0,4
_initDemo
	movem.l	l46,-(a7)
	move.l	#320,_xres
	move.l	#180,_yres
	move.l	#691200,-(a7)
	jsr	_malloc
	move.l	d0,_tempBuffer
	move.l	_yres,d0
	muls.l	_xres,d0
	move.l	_tempBuffer,a0
	add.l	d0,a0
	move.l	a0,_screenBuffer
	jsr	_screenmodeEffectInit
	addq.w	#4,a7
l46	reg
l48	equ	0
	rts
	machine	68060
	fpu	1
	opt	0
	opt	NQLPSMRBT
	public	_updateDemo
	cnop	0,4
_updateDemo
	movem.l	l49,-(a7)
l49	reg
l51	equ	0
	rts
; stacksize=0
	machine	68060
	fpu	1
	opt	0
	opt	NQLPSMRBT
	public	_drawDemo
	cnop	0,4
_drawDemo
	movem.l	l52,-(a7)
	move.l	(4+l54,a7),d2
	divs.l	#25,d2
	cmp.l	_oldpart,d2
	beq	l8
	jsr	_irand
	move.l	d0,d1
	divsl.l	#17,d0:d1
	moveq	#8,d1
	add.l	d0,d1
	move.l	d1,_pic
	move.l	d2,_oldpart
l8
	move.l	_pic,-(a7)
	jsr	_screenmodeEffectRender
	move.l	#256,-(a7)
	move.l	_g_currentPal,-(a7)
	jsr	_wosSetCols
	move.l	#2,-(a7)
	jsr	_wosDisplay
	add.w	#16,a7
l52	reg	d2
	movem.l	(a7)+,d2
l54	equ	4
	rts
	machine	68060
	fpu	1
	opt	0
	opt	NQLPSMRBT
	public	_mainDemo
	cnop	0,4
_mainDemo
	movem.l	l55,-(a7)
	jsr	_wosCheckExit
	tst.l	d0
	bne	l34
l33
	move.l	_g_vbitimer,d2
	divs.l	#25,d2
	cmp.l	_oldpart,d2
	beq	l30
	jsr	_irand
	move.l	d0,d1
	divsl.l	#17,d0:d1
	moveq	#8,d1
	add.l	d0,d1
	move.l	d1,_pic
	move.l	d2,_oldpart
l30
	move.l	_pic,-(a7)
	jsr	_screenmodeEffectRender
	move.l	#256,-(a7)
	move.l	_g_currentPal,-(a7)
	jsr	_wosSetCols
	move.l	#2,-(a7)
	jsr	_wosDisplay
	jsr	_wosCheckExit
	add.w	#16,a7
	tst.l	d0
	beq	l33
l34
l55	reg	d2
	movem.l	(a7)+,d2
l57	equ	4
	rts
	machine	68060
	fpu	1
	opt	0
	opt	NQLPSMRBT
	public	_deinitDemo
	cnop	0,4
_deinitDemo
	movem.l	l58,-(a7)
	jsr	_screenmodeEffectRelease
	move.l	_tempBuffer,-(a7)
	jsr	_free
	addq.w	#4,a7
l58	reg
l60	equ	0
	rts
	machine	68060
	fpu	1
	opt	0
	opt	NQLPSMRBT
	public	_main
	cnop	0,4
_main
	movem.l	l61,-(a7)
	move.l	#320,_xres
	move.l	#180,_yres
	move.l	#691200,-(a7)
	jsr	_malloc
	move.l	d0,_tempBuffer
	move.l	_yres,d0
	muls.l	_xres,d0
	move.l	_tempBuffer,a0
	add.l	d0,a0
	move.l	a0,_screenBuffer
	jsr	_screenmodeEffectInit
	jsr	_wosInit
	jsr	_screenmodeEffectRelease
	move.l	_tempBuffer,-(a7)
	jsr	_free
	moveq	#0,d0
	addq.w	#8,a7
l61	reg
l63	equ	0
	rts
	public	_oldpart
	section	"DATA",data
	cnop	0,4
_oldpart
	dc.l	-1
	public	_pic
	cnop	0,4
_pic
	dc.l	8
	public	_xres
	section	"BSS",bss
	cnop	0,4
_xres
	ds.b	4
	public	_yres
	cnop	0,4
_yres
	ds.b	4
	public	_screenBuffer
	cnop	0,4
_screenBuffer
	ds.b	4
	public	_g_vbitimer
	public	_wosInit
	public	_wosDisplay
	public	_wosCheckExit
	public	_wosSetCols
	public	_screenmodeEffectInit
	public	_screenmodeEffectRender
	public	_screenmodeEffectRelease
	public	_irand
	public	_malloc
	public	_free
	public	_g_currentPal
	cnop	0,4
_g_currentPal
	ds.b	4
	public	_tempBuffer
	cnop	0,4
_tempBuffer
	ds.b	4
