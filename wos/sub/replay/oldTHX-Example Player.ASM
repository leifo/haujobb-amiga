;-------------------T-----------T-----------------T---------T---------------

;=============================================================================
;=============================================================================
;===================== t h x - s o u n d   s y s t e m =======================
;=============================================================================
;=================== r e p l a y e r - t e s t   c o d e =====================
;=============================================================================
;=============================================================================
;========================= v e r s i o n   1 . 0 0 ===========================
;=============================================================================
;=============================================================================

	IncDIR	""
	Include	"THX-Tracker Offsets.I"

;---- (c) Dexter/Abyss! in July 1996. I do NOT take any responsibility!

	Section	thx\Example\Replay\by\Dexter\of\Abyss,Code

Start	movem.l	d1-d7/a0-a6,-(sp)

.OpenGraphicsLib	move.l	4.w,a6
	moveq	#0,d0
	lea	GfxName,a1
	jsr	-$228(a6)	;_LVOOpenLibrary(a6)
	move.l	d0,GfxBase

.InitPlayer	sub.l	a0,a0	;auto-allocate public (fast)
	sub.l	a1,a1	;auto-allocate chip
	jsr	thxReplayer+thxInitPlayer

.InitModule	lea	thxTestModule,a0
	jsr	thxReplayer+thxInitModule

.InitSubSong	moveq	#0,d0	;Subsong #0 = Mainsong
	moveq	#0,d1	;Play immediately
	jsr	thxReplayer+thxInitSubSong

PlayLoop
.DoEASYFrameTiming	move.l	GfxBase,a6
	jsr	-$10e(a6)	;_LVOWaitTOF(a6)

; WaitTOF bugs when Enforcer's running and you're starting from ASM-One !!
; (also without the replay if you have only openlib/waittof/closelib.. 
; Replayer workz!! - workz from dos fine, too, even with Enforcer!
; IT IS NOT REPLAYER'S FAULT WHEN USING EMBEDDER (TRY FROM CLI, WORKZ THEN!)

.DoMusic	jsr	thxReplayer+thxInterrupt
.CheckMouse	btst	#6,$bfe001
	bne.b	PlayLoop


.StopSong	jsr	thxReplayer+thxStopSong

.KillPlayer	jsr	thxReplayer+thxKillPlayer	;totally neccessary!!

.CloseGraphicsLib	move.l	$4.w,a6
	move.l	GfxBase,a1
	jsr	-$19e(a6)	;_LVOCloseLibrary(a6)

	movem.l	(sp)+,d1-d7/a0-a6
	moveq	#0,d0
	RTS


	Section	thx\Data\Section\by\Dexter\of\Abyss,Data

GfxName	dc.b	"graphics.library",0,0
GfxBase	ds.l	1
thxReplayer	IncBIN	"THX-Replayer.BIN"
thxTestModule	IncBIN	"THX.Rob's Vorne-Gelb Hinten-Braun Unterhos'n"
	even

;---- thxTunes may be of odd length! take care!

