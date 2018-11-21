;-------------------T-----------T-----------------T---------T---------------

;=============================================================================
;=============================================================================
;===================== t h x - s o u n d   s y s t e m =======================
;=============================================================================
;=================== r e p l a y e r - t e s t   c o d e =====================
;=============================================================================
;=============================================================================
;========================= v e r s i o n   1 . 2 7 ===========================
;=============================================================================
;=============================================================================

	IncDIR	"sources:replays/"
	Include	"THX-Offsets.I"


	Section	Dexter\Abyss_rulez,Code

Start	movem.l	d1-d7/a0-a6,-(sp)

.InitPlayer	sub.l	a0,a0	;auto-allocate public (fast)
	sub.l	a1,a1	;auto-allocate chip
	jsr	thxReplayer+thxInitPlayer

.InitModule	lea	Module,a0	;module
	jsr	thxReplayer+thxInitModule

.InitSubSong	moveq	#0,d0	;Subsong #0 = Mainsong
	moveq	#0,d1	;Play immediately
	jsr	thxReplayer+thxInitSubSong

.InitCIA	lea	thxCIAInterrupt,a0
	moveq	#0,d0
	jsr	thxReplayer+thxInitCIA
	tst	d0
	bne.b	.thxInitFailed

.thxLetHimPlay	btst	#6,$bfe001
	bne.b	.thxLetHimPlay

.RemoveCIA	jsr	thxReplayer+thxKillCIA	;don't forget!

.thxInitFailed

.StopSong	jsr	thxReplayer+thxStopSong

.KillPlayer	jsr	thxReplayer+thxKillPlayer	;don't forget!

	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#0,d0
	RTS

thxCIAInterrupt	*move	#$0,$dff180
	jsr	thxReplayer+thxInterrupt
	*move	#$aaa,$dff180
	RTS

	Section	Pink\Abyss_rulez,Data

thxReplayer	IncBIN	THX-Replayer.BIN
Module	IncBIN	THX.TestMod
;thxVisualBasic	IncDLL	vbrun300.dll

