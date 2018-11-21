;--- _PR_Profiler.x by Bartman/Abyss


;	section code_f,code_f

START_PROFILE	MACRO
	ifd	PROFILER
	ifnd	ISREADY
	bra.b	.goon\1
.ProfileName\1:	dc.b	\2,0
	even
.goon\1:	set *
	move.l	#.ProfileName\1,easyargs+(\1-1)*28
	jsr	StartProfile
	else
	nop
	endc
	endc
	ENDM

END_PROFILE	MACRO
	IFD	PROFILER
	ifnd	ISREADY
	move.l	d0,-(sp)
	jsr	EndProfile
	tst.l	easyargs+4+(\1-1)*28
	beq.b	.istnull\1
	cmp.l	easyargs+4+(\1-1)*28,d0	;minimum
	bhi.b	.nomini\1
.istnull\1:	move.l	d0,easyargs+4+(\1-1)*28
	bra.b	.oon\1
.nomini\1:	set *
	cmp.l	easyargs+16+(\1-1)*28,d0	;maximum
	blo.b	.oon\1
	move.l	d0,easyargs+16+(\1-1)*28
.oon\1:	set *
	move.l	(sp)+,d0
	else
	nop
	endc
	endc
	ENDM

	ifd	PROFILER
	ifnd	ISREADY
StartProfile	move.l	a5,-(sp)
	lea	$bfd000,a5
	move.b	#$00,$e00(a5)		; ciaCRA stoppe timer a
	move.b	#$00,$f00(a5)		; ciaCRB stoppe timer b
	move.b	#$07,$700(a5)		; ciaTBH
	move.b	#$ff,$600(a5)		; ciaTBL
	move.b	#$ff,$500(a5)		; ciaTAH
	move.b	#$ff,$400(a5)		; ciaTAL
	move.b	#$49,$f00(a5)		; ciaCRB a = 0 -> b--
	move.b	#$01,$e00(a5)		; ciaCRA e-clk d. 68000
	move.b	#$ff,$400(a5)		; ciaTAL
	move.b	#$ff,$500(a5)		; ciaTAH
	move.l	(sp)+,a5
	rts

EndProfile	movem.l	d1-d3/a5,-(sp)
	lea	$bfd000,a5
	move.b	#$00,$e00(a5)		; ciaCRA stoppe timer a
	move.b	#$00,$f00(a5)		; ciaCRB stoppe timer b
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	move.b	$700(a5),d0
	move.b	$600(a5),d1
	move.b	$500(a5),d2
	move.b	$400(a5),d3
	ror.l	#8,d0
	swap	d1
	or.l	d1,d0
	lsl	#8,d2
	or.l	d2,d0
	or.b	d3,d0
	neg.l	d0
	add.l	#$7ffffff,d0
	mulu.l	#1000,d0
	divu.l	#709,d0
	movem.l	(sp)+,d1-d3/a5
	rts

easystruct	dc.l	20				;es_StructSize
	dc.l	0				;es_Flags
	dc.l	version2			;es_Title
	dc.l	esText			;es_TextFormat
	dc.l	esGadget			;es_GadgetFormat
esText
;	dc.b	"123456789012345: 123456 탎 (100.00%) 123456 탎 (100.00%)"
;	dc.b	"              뻣� Profiling Results カ�                ",10
	dc.b	"                  minimum            maximum            ",10
	dc.b	"------------------------------------------------------",10
	rept	PROFILER
	dc.b	"%15s: %6ld 탎 (%2ld.%02ld%%) %6ld 탎 (%2ld.%02ld%%)",10
	endr
	dc.b	"======================================================",10
	dc.b	"          Total: %6ld 탎 (%2ld.%02ldf) %6ld 탎 (%2ld.%02ldf)",0
esGadget
	dc.b	"20000 탎 = 1 frame (PAL)",0
version2:	dc.b	"WickedOS Profiler by Bartman/Abyss",0

	even
easyargs	rept	PROFILER
	dc.l	nothing	;text
	dc.l	0,0,0	;min:탎,%int,%frac
	dc.l	0,0,0	;min:탎,%int,%frac
	endr
	dc.l	0,0,0,0,0,0
nothing	dc.b	"---",0
	even
	endc
	endc

_PR_ProfileEnd:
	ifd	PROFILER
	ifnd	ISREADY
	movem.l	d0-a6,-(sp)
	lea	easyargs,a0
	moveq	#0,d0	;min
	moveq	#0,d1	;max
	moveq	#PROFILER-1,d7	;# of profiling items
.profile1	addq	#4,a0
	add.l	(a0)+,d0
	addq	#8,a0
	add.l	(a0)+,d1
	addq	#8,a0
	dbf	d7,.profile1
	move.l	#20000,d7
	move.l	d0,(a0)+	;total min
	move.l	d0,d2
	divul.l	d7,d3:d2
	move.l	d2,(a0)+
	mulu.l	#100,d3
	divu.l	d7,d3
	move.l	d3,(a0)+

	move.l	d1,(a0)+	;total min
	move.l	d1,d2
	divul.l	d7,d3:d2
	move.l	d2,(a0)+
	mulu.l	#100,d3
	divu.l	d7,d3
	move.l	d3,(a0)+

	lea	easyargs,a0
	moveq	#PROFILER-1,d7	;# of profiling items
.profile2	addq	#4,a0

	move.l	(a0)+,d2
	mulu.l	#100,d2
	divul.l	d0,d3:d2
	move.l	d2,(a0)+
	mulu.l	#100,d3
	divu.l	d0,d3
	move.l	d3,(a0)+

	move.l	(a0)+,d2
	mulu.l	#100,d2
	divul.l	d1,d3:d2
	move.l	d2,(a0)+
	mulu.l	#100,d3
	divu.l	d1,d3
	move.l	d3,(a0)+

	dbf	d7,.profile2

;	move.l	_SO_IntuiBase,a6
	move.l	intbase,a6
	sub.l	a0,a0
	lea	easystruct,a1
	sub.l	a2,a2
	lea	easyargs,a3
	jsr	-588(a6)			;EasyRequestArgs()
	movem.l	(sp)+,d0-a6
	endc
	endc
	rts
