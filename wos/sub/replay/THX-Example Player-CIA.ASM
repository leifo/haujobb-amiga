;-------------------T-----------T-----------------T---------T---------------

;=============================================================================
;=============================================================================
;===================== t h x - s o u n d   s y s t e m =======================
;=============================================================================
;=================== r e p l a y e r - t e s t   c o d e =====================
;=============================================================================
;=============================================================================
;========================= v e r s i o n   2 . 3 d ===========================
;=============================================================================
;=============================================================================

	IncDIR	"ASM:System/THX-Tracker/"
	Include	"THX-Tracker Offsets.I"


	Section	Dexter\Abyss_rulez,Code

Start	movem.l	d1-d7/a0-a6,-(sp)

.InitCIA	lea	thxCIAInterrupt,a0
	moveq	#0,d0
	jsr	thxReplayer+thxInitCIA
	tst	d0
	bne.b	.thxInitFailed

.InitPlayer	sub.l	a0,a0	;auto-allocate public (fast)
	sub.l	a1,a1	;auto-allocate chip
	moveq	#0,d0	;load waves from hd if possible
	moveq	#0,d1
	jsr	thxReplayer+thxInitPlayer
	;check d0=result normally here...

.InitModule	lea	thxMyModule,a0	;module
	jsr	thxReplayer+thxInitModule
	;check d0=result normally here...

.InitSubSong	moveq	#0,d0	;Subsong #0 = Mainsong
	moveq	#0,d1	;Play immediately
	jsr	thxReplayer+thxInitSubSong

.thxLetHimPlay	btst	#6,$bfe001	;not so system-friendly, i know!
	bne.b	.thxLetHimPlay

.StopSong	jsr	thxReplayer+thxStopSong

.KillPlayer	jsr	thxReplayer+thxKillPlayer	;don't forget!

.RemoveCIA	jsr	thxReplayer+thxKillCIA	;don't forget!

.thxInitFailed	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#0,d0
	RTS

thxCIAInterrupt	move	#0,$dff180
	jsr	thxReplayer+thxInterrupt
	move	#$aaa,$dff180
	RTS

	Section	Pink\Abyss_rulez,Data


thxReplayer	IncBIN	THX-Replayer.BIN
thxMyModule	IncBIN	THX.Hawkeye-Loader
thxVisualBasic	IncDLL	vbrun300.dll

