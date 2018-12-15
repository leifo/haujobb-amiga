;-------T-------T-------T-------T-------T-------T-------T-------T-------T---

;WTEST		;uncomment to assemble and check the source

;RETURNCODE

; framesynctest = dirty tests with copper and level1 to achive framesync c2p
; v1.3, 27.09.15, added 32cols>>3 mode for Last Train to Danzig
; v1.4, 15.10.15, removed 030 support, i.e. switched from triple to double buffering almost everywhere
; v1.4.2, 26.11.16, added mode17, 216x180 15 bit from 32bit ARGB pixel
; v1.5, 29.12.16, made it work with a little black stripe on the right
;       02.01.17, fixed to 220x180 15 bit mode18 and 220x90 15 bit mode19
; v1.5.2, 08.01.17, both expect 6 bit component precision and saturate in c2p
; v1.5.3, 02.02.17, framesync experiments
;         11.02.17, framesync started working
;         12.02.17; debugged while listening to Dave Haynie talk at Datastorm
;         20.02.17; stack overflow fixed
; v1.5.4,         ; save and restore complete four-word stack frame
;         24.02.17; interrupt and exit fix
; v1.5.5, 26.02.17; managed buffers (req. for framesync)
; v1.5.6, 21.11.17, mode16 3->8 copper colours (0..7)
;         24.11.17, mode16 colour layout changed (0,249..255)
;         02.12.17; mode14 added saturation
; v1.6,   02.12.17; added mode24 320x180x5 (OCS) 
;         09.12.17; added mode25 320x180x5 (OCS) + copper cols 0, 25..31
; v1.61,  08.09.18; started cleanup for release
;         18.09.18; system mode started working
; v1.62,  30.09.18; cross-assembly working; added WOSASSIGN and KILLER flags
; v1.63,  13.11.18; initial release version
;_Inithook...

;MC68020
;***************************************************************************
;* WOS - Wicked Operating System for Demos by Leif 'NoName' Oppermann      *
;* code single effects and link them into a big thing (intro/demo)         *
;* see doc/Wos_Infos.txt for further infos and history                     *
;***************************************************************************

;	XREF	_Main

	; make pattern,position,row reachable from outside
	; in order to inject calculated fake adpcm data for prototype 1 demo
	xdef	_ETposition
	xdef	_ETpattern
	xdef	_ETrow


	xdef	_wosMouseX
	xdef	_wosMouseY

	ifd	WTEST


;PRINTSTATS
RETURNCODE

NOMODE2
NOMODE3
NOMODE4
NOMODE5
NOMODE6
NOMODE7
NOMODE8
NOMODE9
NOMODE10
NOMODE11
NOMODE12
NOMODE13
NOMODE14
NOMODE15
NOMODE16
NOMODE17
NOMODE18
NOMODE19
NOMODE20
NOMODE21
NOMODE22
NOMODE23
NOMODE24
NOMODE25
NOSPEEDYCHIP

;NOMMS
;NOLOADING
NODECRUNCH

;SAVEFRAMES	;saves each frame as 8bit BMP
;OVERLAY 	;have this in your server if you want to use overlay-multiload!
;DEBUG
;REPLAY=0
MUSIC=2

;DONTTAKE
;use=$a2419609	;P61 usecode (customize per mod)
;asmone		;uncomment if you do use asmone for some extrainfos

	endc

;WOSASSIGN	

WOSINCLUDE	Macro	; does not work for all includes (f.e. xref fails)
	ifd	WOSASSIGN
		include	wos:\1
	else
		include	\1
	endc
	endm
WOSINCBIN	Macro
	ifd	WOSASSIGN
		incbin	wos:\1
	else
		incbin	\1
	endc
	endm



	incdir	includes:
	include hardware/custom.i

	ifd	WOSASSIGN
		include	wos:sub/wos_incall.i
	else
		include	sub/wos_incall.i
	endc
	
		
DATUM	Macro
	dc.b    "13.11.2018"
	EndM    
VERSION	macro
	dc.b    "1.63"
	endm

	ifd	OVERLAY
		ifd	asmone
			printt	"Overlay On"
		endc
		WOSINCLUDE	sub/wos_overlay.s
	endc
	ifd	WTEST
KILLER	; undefine to use multi-tasking hardware abstraction layer which allows loading a.o.

		ifd	asmone
			printt	""
			printt	"*** Note: wtest-flag is set, WOS is not useable like this,"
			printt	"          please comment it out before you save the source."
			printt	""
		endc


		jmp	skip	;leave this, the system first needs to
				;initialize itself and will then jump
				;to _Main which is inside the INITWOS macro
	INITWOS
	SETMODE	#1,#Buffer,#Cols,#255
loop
        DISPLAY
        CHECKEXIT
        beq	loop
	
	EXITWOS

Buffer	WOSINCBIN	dat/320x200x8.cnk
Cols	WOSINCBIN	dat/320x200x8.col

skip		;in case of "WTEST" we first jump here and init the system
	endc

AHXVBL	;force AHX to VBL-Timing because of some remaining errors with CIA

;--- internal stuff for conditional assembling
	ifnd	MUSIC
MUSIC equ 0
	endc

	ifnd	REPLAY
		ifd	MUSIC
REPLAY set MUSIC
		else
REPLAY set 0
		endc	
	else
		ifd	MUSIC
			ifne	REPLAY-REPLAY!MUSIC
REPLAY set REPLAY!MUSIC
			endc
		endc
	endc


WOS_P61 = REPLAY&1
WOS_TP3 = REPLAY&2
WOS_THX = REPLAY&4
WOS_AHX = REPLAY&8

	ifnd	use	
use set -1	;dummy for p61.i and especially for OMA 3. just leave it here!
	endc
	
	ifne	WOS_P61
		include	exec/types.i
		WOSINCLUDE	sub/replay/p61.i
	endc

	ifne	WOS_TP3
		WOSINCLUDE	sub/replay/TP3.i
	endc

	ifne	WOS_THX
		WOSINCLUDE	sub/replay/oldthx-offsets.i
	endc

	ifne	WOS_AHX
		WOSINCLUDE	sub/replay/thx-offsets.i
	endc

	ifnd   	CLIONLY
EXEC equ 4
;pr_CLI equ $AC
pr_MSGPORT equ $5C

sm_ARGLIST equ $24
sm_NUMARGS equ $1C

FINDTASK equ -294
WAITPORT equ -384
GETMSG equ -372
REPLYMSG equ -378

WBStartUp:
        movem.l d0/a0,-(sp)     ;Args auf den Stack
        sub.l   a1,a1           ;uns selbst
        move.l  EXEC.w,a6       ;Execbase nach a6
        jsr     FINDTASK(a6)    ;suchen

        sub.l   a1,a1           ;keine WB_MSG !
        move.l  d0,a2           ;nach a2
        tst.l   pr_CLI(a2)      ;kommen wir vom CLI ?
        bne.s   .WBL1              ;ja,dann weiter !!!

        lea     pr_MSGPORT(a2),a0       ;MsgPort nach a0
        jsr     WAITPORT(a6)            ;warten
        lea     pr_MSGPORT(a2),a0
        jsr     GETMSG(a6)
        move.l  d0,a1                   ;WB_Startup nach a1 retten

        move.l  sm_NUMARGS(a1),d0       ;Anzahl nach d0
        move.l  sm_ARGLIST(a1),a0       ;Liste nach a0
        moveq   #-1,d1                  ;<>0 bed. wir kommen von WB !
        addq.w  #8,sp                   ;Stack korrigieren
        bra.s   .WBL2
.WBL1
        movem.l (sp)+,d0/a0             ;Args vom Stack
        moveq   #0,d1                   ;=0 bed. wir kommen vom CLI !
.WBL2
        movem.l a1/a6,-(sp)             ;retten
        bsr     .WBL4                   ;Hauptprogramm abarbeiten
        movem.l (sp)+,a1/a6             ;wieder vom Stack

        move.l  a1,d1                   ;kamen wir von WB ?
        beq.s   .WBL3                      ;nein,dann fertig !
        move.l  d0,d2                   ;Returncode retten
        jsr     REPLYMSG(a6)            ;WB_MSG zurück !
        move.l  d2,d0                   ;Returncode wieder nach d0
.WBL3
        rts                             ;und fertig !

.WBL4
	endc	;of CLIONLY


GO:	movem.l d1-a6,-(a7)
 	move.l	$4,execbase		;cache execbase
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	ifnd	NOINFO
		lea	comlenstr(pc),a1
		move.l	d0,(a1)+	;store the args
		move.l	a0,(a1)+
	endc

	bsr	WOSInit
	tst	d0
	bne	noinit

	ifnd	NOINFO
		lea	comlenstr(pc),a1
		move.l	(a1)+,d0
		move.l	(a1)+,a0
		bsr	ProcessArgs
		beq	notake		;if INFO was requested
	endc

	lea	_wosbase,a6
	ifd	STARTUPHOOK
		STARTUPHOOK
	endc
	lea	_wosbase,a6

	ifnd	DONTTAKE
	        bsr	Take
	        tst     d0
	        bne     notake

		ifnd	NOSPEEDYCHIP
			jsr	SpeedyChipBin
		endc

	endc
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;	lea	_wosbase,a0

	ifne	WOS_TP3
		lea	TP3Bin,a0
		move.l  vbroffset,tp_vbr(a0)
	endc

;-------------- Start requested replayer 
	ifd	MUSIC
        	sub.l	a0,a0
        	
		ifeq	MUSIC-P61
			lea	p61_module,a0
		endc

		ifeq	MUSIC-TP3
			lea	tp_module,a0
		endc
	
		ifeq	MUSIC-THX
			lea	thx_module,a0
		endc

		ifeq	MUSIC-AHX
			lea	ahx_module,a0
		endc

		ifeq	MUSIC
			; disable audio dma; 15.05.2015, v1.2
			;move	#%0000000000001111,$dff096
		endc

		bsr	_PlayMod
		
	endc	

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	move.l	a7,InitialStack		;safe the stack for panic-exit

;	ifd	INITHOOKPRESENT
		lea	_wosbase,a0
		moveq	#0,d0
		jsr	_Inithook
;	endc	


	moveq	#0,d2			;no delay
	lea	_wosbase(pc),a0		;do never ever modify _W#? entries
	lea	L3_VBI(a0),a1
	jsr	_Main			; set "WTEST" flag for testing

getout:
	ifd	EXITHOOKPRESENT
		lea	_wosbase(pc),a0
		moveq	#0,d0
		jsr	_Exithook
	endc	

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
errout:					;continue here if an error occured
	move.l	InitialStack,a7
;-------------- Stop requested replayer
	ifd	RETURNCODE
		move.l	d2,return
	endc
	bsr	_StopMod

	ifd     MUSIC

		ifeq	MUSIC-THX
			move.b	Playing(pc),d0
			cmp.b	#THX,d0
			bne.s	notthis1
;	                       bsr     othxReplayer+othxKillCIA  ;don't forget!
othxInitFailed
			bsr	othxReplayer+othxStopSong
			bsr	othxReplayer+othxKillPlayer       ;don't forget!
notthis1
	        endc                    

		ifeq	MUSIC-AHX
			move.b	Playing(pc),d0
			cmp.b	#AHX,d0
			bne.s	notthis2
thxInitFailed
			bsr	thxReplayer+thxStopSong
			bsr	thxReplayer+thxKillPlayer       ;don't forget!
			ifnd	AHXVBL
				bsr	thxReplayer+thxKillCIA		;don't forget!
			endc
notthis2
		endc

	endc
        

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
exit:
	ifnd	DONTTAKE
		bsr	Give
	endc

alive:		;the system is alive again, can be used as a breakpoint

	lea	_wosbase(pc),a6
	ifd	CLOSEDOWNHOOK
		CLOSEDOWNHOOK
	endc
	lea	_wosbase(pc),a6

	ifnd	ABSOLUTELYNOERRORS
		move.w	ErrorFlag,d0
		beq.s	.noerr
		bsr	PrintErrors
.noerr
	endc


	ifd	PROFILER
		jsr _PR_ProfileEnd
	endc

	ifd	DEBUG
		bsr	WaitDebug
	endc

	
notake	bsr	WOSExit
	
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

noinit:	movem.l (a7)+,d1-a6
	ifnd	RETURNCODE
		moveq	#0,d0
	else
		move.l	return(pc),d0	
	endc
	rts     

return	dc.l	0

	ifnd	INITHOOKPRESENT
_Inithook:
	endc
	ifnd	EXITHOOKPRESENT
_Exithook:
	endc
	rts

bufstate:	dc.l	0	; 0: available
				; 1: c2p pending (render done)
				; 2: c2p in progress


******************************************************************************

;++++++++++++++ WOS Structure...given routines (_W#?) and some data fields
_wosbase:
	dc.l    "wSER"	

	bra     _SetModeAndColors
	bra     _SetColors
	bra     _Display
	bra     _CheckExit
	bra     _MouseX
	bra     _MouseY
	bra     _SetExit
	bra     _ClearExit
	bra     _NoMode
                                
m1:	dc.l	0,0,0		; mode1	(init,main,exit)
m2:	dc.l	0,0,0		; mode2
m3:	dc.l	0,0,0		; mode3
m4:	dc.l	0,0,0		; mode4
m5:	dc.l	0,0,0		; mode5

	bra	_Init

	dc.l	0		;
	dc.l	0		;mode2ptr
	dc.l	0		;mode3ptr
	dc.l	0		;mode4ptr
	dc.l	0		;mode5ptr
lulu	dc.l	0		;L3_VBI
	dc.l	0		;L3_Blitter
	bra	_VBIHook	;_WVBIHook

	;---v0.33
	bra	_Exit		;_WExit
	;---v0.36
	dc.w	0,0,0,0         ;ATTNFLAGS,CHIPREVBITS,CPU,AGA

	;---v0.45
	dc.l	0		;dk3dptr

	;---v0.48
	bra	_Decrunch	;_WDecrunch
	bra	_InitwPAC	;_WInitwPAC

	;---v0.49
	ds.l	15		;instead of d0-a6, 15 longwords for possible data-passing
	ifnd	NOMMS
		bra	_AllocChip	;6 macros for normal use
		bra	_Alloc
		bra	_Erase
		bra	_EraseAll
		bra	_Start
		bra	_Length
		bra	_SYSAllocChip	;6 macros to be used by the system and its extensions
		bra	_SYSAlloc
		bra	_SYSErase
		bra	_SYSEraseAll
		bra	_SYSStart
		bra	_SYSLength
	;---v0.492
		bra	_AllocAny
		bra	_AllocAnyChip
		bra	_SYSAllocAny
		bra	_SYSAllocAnyChip
	else
		ds.l	16
	endc

	;---v0.495
	bra	_WaitVBL
	;---v0.497
	bra	_CallEfx
	;---v0.497b
	bra	_SetScreen
	;---v0.497f
	bra	_Error
	;---v0.499
	bra	_PlayMod
	bra	_StopMod
	bra	_Volume
	bra	_GetPos
	bra	_NextVBI_obsolete
	;---v0.5
	bra	_Load
	;---v0.52
	dc.l	0		;mmstabptr
	;---v0.54
m6:	dc.l	0,0,0		;mode6 (18 bit)
	dc.l	0		;mode6ptr
	;---v0.55
	bra	_InitEfx
	bra	_ExitEfx
	bra	_CallEfxOnce
				;the following 3 pointers are only available
				;when OVERLAY is set and the loadfile is valid
	dc.l	0		;ownfh (own filehandle)
	dc.l	0		;ownname (our filename incl. path)
	dc.l	0		;owndata (offset in own file to own data)
	;---v0.56
				;these 3 also need OVERLAY set	
	dc.l	0		;^TOC
	dc.l	0		;^TON
	bra	_LoadFrom
	bra	_Print

	;---v0.6	
	bra	_ClearPlanes
	
	;---v0.61
m7:	dc.l	0,0,0		;mode7 (1x1 64cols)
	dc.l	0		;mode7ptr
	dc.l	0		;coplist ptr

	;---v0.63	
	dc.l	0		:sprlist (dummy)
	bra	_SetSprites	;(dummy)

	;---v0.7
	bra	_EffectTracker

	;---v1.0 - v1.01 were basically the same as v0.7, just cleaned up for release
		
	;---v1.02
m8:	dc.l	0,0,0,0			;mode8 (1x1 320x180, (framesync intended))

	;---v1.03 
m9:	dc.l	0,0,0,0			;mode9  (1x2 160x90)
m10:	dc.l	0,0,0,0		;mode10 (2x2 160x90)
m11:	dc.l	0,0,0,0		;mode11 (2x2 160x90 18 bit)
m12:	dc.l	0,0,0,0		;mode12 (1x2 640x90)
m13:	dc.l	0,0,0,0		;mode13 (1x1 640x180)
	;---v1.3,27.09.15
m14:	dc.l	0,0,0,0		;mode14 (1x1 320x180 6 bit with saturation)
m15:	dc.l	0,0,0,0		;mode15 (1x1 320x180 5 bit + bitplane pointers 567)
	bra	_SetLine		
	; 07.10.15
m16:	dc.l	0,0,0,0		;mode16 (1x1 320x180 8 bit + copper cols012)
	bra	_SetCopper
	; 26.11.16
m17:	dc.l	0,0,0,0		;mode17 (220x180 15 bit), chunkybuffer is 4rgb888 (24 bit)
	; 30.12.16
m18:	dc.l	0,0,0,0		;mode18 (220x180 15 bit), chunkybuffer is 4rgb666 (18 bit, allows for overflow saturation in c2p and 1 bit extra precision, e.g. for dithering)
m19:	dc.l	0,0,0,0		;mode19 (220x90 15 bit), chunkybuffer is 4rgb666 (18 bit, allows for overflow saturation in c2p and 1 bit extra precision, e.g. for dithering)
	; 07.01.17
m20:	dc.l	0,0,0,0		;mode20 (220x180 18 bit), chunkybuffer is 4rgb888 (24 bit)
	; 08.01.17
m21:	dc.l	0,0,0,0		;mode21 (220x180 18 bit), chunkybuffer is 4rgb666 (18 bit, allows for overflow saturation in c2p)
m22:	dc.l	0,0,0,0		;mode22 (220x90 18 bit), chunkybuffer is 4rgb666 (18 bit, allows for overflow saturation in c2p)
m23:	dc.l	0,0,0,0		;mode23 (220x180 12 bit), chunkybuffer is 4rgb666 (18 bit, allows for overflow saturation in c2p)
	; 27.02.17
mptrptr:	dc.l	0	;points to mode#?ptr to allow setbuf
b1	dc.l	0		;two buffers required for framesync (parallel)
b1state	dc.l	0		;" (state changes will be written back)
b2	dc.l	0		;"
b2state	dc.l	0		;" (states 0: free, 1: c2p pending, 2: c2p)
	bra     _SetBuffer

	;---v1.6,03.12.17
m24:	dc.l	0,0,0,0		;mode24 (1x1 320x180 5 bit)
m25:	dc.l	0,0,0,0		;mode25 (1x1 320x180 5 bit + copper cols 0, 25..31)


;-------------- End of WOS Structure
	ds.w	128*2		;to keep the bra.w's in the jump-table!!!
	

;-------------- New in 2015++ :)
blackCopper:	ds.l	180

_SetCopper:
	; AGA mode 16
	cmp.b	#16,ScreenMode
	beq	SCmode16

	; OCS mode 25
	cmp.b	#25,ScreenMode
	beq.s	SCmode25
	rts

SCmode25
	ifnd	NOMODE25
; in: d0 - colour index, a0 - pointer to gradient / list of 180 colours (4 bytes each, 00rrggbb)
; out: none

; routine will update all lines of colour index d0 with gradient colours from a0
; setup

	tst	PageFlips		; pass through on init (before any c2p display has happened)
	beq.s	.ok
	
	tst.l	DisplayCurrent	; only allow colour changes when c2p display after latest screenmode change has reached the front buffer
	bpl.s	.ok
	rts
.ok
	movem.l	d2-d3,-(a7)

	cmp	#0,d0
	beq	.col0
	cmp.l	#25,d0
	beq	.col25
	cmp.l	#26,d0
	beq	.col26
   cmp.l	#27,d0
	beq	.col27
   cmp.l	#28,d0
	beq	.col28
   cmp.l	#29,d0
	beq	.col29
   cmp.l	#30,d0
	beq	.col30
   cmp.l	#31,d0
	beq	.col31
	
	bra	.clip	

.col0	; write to coplinesm25+offset
	lea	coplinesm25,a1
	
	move.l	#179,d3	; counter
	moveq.l	#0,d1
.loopc0
	move.l	(a0)+,d0	; get $00rrggbb in d0

	;move.l	#$123456,d0
	;want: 135 in d1

	; blue
	ror.l	#4,d0
	bfins	d0,d1{28:4}

	; green
	ror.l	#8,d0
	bfins	d0,d1{24:4}

	; red
	ror.l	#8,d0
	bfins	d0,d1{20:4}

	;move.l	#$020,d1
	move	d1,6(a1)	; colour 0 high word in current line in coplinesm16

	; correct pointer into copper colour list
	add.l	#LINECOLMODE25_LENGTH,a1
	dbf	d3,.loopc0
	bra	.out

.col25
	lea	coplinesm25,a1
	
	move.l	#179,d3	; counter
   moveq.l	#0,d1
.loopc25
   move.l	(a0)+,d0	; get $00rrggbb in d0
   
   ;move.l	#$123456,d0
   ;want: 135 in d1
   
   ; blue
   ror.l	#4,d0
   bfins	d0,d1{28:4}
   
   ; green
   ror.l	#8,d0
   bfins	d0,d1{24:4}
   
   ; red
   ror.l	#8,d0
   bfins	d0,d1{20:4}

	;move.l	#$040,d1
	move	d1,10(a1)	; colour 1 high word in current line in coplinesm16

	; correct pointer into copper colour list
	add.l	#LINECOLMODE25_LENGTH,a1
	dbf	d3,.loopc25
	bra	.out

.col26
	lea	coplinesm25,a1
	
	move.l	#179,d3	; counter
   moveq.l	#0,d1
.loopc26
   move.l	(a0)+,d0	; get $00rrggbb in d0
   
   ;move.l	#$123456,d0
   ;want: 135 in d1
   
   ; blue
   ror.l	#4,d0
   bfins	d0,d1{28:4}
   
   ; green
   ror.l	#8,d0
   bfins	d0,d1{24:4}
   
   ; red
   ror.l	#8,d0
   bfins	d0,d1{20:4}

	;move.l	#$060,d1
	move	d1,14(a1)	; colour 1 high word in current line in coplinesm16

	; correct pointer into copper colour list
	add.l	#LINECOLMODE25_LENGTH,a1
	dbf	d3,.loopc26
	bra	.out
.col27
	lea	coplinesm25,a1
	
	move.l	#179,d3	; counter
   moveq.l	#0,d1
.loopc27
   move.l	(a0)+,d0	; get $00rrggbb in d0
   
   ;move.l	#$123456,d0
   ;want: 135 in d1
   
   ; blue
   ror.l	#4,d0
   bfins	d0,d1{28:4}
   
   ; green
   ror.l	#8,d0
   bfins	d0,d1{24:4}
   
   ; red
   ror.l	#8,d0
   bfins	d0,d1{20:4}

	;move.l	#$080,d1
	move	d1,18(a1)	; colour 1 high word in current line in coplinesm16

	; correct pointer into copper colour list
	add.l	#LINECOLMODE25_LENGTH,a1
	dbf	d3,.loopc27
	bra	.out
.col28
	lea	coplinesm25,a1
	
	move.l	#179,d3	; counter
   moveq.l	#0,d1
.loopc28
   move.l	(a0)+,d0	; get $00rrggbb in d0
   
   ;move.l	#$123456,d0
   ;want: 135 in d1
   
   ; blue
   ror.l	#4,d0
   bfins	d0,d1{28:4}
   
   ; green
   ror.l	#8,d0
   bfins	d0,d1{24:4}
   
   ; red
   ror.l	#8,d0
   bfins	d0,d1{20:4}

	;move.l	#$0a0,d1
	move	d1,22(a1)	; colour 1 high word in current line in coplinesm16

	; correct pointer into copper colour list
	add.l	#LINECOLMODE25_LENGTH,a1
	dbf	d3,.loopc28
	bra	.out
.col29
	lea	coplinesm25,a1
	
	move.l	#179,d3	; counter
   moveq.l	#0,d1
.loopc29
   move.l	(a0)+,d0	; get $00rrggbb in d0
   
   ;move.l	#$123456,d0
   ;want: 135 in d1
   
   ; blue
   ror.l	#4,d0
   bfins	d0,d1{28:4}
   
   ; green
   ror.l	#8,d0
   bfins	d0,d1{24:4}
   
   ; red
   ror.l	#8,d0
   bfins	d0,d1{20:4}

	;move.l	#$0c0,d1
	move	d1,26(a1)	; colour 1 high word in current line in coplinesm16

	; correct pointer into copper colour list
	add.l	#LINECOLMODE25_LENGTH,a1
	dbf	d3,.loopc29
	bra	.out
.col30
	lea	coplinesm25,a1
	
	move.l	#179,d3	; counter
   moveq.l	#0,d1
.loopc30
   move.l	(a0)+,d0	; get $00rrggbb in d0
   
   ;move.l	#$123456,d0
   ;want: 135 in d1
   
   ; blue
   ror.l	#4,d0
   bfins	d0,d1{28:4}
   
   ; green
   ror.l	#8,d0
   bfins	d0,d1{24:4}
   
   ; red
   ror.l	#8,d0
   bfins	d0,d1{20:4}

	;move.l	#$0e0,d1
	move	d1,30(a1)	; colour 1 high word in current line in coplinesm16

	; correct pointer into copper colour list
	add.l	#LINECOLMODE25_LENGTH,a1
	dbf	d3,.loopc30
	bra	.out
.col31
	lea	coplinesm25,a1
	
	move.l	#179,d3	; counter
   moveq.l	#0,d1
.loopc31
   move.l	(a0)+,d0	; get $00rrggbb in d0
   
   ;move.l	#$123456,d0
   ;want: 135 in d1
   
   ; blue
   ror.l	#4,d0
   bfins	d0,d1{28:4}
   
   ; green
   ror.l	#8,d0
   bfins	d0,d1{24:4}

   ; red
   ror.l	#8,d0
   bfins	d0,d1{20:4}

	;move.l	#$0ff,d1
	move	d1,34(a1)	; colour 1 high word in current line in coplinesm16

	; correct pointer into copper colour list
	add.l	#LINECOLMODE25_LENGTH,a1
	dbf	d3,.loopc31
	bra	.out



   nop

.out:	
.clip:
	movem.l	(a7)+,d2-d3
	endc

	rts

	
SCmode16:
	ifnd	NOMODE16
; in: d0 - colour index, a0 - pointer to gradient / list of 180 colours (4 bytes each, 00rrggbb)
; out: none

; routine will update all lines of colour index d0 with gradient colours from a0
; setup

	tst	PageFlips		; pass through on init (before any c2p display has happened)
	beq.s	.ok
	
	tst.l	DisplayCurrent	; only allow colour changes when c2p display after latest screenmode change has reached the front buffer
	bpl.s	.ok
	rts
.ok
	movem.l	d2-d3,-(a7)

	cmp	#0,d0
	beq	.col0
	cmp.l	#249,d0
	beq	.col249
	cmp.l	#250,d0
	beq	.col250
   cmp.l	#251,d0
	beq	.col251
   cmp.l	#252,d0
	beq	.col252
   cmp.l	#253,d0
	beq	.col253
   cmp.l	#254,d0
	beq	.col254
   cmp.l	#255,d0
	beq	.col255
	
	bra	.clip	

.col0	; write to coplinesm16+offset
	lea	coplinesm16,a1
	
	move.l	#179,d3	; counter
	move.l	#0,d1
	move.l	#0,d2

.loopc0
	move.l	(a0)+,d0	; get $00rrggbb in d0

	;move.l	#$123456,d0
	;want: 135 in d1, 246 in d2

	; blue
	bfins	d0,d2{28:4}
	ror.l	#4,d0
	bfins	d0,d1{28:4}
	ror.l	#4,d0

	; green
	bfins	d0,d2{24:4}
	ror.l	#4,d0
	bfins	d0,d1{24:4}
	ror.l	#4,d0

	; red
	bfins	d0,d2{20:4}
	ror.l	#4,d0
	bfins	d0,d1{20:4}
	;ror.l	#4,d0

	; use coplinesm16+LINECOL012_LENGTH*Line to write to registers
	;  offset 10: high word of colour 0
	;  offset 26: high word of colour 249
	;  offset 30: high word of colour 250
   ;  offset 34: high word of colour 251
   ;  offset 38: high word of colour 252
   ;  offset 42: high word of colour 253
   ;  offset 46: high word of colour 254
   ;  offset 50: high word of colour 255
   
	;   offset 18: low word of colour 0
	;   offset 58: low word of colour 249
	;   offset 62: low word of colour 250
   ;   offset 66: low word of colour 251
   ;   offset 70: low word of colour 252
   ;   offset 74: low word of colour 253
   ;   offset 78: low word of colour 254
   ;   offset 82: low word of colour 255
	; write d2 and d1 to col0 low and high
	;move.l	#$020,d1
	;move.l	#$020,d2

	move	d1,10(a1)	; colour 0 high word in current line in coplinesm16

	move	d2,18(a1)	; dito for low word

	; correct pointer into copper colour list
	add.l	#LINECOLMODE16_LENGTH,a1
	dbf	d3,.loopc0
	bra	.out

.col249
	lea	coplinesm16,a1
	
	move.l	#179,d3	; counter
	move.l	#0,d1
	move.l	#0,d2
.loopc249
	move.l	(a0)+,d0	; get $00rrggbb in d0

	;move.l	#$123456,d0
	;want: 135 in d1, 246 in d2

	; blue
	bfins	d0,d2{28:4}
	ror.l	#4,d0
	bfins	d0,d1{28:4}
	ror.l	#4,d0

	; green
	bfins	d0,d2{24:4}
	ror.l	#4,d0
	bfins	d0,d1{24:4}
	ror.l	#4,d0

	; red
	bfins	d0,d2{20:4}
	ror.l	#4,d0
	bfins	d0,d1{20:4}
	;ror.l	#4,d0

	move	d1,26(a1)	; colour 1 high word in current line in coplinesm16
	move	d2,58(a1)	; dito for low word

	; correct pointer into copper colour list
	add.l	#LINECOLMODE16_LENGTH,a1
	dbf	d3,.loopc249
	bra	.out

.col250
	lea	coplinesm16,a1
	
	move.l	#179,d3	; counter
	move.l	#0,d1
	move.l	#0,d2
.loopc250
	move.l	(a0)+,d0	; get $00rrggbb in d0

	;move.l	#$123456,d0
	;want: 135 in d1, 246 in d2

	; blue
	bfins	d0,d2{28:4}
	ror.l	#4,d0
	bfins	d0,d1{28:4}
	ror.l	#4,d0

	; green
	bfins	d0,d2{24:4}
	ror.l	#4,d0
	bfins	d0,d1{24:4}
	ror.l	#4,d0

	; red
	bfins	d0,d2{20:4}
	ror.l	#4,d0
	bfins	d0,d1{20:4}
	;ror.l	#4,d0

	move	d1,30(a1)	; colour 1 high word in current line in coplinesm16
	move	d2,62(a1)	; dito for low word

	; correct pointer into copper colour list
	add.l	#LINECOLMODE16_LENGTH,a1
	dbf	d3,.loopc250
   bra	.out

.col251
	lea	coplinesm16,a1
	
	move.l	#179,d3	; counter
	move.l	#0,d1
	move.l	#0,d2
.loopc251
	move.l	(a0)+,d0	; get $00rrggbb in d0

	;move.l	#$123456,d0
	;want: 135 in d1, 246 in d2

	; blue
	bfins	d0,d2{28:4}
	ror.l	#4,d0
	bfins	d0,d1{28:4}
	ror.l	#4,d0

	; green
	bfins	d0,d2{24:4}
	ror.l	#4,d0
	bfins	d0,d1{24:4}
	ror.l	#4,d0

	; red
	bfins	d0,d2{20:4}
	ror.l	#4,d0
	bfins	d0,d1{20:4}
	;ror.l	#4,d0

	move	d1,34(a1)	; colour 1 high word in current line in coplinesm16
	move	d2,66(a1)	; dito for low word

	; correct pointer into copper colour list
	add.l	#LINECOLMODE16_LENGTH,a1
	dbf	d3,.loopc251
   bra	.out

.col252
	lea	coplinesm16,a1
	
	move.l	#179,d3	; counter
	move.l	#0,d1
	move.l	#0,d2
.loopc252
	move.l	(a0)+,d0	; get $00rrggbb in d0

	;move.l	#$123456,d0
	;want: 135 in d1, 246 in d2

	; blue
	bfins	d0,d2{28:4}
	ror.l	#4,d0
	bfins	d0,d1{28:4}
	ror.l	#4,d0

	; green
	bfins	d0,d2{24:4}
	ror.l	#4,d0
	bfins	d0,d1{24:4}
	ror.l	#4,d0

	; red
	bfins	d0,d2{20:4}
	ror.l	#4,d0
	bfins	d0,d1{20:4}
	;ror.l	#4,d0

	move	d1,38(a1)	; colour 1 high word in current line in coplinesm16
	move	d2,70(a1)	; dito for low word

	; correct pointer into copper colour list
	add.l	#LINECOLMODE16_LENGTH,a1
	dbf	d3,.loopc252
   bra	.out

.col253
	lea	coplinesm16,a1
	
	move.l	#179,d3	; counter
	move.l	#0,d1
	move.l	#0,d2
.loopc253
	move.l	(a0)+,d0	; get $00rrggbb in d0

	;move.l	#$123456,d0
	;want: 135 in d1, 246 in d2

	; blue
	bfins	d0,d2{28:4}
	ror.l	#4,d0
	bfins	d0,d1{28:4}
	ror.l	#4,d0

	; green
	bfins	d0,d2{24:4}
	ror.l	#4,d0
	bfins	d0,d1{24:4}
	ror.l	#4,d0

	; red
	bfins	d0,d2{20:4}
	ror.l	#4,d0
	bfins	d0,d1{20:4}
	;ror.l	#4,d0

	move	d1,42(a1)	; colour 1 high word in current line in coplinesm16
	move	d2,74(a1)	; dito for low word

	; correct pointer into copper colour list
	add.l	#LINECOLMODE16_LENGTH,a1
	dbf	d3,.loopc253
   bra	.out

.col254
	lea	coplinesm16,a1
	
	move.l	#179,d3	; counter
	move.l	#0,d1
	move.l	#0,d2
.loopc254
	move.l	(a0)+,d0	; get $00rrggbb in d0

	;move.l	#$123456,d0
	;want: 135 in d1, 246 in d2

	; blue
	bfins	d0,d2{28:4}
	ror.l	#4,d0
	bfins	d0,d1{28:4}
	ror.l	#4,d0

	; green
	bfins	d0,d2{24:4}
	ror.l	#4,d0
	bfins	d0,d1{24:4}
	ror.l	#4,d0

	; red
	bfins	d0,d2{20:4}
	ror.l	#4,d0
	bfins	d0,d1{20:4}
	;ror.l	#4,d0

	move	d1,46(a1)	; colour 1 high word in current line in coplinesm16
	move	d2,78(a1)	; dito for low word

	; correct pointer into copper colour list
	add.l	#LINECOLMODE16_LENGTH,a1
	dbf	d3,.loopc254
   bra	.out

.col255
	lea	coplinesm16,a1
	
	move.l	#179,d3	; counter
	move.l	#0,d1
	move.l	#0,d2
.loopc255
	move.l	(a0)+,d0	; get $00rrggbb in d0

	;move.l	#$123456,d0
	;want: 135 in d1, 246 in d2

	; blue
	bfins	d0,d2{28:4}
	ror.l	#4,d0
	bfins	d0,d1{28:4}
	ror.l	#4,d0

	; green
	bfins	d0,d2{24:4}
	ror.l	#4,d0
	bfins	d0,d1{24:4}
	ror.l	#4,d0

	; red
	bfins	d0,d2{20:4}
	ror.l	#4,d0
	bfins	d0,d1{20:4}
	;ror.l	#4,d0

	move	d1,50(a1)	; colour 1 high word in current line in coplinesm16
	move	d2,82(a1)	; dito for low word

	; correct pointer into copper colour list
	add.l	#LINECOLMODE16_LENGTH,a1
	dbf	d3,.loopc255
   bra	.out
   nop

.out:	
.clip:
	movem.l	(a7)+,d2-d3
	endc
	rts



_SetLine:
	ifnd	NOMODE15
; in: a0 - bitplane id (0..7) , d0 - pointer to bitplane data , d1 - line number
;
; out: none
;
; routine will update line d1 of bitplane a0 with data in d0
; allows for line-based effects, e.g. flood-fill, etc..
; currently (4.10.15) hard coded for mode15 (320x180, 32cols) upper 3 bits

; Funktion: Setze Bitplane (id in a0) für Zeile (d1) auf pointer (d0)
; input
;	move.l	#$12345678,d0	; pointer to bitplane data (datareg needed)
;	move.l	#150,d1		; lines
;	move.l	#$00000006,a0	; id for bitplane

	tst	PageFlips		; pass through on init (before any c2p display has happened)
	beq.s	.ok
	
	tst.l	DisplayCurrent	; only allow colour changes when c2p display after latest screenmode change has reached the front buffer
	bpl.s	.ok
	rts
.ok

; sanity checks
	cmp.l	#0,d1		; line <0?
	blt	.clip

	cmp.l	#179,d1		; line >179?
	bgt	.clip

; setup
	tst	d0	; emptyline?
	bne.w	.notempty
	move.l	#emtpylinem15,d0
.notempty:
	mulu.l	#LINE678_LENGTH,d1		; lines * LINE678_LENGTH

	cmp.l	#5,a0			; Amiga RKM counts 1..8, but we want 0..7
	beq	.bpl6
	cmp.l	#6,a0
	beq	.bpl7
	cmp.l	#7,a0
	beq	.bpl8


	bra	.clip	

; output d2 (high), d3 (low)
;	move	d0,d3
;	swap	d0
;	move	d0,d2

.bpl8	; write to bplm15+d1+offset
	lea	bplm15,a1
	move	d0,26(a1,d1.l)	; bitplane 8 low word in line d1 in bplm15 
	swap	d0
	move	d0,22(a1,d1.l)	; dito for high word
	rts

.bpl7	; write to bplm15+d1+offset
	lea	bplm15,a1
	move	d0,18(a1,d1.l)	; bitplane 7 low word in line d1 in bplm15 
	swap	d0
	move	d0,14(a1,d1.l)	; dito for high word
	rts

.bpl6	; write to bplm15+d1+offset
	lea	bplm15,a1
	move	d0,10(a1,d1.l)	; bitplane 6 low word in line d1 in bplm15 
	swap	d0
	move	d0,06(a1,d1.l)	; dito for high word
		
	
.out:	rts

.clip:
	endc
	;move.l	#-1,d0
	rts
;-------------- Main Stuff from WOS
_InitEfx:
; in: a0 - effect definitions , a1 - CallEfxinfo of the calling process
;
;out: d0=0 (error) or d0=^relocated effect
;
;routine will update effect definitions

	move.l	16(a0),d1		;Init done?
	tst	d1
	beq.s	.notdone		;not yet

	move.l	8(a0),d0		;return address of code
	rts
	
.notdone
	pushns
	move.l	d0,.d0			;user params
	move.l	a0,a3			;store effect definitions

	;--- decrunch effect
	move.l	(a3),a0		;data to decrunch
	bsr	_InitwPAC
	cmp.l	#-1,a0		;-1=error , 0=not crunched
	beq	.error
	cmp.l	#0,a0
	bne	.wascrunched
	move.l	(a3),a0		;restore address of uncrunched effect
.wascrunched
	move.l	d0,.banknumber	;free this after relocation
	move.l	a0,.decr
	
	;--- relocate effect
	push	d1-a6
	jsr	_LVOHunkLength          ;get size requirements into d0
	pull	d1-a6
	jsr	_SYSAllocAny		;alloc d0 bytes 
	tst	d0			;address or 0 (d1=banknumber)
	beq	.error
	move.l	d1,12(a3)		;efxbanknumber into DEFEFX

	move.l	.decr(pc),a0		;source (decrunched data)
	move.l	d0,a1			;dest   (allocated memory)
	push	d1-d7/a1-a6
	jsr	_LVOHunkRelocate        ;relocate file...
	pull	d1-d7/a1-a6
	tst.l	d0	
	bne	.error			;did relocation fail?
	
	move.l  a0,a2			;ptr to relocated effect
	move.l	a2,8(a3)		;write to DEFEFX

	move.l	$4.w,a6
	jsr	-636(a6)                ;CacheClearU

	move.l	.banknumber(pc),d0	;free memory of decrunched data
	beq.s	.notused
	bsr	_SYSErase
	move.l	#0,.banknumber
.notused

	;--- do some checks
	move.l	2(a2),d2		;should be dc.b "WOS",VERSION
	and.l	#-256,d2		;clear the version number
	cmp.l	#$574f5300,d2
	bne.s	.error
	move.l	2(a2),d2
	and.l	#255,d2			;clear the "WOS" tag
	cmp.w	#FILEVERSION,d2
	blt.s	.error			;too old fileversion


	;--- call effects init-routine
	lea	_wosbase(pc),a0
	move.l	.d0,d0			;user-data

	move.l	6(a2),a6		;init-routine
	cmp.l	#0,a6
	beq.s	.noinit
	push	d0-a6
	jsr	(a6)			
	pull	d0-a6
.noinit
	move.l	#-1,16(a3)		;Init done to DEFEFX


	;--- possible exits
.success
	move.l	a2,d0
	pullns
	rts

.error	move.l	12(a3),d0		;free efxbank
	beq.s	.e1
	bsr	_SYSErase
	move.l	#0,12(a3)
.e1
	move.l	.banknumber(pc),d0	;free decrunched data
	beq.s	.e2
	bsr	_SYSErase
	move.l	#0,.banknumber
.e2
	moveq	#0,d0
	pullns
	rts

.banknumber	dc.l	0	;must be syserased if not zero
.d0	dc.l	0		;user-data
.decr	dc.l	0		;ptr to decr data


AllEfxPseudoTimer	dc.l	0	;wird von jedem Effekt um dessen
				;Länge erhöht
_CallEfxOnce:
; in: a0 - effect definitions , a1 - CallEfxinfo of the calling process
;
;out: d1=0 (error) or d1=-1 (success)
;
;d0 is safe for your params

	pushns

	move.l	16(a0),d1	;Init done?
	beq	.error

	;--- extract infos from a1 and set the timers
	move.l	a1,a5	;_childVBIptr
	move.l	a1,a4	
	add.l	#4,a4	;Lev3Timer
	move.l	a1,a2
	add.l	#8,a2	;ChildTimer

	move.l	a0,a3	;store effect definitions

	;--- Timer Vergleich und Anpassung
	move.l	4(a3),d4		;effects lenght
	add.l	d4,AllEfxPseudoTimer
	move.l	AllEfxPseudoTimer(pc),d4

	sub.l	Timer(pc),d4		;-> allowed time to run
	tst	d4
;aaargh
	ble.s	.dontrun		;negative or null time not allowed

	move.l	d4,(a2)			;allowed time -> ChildTimer

	move.l	(a4),d2			:-> effects delay in d2
	move.l	#0,(a4)			;-> reset Lev3Timer
					;(start counting for the client)

.run	;--- go 
	move.l	8(a3),a2		;^relocated effect	
	move.l	d4,d1			;total allowed time for the effect
	lea	_wosbase(pc),a0
	move.l	a5,a1			;_childVBIptr
					;(where to write the VBI back to)

	move.l	_mmstabptr(a0),-(a7)	; very important!
	push	d0-a6
	jsr	(a2)                    ; *** run relocated program
	pull	d0-a6
	move.l	(a7)+,_mmstabptr(a0)

	move.l	#0,(a4)			;-> reset Lev3Timer
				;(don't know why we need this, but we do!!!)

	move.l	d0,a2			;store returncode
	jsr	_CheckExit
	cmp	#2,d0			; User Exit requested?
	beq	.error	; directly quit. if you need to clenup something,
			; you have to install an Exit-routine!
	
	bsr	_ClearPlanes

	jsr	_ClearExit
	move.l	a2,d0

.dontrun
	pullns
	moveq	#-1,d1		;d0 is for params
	rts

.error	pullns
	moveq	#0,d1
	rts


_ExitEfx:
; in: a0 - effect definitions , a1 - CallEfxinfo of the calling process
;
;routine will update effect definitions
	push	a2-a3

	move.l	8(a0),a2	;^relocated code ?
	cmp.l	#0,a2
	beq.s	.noexit

	move.l	10(a2),a3	;Exit-routine ?
	cmp.l	#0,a3
	beq.s	.noexit
	push	d0-a6
	jsr	(a3)
	pull	d0-a6

.noexit
	move.l	#0,(a1)		;kill _childVBIptr

	move.l	#0,16(a0)	;remove Init done
	move.l	a0,a2

	move.l	12(a0),d0	;free memory of relocated code
	jsr	_SYSErase	

	move.l	a2,a0
	move.l	#0,12(a0)	;banknumber
	move.l	#0,8(a0)	;address of code

	move.l	#-1,20(a0)	;Exit done to DEFEFX
	pull	a2-a3
	rts

_CallEfx:
; in: a0 - effect definitions , a1 - CallEfxinfo of the calling process
;out: d0 - 0=error , -1=success

	push	a2-a4

	move.l	a0,a2		;store essential infos
	move.l	a1,a3
	move.l	d0,a4

	bsr	_InitEfx
	tst.l	d0		;0=error or address of relocated code
	beq.s	.error	

	move.l	a2,a0
	move.l	a3,a1
	move.l	a4,d0
	bsr	_CallEfxOnce
			;no check for errors because we must exit anyway

	move.l	a2,a0
	move.l	a3,a1
	bsr	_ExitEfx
			

	pull	a2-a4
	moveq	#-1,d0
	rts

.error
	pull	a2-a3
	moveq	#0,d0
	rts


;++++++++++++++ The Memory Allocation Routines
	ifnd	NOMMS	
_AllocChip
		move.l	d1,d2		;banknumber
	        move.l  #$30002,d1      ;attributes (leer,am stück+chip)
		jsr	__allocbank
		rts
	
_Alloc
		move.l	d1,d2		;banknumber
	        move.l  #$30001,d1      ;attributes (leer,am stück+public)
		jsr	__allocbank
		rts
_Erase
		jsr	__erase
		rts

_EraseAll
		jsr	__eraseall
		rts

_Start
		jsr	__start
		rts
_Length
		jsr	__length
		rts

;_GetAny
;		jmp	__getany

_AllocAny
		jsr	__allocany
		rts

_AllocAnyChip
		jsr	__allocanychip
		rts

;---


_SYSAllocChip
		move.l	d1,d2		;banknumber
	        move.l  #$30002,d1      ;attributes (leer,am stück+chip)
		bsr	_swaptosys
		jsr	__allocbank
		bsr	_swaptoclient
		rts
	
_SYSAlloc
		move.l	d1,d2		;banknumber
	        move.l  #$30001,d1      ;attributes (leer,am stück+public)
		bsr	_swaptosys
		jsr	__allocbank
		bsr	_swaptoclient
		rts
_SYSErase
		bsr	_swaptosys
		jsr	__erase
		bsr	_swaptoclient
		rts
_SYSEraseAll
		bsr	_swaptosys
		jsr	__eraseall
		bsr	_swaptoclient
		rts
_SYSStart
		bsr	_swaptosys
		jsr	__start
		bsr	_swaptoclient
		rts
_SYSLength
		bsr	_swaptosys
		jsr	__length
		bsr	_swaptoclient
		rts
;_SYSGetAny
;		bsr	_swaptosys
;		jmp	__getany
;		bsr	_swaptoclient

_SYSAllocAny
		bsr	_swaptosys
		jsr	__allocany
		bsr	_swaptoclient
		rts
_SYSAllocAnyChip
		bsr	_swaptosys
		jsr	__allocanychip
		bsr	_swaptoclient
		rts

_swaptosys	lea	_wosbase(pc),a6
		move.l	_mmstabptr(a6),_swapstore
		move.l	#sysmmstable,_mmstabptr(a6)
		rts	
_swapstore	dc.l	0
_swaptoclient	lea	_wosbase(pc),a6
		move.l	_swapstore(pc),_mmstabptr(a6)
		rts

	endc

;++++++++++++++ Some Client-Funtions
;nil:		;Dummy-Function for unincluded jumptable-functions
;	moveq	#-1,d0
;	rts


_WaitVBL
	bra	wait_vert_blanc
	
_CheckExit:
	moveq	#0,d0
	move.b	Esc(pc),d0	;1=Efx Exit / 2=User Exit
	rts

_wosMouseX:
_MouseX:
	moveq	#0,d0
	move	MX,d0
	rts

_wosMouseY:
_MouseY:
	moveq	#0,d0
	move	MY,d0
	rts

_VBIHook:
;	lea	_wosbase(pc),a6		;most probably redundant
		move.l	a0,L3_VBI(a6)		;because of the VBIHOOK macro
	rts

;++++++++++++++ Some Server-Functions
_InitwPAC:
; in: a0 - ^wPAC file
;out: a0 - ^decrunched data or zero (notcrunched) or -1 (error)
;     d0 - banknumber of decrunched data
;
; preserves all other registers

	ifd	NODECRUNCH
		moveq	#0,d0
		move.l	#-1,a0
		rts
	else
		push	d1-d7/a1-a6
		cmp.l	#"wPAC",(a0)
		bne.s	.decr		;most probably already decrunched

		move.l	a0,-(a7)
		move.l	4(a0),d0
		add.l	#8,d0

		bsr	_SYSAllocAny
		move.l	(a7)+,a0
		move.l	d0,a1		;adr or 0
		beq.s	.error
		move.l	d1,.banknumber
	
		add.l	#24,a0		;skip to beginning of description
		move.l	(a0)+,(a1)+	;copy the 8 bytes long "bankname"
		move.l	(a0)+,(a1)+

		bsr	_Decrunch
		move.l	d0,a0
		move.l	.banknumber(pc),d0
		pull	d1-d7/a1-a6
		rts

.error		move.l	#-1,a0
		moveq	#0,d0
		pull	d1-d7/a1-a6
		rts
.decr		sub.l	a0,a0
		moveq	#0,d0
		pull	d1-d7/a1-a6
		rts

.banknumber	dc.l	0
	endc	;of NODECRUNCH

_SetExit:
	lea	Esc(pc),a0
	move.b	#1,(a0)		;Effect Exit
	rts

_ClearExit:
	lea	Esc(pc),a0
	move.b	#0,(a0)
	rts

	ifd	DEBUG
WaitDebug:	;wait at the end until the window is closed
		move.l	intbase(pc),a6
			
		sub.l	a0,a0			;window
		lea	debSTRUCT,a1
		sub.l	a2,a2			;IDCMP_ptr
		sub.l	a3,a3			;ArgList

		jsr	-588(a6)		;EasyRequestArgs
		rts

debSTRUCT:
		dc.l	debSTRUCTend-debSTRUCT	;sizeof
		dc.l	0	;flags
		dc.l	debtitle
		dc.l	debbody
		dc.l	debgadgets
		
debSTRUCTend:

debtitle:		dc.b	"DEBUG",0
debbody:	
		dc.b	"Now find the Enforcer hits!",0

debgadgets:	dc.b	"OK",0
		even
	endc	;of DEBUG

	ifnd	ABSOLUTELYNOERRORS
PrintErrors:		 
		move.l	intbase(pc),a6
		sub.l	a0,a0
		call	DisplayBeep
		jsr	-96(a6)
			
		sub.l	a0,a0			;window
		lea	errSTRUCT,a1
		sub.l	a2,a2			;IDCMP_ptr
		sub.l	a3,a3			;ArgList

		jsr	-588(a6)		;EasyRequestArgs
		rts

errSTRUCT:
		dc.l	errSTRUCTend-errSTRUCT	;sizeof
		dc.l	0	;flags
		dc.l	errtitle
errstr		dc.l	errbody			;replaced with a custom ptr by an error
		dc.l	errgadgets
		
errSTRUCTend:

errtitle:		dc.b	"WickedOS ERROR",0
errbody:	
		dc.b	"An error has occured!",10
		dc.b	10
		dc.b	"Remove the NOERRORS flag to get it more precise",0

errgadgets:	dc.b	"Quit",0
		even
	endc	;of DEBUG
	
;++++++++++++++ WOS Init: and Exit:
WOSInit:		;d0<>0 = error
	move.b	Esc(pc),d0
	tst.b	d0	;has this been run before saving?
	bne	.error	;...nothing would be the same then -> exit

;------ open libraries and get output-handle
	;--- open dos
	lea	dosname(pc),a1
	moveq	#0,d0
	move.l	4.w,a6
	jsr	-552(a6)
	lea	dosbase(pc),a0
	move.l	d0,(a0)
	beq.w	.error
	;--- open gfx
        lea     gfxname(pc),a1
        moveq   #39,d0          ;kick3.0
        move.l  4.w,a6
        jsr     -552(a6)
        lea     gfxbase(pc),a0
        move.l  d0,(a0)
        beq.w   .error
	;--- open intuition
        lea     intname(pc),a1
        moveq   #39,d0          ;kick3.0
        move.l  4.w,a6
        jsr     -552(a6)
        lea     intbase(pc),a0
        move.l  d0,(a0)
        beq.w   .error

	ifnd	NOINFO
	;--- get handle
	        call    Output,dos
		lea	outputhandle(pc),a0
	        move.l  d0,(a0)
	endc

;------ Init the dk3dbase pointer
	ifd	DK3D
		lea	dk3dbin,a0
		lea	_wosbase(pc),a1
		move.l	a0,dk3dptr(a1)
	        jsr     InitDK3DSinus
	endc

;------ Setup Framesync stuff
	move.l	wosbase,a0
	lea	bufstate,a1
	move.l	a1,buf1stateptr(a0)
	move.l	a1,buf2stateptr(a0)

	move.l	#0,buf1ptr(a0)
	move.l	#0,buf2ptr(a0)


;------ Fill ATTNFLAGS and CPU fields
	lea	_wosbase(pc),a0
        move.l  4.w,a6
        move.w	296(a6),d0
        move.w	d0,ATTNFLAGS(a0)
        and	#%10001111,d0		; fpu bits rausmaskieren
        rol	#1,d0           
        rol.b	#3,d0			; cpubits als 5 bit muster
        ror	#4,d0			; in d0 speichern
        move.w	d0,CPU(a0)		; (68010=1/68020=3..68060=31)

	; check for 68020 minimum
	cmp	#3,d0
	bge	.cpuok

	move.l	#.cpufail,d2
	bsr	printit

	move.l	#-1,d0
	rts
.cpufail	dc.b	"68020+ required",10,0
	even

.cpuok
	; check for FPU
        move.l  4.w,a6
        move.w	296(a6),d0
	and	#%01110000,d0
	tst	d0
	bne.s	.fpuok

	move.l	#.fpufail,d2
	bsr	printit

	move.l	#-1,d0
	rts
	
.fpufail	dc.b	"FPU required",10,0
	even

.fpuok

	; CPU and FPU ok
;	move.l	#.cpufpuok,d2
;	bsr	printit
;	bra.s	.continue
;
;.cpufpuok	dc.b	"CPU and FPU okay",10,0
;	even
;.continue	


;------ Chip-Speicher holen für Bitplanes und BlitBuffer
	
	;// change to double buffer
	move.l	#mode17size*8*2,d0	;double buffer, no blitbuffer
	;move.l	#mode8size*8*2,d0	;double-buffer


	ifnd	NOMODE6
		add.l	#(mode6size*6+64)*2,d0	;additional Bitbuffers
	endc
	lea	mem1siz(pc),a0
	move.l	d0,(a0)
	move.l	#MEMF_CHIP!MEMF_CLEAR,d1
	move.l	$4.w,a6
	call	AllocMem
	tst	d0
	bne	.memok

	;-- out of memory
	move.l	#.memfail,d2
	bsr	printit

	move.l	#-1,d0
	rts
.memfail	dc.b	"Error allocating memory for bitplanes",10,0
	even
	
.memok:	lea	mem1blk(pc),a0
	move.l	d0,(a0)
	move.l	d0,a0
	;------ die Pointer auf den Speicher richten
	lea	Bpl1(pc),a1									;//!!!magic
	move.l	a0,(a1)+	;Bpl1
	add.l	#mode17size*8,a0
	move.l	a0,(a1)+	;Bpl2
	;// no triple, no blit
	;add.l	#mode1size*8,a0
	;move.l	a0,(a1)+	;Bpl3
	;add.l	#mode1size*8,a0
	;move.l	a0,(a1)+ 	;c2p_blitbuf

;------ initialising the c2p pointers at m1: , m2: ... m5:	
;Format: dc.l Init,Main,Exit	
;if CPU >=15 , 68040 or better is available

	ifnd	NOMODE1
		lea	m1c2p,a0
		lea	m1,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc
.m1ok:

	ifnd	NOMODE2
		lea	m2c2p,a0
		lea	m2,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m2ok:

	ifnd	NOMODE3
		lea	m3c2p,a0
		lea	m3,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m3ok:

	ifnd	NOMODE4
		lea	m4c2p,a0
		lea	m4,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m4ok:

	ifnd	NOMODE5
		lea	m5c2p,a0
		lea	m5,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m5ok:
	ifnd	NOMODE6
		lea	m6c2p,a0
		lea	m6,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit

		bsr	Init18bit
	endc	
.m6ok:
	ifnd	NOMODE7
		lea	m7c2p,a0
		lea	m7,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m7ok:
	ifnd	NOMODE8
		lea	m8c2p,a0
		lea	m8,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m8ok:
	ifnd	NOMODE9
		lea	m9c2p,a0
		lea	m9,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m9ok:
	ifnd	NOMODE10
		lea	m10c2p,a0
		lea	m10,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m10ok:
	ifnd	NOMODE11
		lea	m11c2p,a0
		lea	m11,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m11ok:
	ifnd	NOMODE12
		lea	m12c2p,a0
		lea	m12,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m12ok:
	ifnd	NOMODE13
		lea	m13c2p,a0
		lea	m13,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m13ok:

	ifnd	NOMODE14
		lea	m14c2p,a0
		lea	m14,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m14ok:
	ifnd	NOMODE15
		lea	m15c2p,a0
		lea	m15,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m15ok:
	ifnd	NOMODE16
		lea	m16c2p,a0
		lea	m16,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m16ok:
	ifnd	NOMODE17
		lea	m17c2p,a0
		lea	m17,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit

		bsr	Init15bit
	endc	
.m17ok:
	ifnd	NOMODE18
		lea	m18c2p,a0
		lea	m18,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit

		bsr	Init15bit
	endc	
.m18ok:
	ifnd	NOMODE19
		lea	m19c2p,a0
		lea	m19,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit

		bsr	Init15bit
	endc	
.m19ok:
	ifnd	NOMODE20
		lea	m20c2p,a0
		lea	m20,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit

		;bsr	Init18bit
	endc	
.m20ok:
	ifnd	NOMODE21
		lea	m21c2p,a0
		lea	m21,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit

		;bsr	Init18bit
	endc	
.m21ok:
	ifnd	NOMODE22
		lea	m22c2p,a0
		lea	m22,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit

		;bsr	Init18bit
	endc	
.m22ok:
	ifnd	NOMODE23
		lea	m23c2p,a0
		lea	m23,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit

		;bsr	Init18bit
	endc	
.m23ok:
	ifnd	NOMODE24
		lea	m24c2p,a0
		lea	m24,a1	;dc.l 0,0,0
		move.l	a0,(a1)+	;Init
		add.l	#4,a0
		move.l	a0,(a1)+	;Main
		add.l	#4,a0
		move.l	a0,(a1)+	;Exit
	endc	
.m24ok:
   ifnd	NOMODE25
      lea	m25c2p,a0
      lea	m25,a1	;dc.l 0,0,0
      move.l	a0,(a1)+	;Init
      add.l	#4,a0
      move.l	a0,(a1)+	;Main
      add.l	#4,a0
      move.l	a0,(a1)+	;Exit
   endc	
.m25ok:

;------ preloading of AHX-waves
	ifd	MUSIC
		ifeq	MUSIC-AHX
			ifnd	AHXVBL
			lea	thxVertb(pc),a0
			moveq	#0,d0
			bsr	thxReplayer+thxInitCIA
			tst	d0
			bne.b	thxInitFailed
			endc
			sub.l	a0,a0   ;auto-allocate public (fast)
			sub.l	a1,a1   ;auto-allocate chip
			moveq	#0,d0	;load Waves if possible
			moveq	#0,d1	;Filters
			bsr	thxReplayer+thxInitPlayer
		endc
	endc


;------ initializing the loading routines
	ifnd	NOLOADING
		bsr	loadInit	;changes a6
	endc
	
;------ clearing the caches
	move.l	4.w,a6
	jsr	-636(a6)	;CacheClearU
	
	moveq	#0,d0
	rts

.error:	moveq	#-1,d0
	rts

WOSExit:
	move.l	d0,-(a7)	;safe the returncode

;------ freeing the loading routines
	ifnd	NOLOADING
		bsr	loadExit
	endc

	lea	_wosbase(pc),a6

	ifnd	NOMMS
		bsr	_EraseAll
		bsr	_SYSEraseAll
	endc


	move.l	4.w,a6
	move.l	mem1siz(pc),d0
	move.l	mem1blk(pc),a1
	call	FreeMem

	
	ifd	PRINTSTATS
	;--- print some stats
        movem.l a2-a3,-(sp)
        lea     fstats(pc),a0           ;format string
        lea     stats(pc),a1

	;- move	values
	move.l	framesDisplayed(pc),d0
	move.l	Timer(pc),d1
	move.l	d0,(a1)		;frames
	move.l	d1,4(a1)	;ticks
	mulu.l	#50,d0		;50 ticks/second
	divu.l	d1,d0
	move.l	d0,8(a1)	;fps
        
        lea     stuffchar(pc),a2        ;copy-routine
        lea     ostring(pc),a3          ;output string
        call    RawDoFmt,exec           ;i.e. printf
        move.l  #ostring,d2
        bsr	printit
        movem.l (sp)+,a2-a3
	endc
	
	;--- close down
	closelib	int
	closelib	gfx
	closelib	dos

	move.l	(a7)+,d0		; return code
	rts

stats	dc.l	4,5,6
fstats	dc.b    'Displayed %ld frames in %ld ticks (%ld fps)',10,0
	even
ostring	ds.b	100
stuffchar:      move.b  d0,(a3)+        ; support routine for rawdofmt
        rts

	ifnd	NOMODE6
;------ 18 bit Maskenplanes erzeugen
Init18bit:
	lea	m6mask1,a0		; a0 = Zeiger auf Bitplane #1
	lea	(mode6xsize/8)*mode6ysize(a0),a1		; a1 = Zeiger auf Bitplane #2

	move.l	#$bbbbbbbb,d0		; d0 = Mask #1
;	move.l	#$dddddddd,d0	; for $d RGBB
	move.l	#$66666666,d1		; d1 = Mask #2


MakeHamPlanes:
	move	#mode6ysize*(mode6xsize/8)/4-1,d2	; d2 = Anzahl der Langworte
.Loop_01	
	move.l	d0,(a0)+		; Trage ein
	move.l	d1,(a1)+		; Trage ein
	dbf	d2,.Loop_01		; Alles geschafft ???
	rts
	endc

	ifnd	NOMODE17	;
;------ 15 bit Maskenplanes erzeugen
Init15bit:
	lea	m17mask1,a0		; a0 = Zeiger auf Bitplane #1
	;lea	(mode17xsize/8)*mode17ysize(a0),a1		; a1 = Zeiger auf Bitplane #2
	lea	m17mask2,a1

	move.l	#$6db6db6d,d0		; d0 = Mask #1
	move.l	#$db6db6db,d1		; d1 = Mask #2


	;move	#mode17ysize*(mode17linexsize/8)/4-1,d2	; d2 = Anzahl der Langworte
	move	#mode17size/4-1,d2
.Loop_01	
	move.l	d0,(a0)+		; Trage ein
	move.l	d1,(a1)+		; Trage ein
	dbf	d2,.Loop_01		; Alles geschafft ???
	rts
	endc

;------ Sprites setzen
_SetSprites:
; in: a0 - your spritelist (8 long-pointers to 8 sprites)
;	rts

	move.l	a0,a1
	move.l	sprlist(a6),a0

;	lea cop\.sptr,a0
;	lea sprites,a1
	moveq #7,d1
.lp	move.l (a1)+,d0
	move d0,6(a0)
	swap d0
	move d0,2(a0)
	addq.l #8,a0
	dbra d1,.lp
	rts
;
;	moveq #1,d1
;.l1	move.l #dummyspr,d0
;	move d0,6(a0)
;	swap d0
;	move d0,2(a0)
;	addq.l #8,a0
;	dbra d1,.l1
;	rts

;++++++++++++++ Processing the Commandline Arguments (taken from DeXFD)
	ifnd	NOINFO
ProcessArgs:
		cmp.l	#1,d0		; any Arguments (length >1)
		ble.s	.noinfo		; no INFO requested -> get out

	;--- answering the users request
		cmp.b	#"?",(a0)
		beq.s	.info


	        subq.l  #2,d0           ; Schonmal vorausgreifend das evtl. ...
	        cmp.b   #" ",(a0,d0)    ; ...SPACE am Ende entfernen und das RETURN
	        beq.s   .goon
	        addq.l  #1,d0           ; war doch kein Space (" ")

.goon	   	cmp.b   #$22,(a0)       ; anführungsstriche???
     	   	bne     .goon2            ; nein , kein problem
        
        	add.l   #1,a0           ; weg damit (pointer einen weiter setzen :-)    
        	subq.l  #2,d0           ; 2 anführungszeichen weniger

.goon2
                                ; länge des strings ist noch in d0
                                ; adresse ist noch in a0

        	move.l  d0,comlen	; für späteren param-check aufheben
        	lea     comstr,a1	;in den buffer...
        	bsr     copy            ;...kopieren

.noinfo:
		moveq	#-1,d0
		rts

.info
		lea	INFO(pc),a0
		move.l	a0,d2
		bsr	printit

		moveq	#0,d0		;INFO was requested
		rts


comlen:		dc.l	0
comstr:		ds.b	128
comlenstr:	dc.l	0,0	; Comlen, Comstrptr
outputhandle:	dc.l	0
copy                            ; a0=start a1=ziel d0=länge
        	move.l  d7,-(sp)        ; d7 retten
        	move.l  d0,d7
        	subq    #1,d7
copyloop
        	move.b  (a0)+,(a1)+     
        	dbeq    d7,copyloop     ; kopiert bis zum 1. nullbyte oder bis LÄNGE
        	move.l  (sp)+,d7
        	rts

_Print:		;don't call when system is killed
		push	d2
		move.l	_a0(a6),d2
		bsr	printit
		pull	d2
		rts

printit:
        	movem.l	a6/d3-d4,-(a7)
        	move.l	outputhandle(pc),d1
		beq.S	.error		;no handle!
        	move.l	d2,a0            ;       aptr to buffer needed in D2!!!                  
        	moveq	#0,d3
.l1:    	addq	#1,d3           ; ein zeichen mehr (Länge ermitteln)
        	tst.b	(a0)+
        	bne.s	.l1      
        	call	Write,dos       ; und ausgeben (d1=handle d2=buffer d3=len)
.error:		movem.l	(a7)+,a6/d3-d4
        	rts

	endc	;of NOINFO


;++++++++++++++ Kill the System
Take:
; IN: -
;OUT: D0=0 -> Okay 

        movem.l d1-a6,-(a7)

	jsr	wosInitHAL

	move.l	gfxbase(pc),a6

	; Get ChipRevBits0
	lea	_wosbase(pc),a0
	moveq	#0,d0
        move.b	236(a6),d0		
	move.w	d0,CHIPREVBITS(a0)
        btst	#2,d0			; 1=AGA
        beq.s	.noaga
	move.w	#-1,AGA(a0)
.noaga:
	; init Display and Interrupts
	; a0 - ptr to vertical blanc interrupt routine (to end with rts)

	lea	Level3VBI,a0
	jsr	wosActivateHAL	; in sub/wos_hal#?

	tst	d0
	bne	.error

        moveq   #0,d0           ;no error
        bra.s   .skip
.error  moveq   #-1,d0          ;failed to kill system
.skip   movem.l (a7)+,d1-a6
        rts


;-------------- Enable the System
Give:
; IN: -
;OUT: -
        movem.l d0-a6,-(a7)


	jsr	wosReleaseHAL


        movem.l (a7)+,d0-a6
        rts


;_ExecBase:
_execbase:
execbase:	dc.l	0

;_IntuitionBase:
_intbase:
intbase:        dc.l    0
intname:        dc.b    "intuition.library",0
        even
;_GraphicsBase:
_gfxbase:
gfxbase:        dc.l    0
gfxname:        dc.b    "graphics.library",0
        even
;_DosBase:
_dosbase:
dosbase:	dc.l	0
dosname:	dc.b	"dos.library",0
	even

vers	dc.b    "$VER: WickedOS "
	VERSION
	dc.b	" ("
	DATUM
	dc.b	 ")",0

	even
c2p_queue:	dc.l	0	;Pointer to the c2pQueue-Routine

	ifnd	NOINFO
		ifd	WOSASSIGN
			include	wos:sub/wos_infostring.s
		else
			include	sub/wos_infostring.s
		endc
	endc

;- leave the order of these untouched
Bpl1:	dc.l	0
Bpl2:	dc.l	0

;//!!!magic removed
;Bpl3:	dc.l	0
c2p_blitbuf	dc.l	0 	;Pointer to the CHIP Blit-Buffer

;// jetzt wohl eher die hälfte, also 128000, aber nur bei lowres, also doch noch 256k
mem1siz	dc.l	0	;256000 bytes
mem1blk	dc.l	0


;--- NEXTVBI
;called from old NEXTVBI macro
_NextVBI_obsolete:	
	; all NEXTVBI related code moved into INITWOS on 22.5.2010
	; it was still in the jump-table so just rts to retain compatibility
	; and keep the structure of the jumptable intact
	rts


lop:
framesRendered:		dc.l	-1	; i.e. efx
framesDisplayed:	dc.l	0	; i.e. c2p`ed

;-------------- Level 3 Vertical Blanc Interrupt
Level3VBI:
	push	d2-d7/a2-a4

	;--- update hardware display
        lea     $dff000,a6      
	bsr     _RefreshDisplay
	
	;--- check the mod
	bsr	GetPosVBI

	;--- call the Effecttracker
	cmp.l	#0,ETpatternlist
	beq.s	.noET
	bsr	ETVBI
.noET        

        ;--- Vertb. User (from the effect)      
        lea     _wosbase(pc),a0
        tst.l   L3_VBI(a0)
        beq.s   .novertbuser
        move.l  L3_VBI(a0),a0
	jsr	(a0)

.novertbuser:
    
	ifd	MUSIC

		ifeq	MUSIC-THX
			jsr	othxVertb
		endc

		ifeq	MUSIC-AHX
			ifd	AHXVBL
				jsr	thxVertb
			endc
		endc
	endc

        ;--- timer
        move.b  TimerSwitch(pc),d0
        beq.s   .notimer
        lea	Timer(pc),a0
        addq.l	#1,(a0)
.notimer:

	;-- debug code
	tst.l	DisplayCurrent
	bmi.s	.noPalCon

	;-- check for AGA mode palette update
	move.b	AGAConv(pc),d0
	tst.b	d0
	beq.s	.noAGAPalCon
	lea	PalPhy(pc),a0
	move.l	#256,d0
	move.l	AGAPtr(pc),a1
	bsr	AGA_PalCon
	bra.s	.noPalCon

.noAGAPalCon:

	;-- check for OCS mode palette update
	move.b	OCSConv(pc),d0
	tst.b	d0
	beq.s	.noPalCon
	lea	PalPhy(pc),a0
	move.l	#32,d0
	move.l	OCSPtr(pc),a1
	bsr	OCS_PalCon
	bra.w	.noPalCon


.noPalCon:
	pull	d2-d7/a2-a4
	nop
	rts

;----------------------------- Wicked Soundsystem :)
_PlayMod:	;in: a0 - #module ; d0 - pattern or -1
	cmp.l	#0,a0
	bne.s	.ok
	rts

.ok
	pushns
	move.l	d0,.patpos
	bsr	_StopMod	;just to be sure

	;check type of module
	move.l	(a0),d1
	move.l	(4,a0),a1

	cmp.l	#"P61A",d1
	beq	.p61

	cmp.l	#"CPLX",d1
	bne.s	.nottp3
	cmp.l	#"_TP3",a1
	beq	.tp3
.nottp3
	cmp.l	#$54485800,d1
	beq.s	.thx

	cmp.l	#$54485801,d1
	beq.s	.ahx

	bra.w	.error
.p61
	ifne	WOS_P61
		move.l	a1,d1
;		btst	#14,d1		;!!! das bit ist das falsche!
;		beq.s	.nopackedsamples
		ifd	P61BUFFERSIZE
			lea	P61SampleBuffer,a2
			bra.s	.skipit
		else
;			bra.s	.error
		endc
.nopackedsamples:
		sub.l	a2,a2		;No packed samples
.skipit		sub.l	a1,a1		;No separate samples
		moveq	#0,d0		;Auto Detect
		bsr	P61Bin+P61_InitOffset
		move.b	#P61,Playing
		move.l	.patpos(pc),d0
		beq	.noP61jump
		bsr	P61Bin+P61_SetPositionOffset
.noP61jump		pullns
		rts
	else
		bra.s	.error
	endc

.tp3
	ifne	WOS_TP3
		move.l	a0,-(a7)
		bsr	FixCIABug
		waittime	#5     ; 1 sec wasted
		bsr	tp_end+TP3Bin

		move.l	(a7)+,a0
		move	#255,tp_volume+TP3Bin
		bsr	TP3Bin
		move.b	#TP3,Playing
		pullns
		rts
	else
		bra.s	.error
	endc
.thx
	ifne	WOS_THX
		move.l	a0,-(a7)
		sub.l	a0,a0   ;auto-allocate public (fast)
		sub.l	a1,a1   ;auto-allocate chip
		bsr	othxReplayer+othxInitPlayer

		move.l	(a7)+,a0
		bsr	othxReplayer+othxInitModule

		moveq	#0,d0   ;Subsong #0 = Mainsong
		moveq	#0,d1   ;Play immediately
		bsr	othxReplayer+othxInitSubSong
		;lea	othxCIAInterrupt,a0
		;moveq	#0,d0
		;bsr	othxReplayer+othxInitCIA
		;tst	d0
		;bne.b	.othxInitFailed
		pullns
		rts
	else
		bra.s	.error
	endc
.ahx
	ifne	WOS_AHX
		bsr	thxReplayer+thxInitModule
	
		moveq	#0,d0   ;Subsong #0 = Mainsong
		moveq	#0,d1   ;Play immediately
		bsr	thxReplayer+thxInitSubSong
		pullns
		rts
	else
		bra.s	.error
	endc
	nop

	rts
.error
	SERROR	Couldnt_play_the_module!
	even
	rts
	
.patpos	dc.l	0	;backup of the requested pattern-position
	
_StopMod:	moveq	#0,d0
	move.b	Playing(pc),d0
	beq.w	.quit

	;Stop running replayer
	ifne	WOS_P61
		cmp.b	#P61,d0
		bne.s	.notp61
		bsr	P61Bin+P61_EndOffset
		move.b	#0,Playing
		bra	.quit
.notp61
	endc
	
	ifne	WOS_TP3
		cmp.b	#TP3,d0
		bne.s	.nottp3
		bsr	tp_end+TP3Bin
		move.b	#0,Playing
		bra	.quit
.nottp3
	endc

	ifne	WOS_THX
		cmp.b	#THX,d0
		bne.s	.notthx
		;bsr     othxReplayer+othxKillCIA  ;don't forget!
		bsr	othxReplayer+othxStopSong
		bsr	othxReplayer+othxKillPlayer       ;don't forget!
		move.b	#0,Playing
		bra	.quit
.notthx
	endc
	
	ifne	WOS_AHX
		cmp.b	#AHX,d0
		bne.s	.notahx
		bsr	thxReplayer+thxStopSong
		bsr	thxReplayer+thxKillPlayer       ;don't forget!
		ifnd	AHXVBL
			bsr	thxReplayer+thxKillCIA		;don't forget!
		endc
		move.b	#0,Playing
		bra	.quit
.notahx
	endc
	
.quit
	rts

_Volume:
; in: d0 - volume (0..255)
	moveq	#0,d1
	move.b	Playing(pc),d1
	beq	.err
	nop
	ifne	WOS_P61
		cmp.b	#P61,d1
		bne.s	.notp61
		lsr	#2,d0
		lea	P61Bin,a0
		move	d0,P61_MasterVolume(a0)
.notp61
	endc

.err	
	rts


;--- only possible with P61
GetPosVBI
	moveq	#0,d0
	move.b	Playing(pc),d0
	beq.s	.err
	nop
	ifne	WOS_P61			;extract infos from playing P61 mod
		cmp.b	#P61,d0
		bne.w	.notp61
		moveq	#0,d1
		lea	P61Bin,a0
		move	P61_Pattern(a0),d0
;			move	#0,P61_Pattern(a0)
		move	d0,Pattern
		move	P61_Position(a0),d0
;			move	#0,P61_Position(a0)
		move	d0,Position
		move	P61_Row(a0),d0
;			move	#0,P61_Row(a0)
		move	d0,Row
		move	P61_E8_info(a0),d0
			move	#0,P61_E8_info(a0)
		move	d0,E8
		rts
.notp61
	endc
.err
	rts

_GetPos:
; in: -
;out: d0-d3 pat,pos,row,e8
;     a0    ptr to P61Bin (to get all the infos about the mod if wanted)

	moveq	#0,d0
;	move.b	Playing(pc),d0
;	beq.w	.err
;	nop
;	ifne	WOS_P61
		move	Pattern,d0
		move	Position,d1
		move	Row,d2
		move	E8,d3
		rts
;.notp61
;	endc


.err	moveq	#-1,d0
	rts

	;these will be filled by the supported replay-routines.
	;if a replay doesn't support GetPos, it will return -1 in d0
	
Playing:	dc.b	0	;1 for p61 - 2 for tp3 - 4 for thx - 8 for ahx - 0 for nothing
	even

_ETpattern:
Pattern:	dc.w	0

_ETposition:
Position:	dc.w	0

_ETrow:
Row:		dc.w	-1
lastRow		dc.l	0

;not needed to xdef for adpcm
E8:		dc.w	0


;----------------------------- Effecttracker
_EffectTracker:
;called to initialize the ET (a0 - ptr to a patternlist or 0 to switch off)
	cmp.l	#0,a0
	bne.s	.noexit
	move.l	#0,ETpatternlist	;off
	rts

.noexit
	move.l	a0,d1
	move.l	d2,_d2(a6)
	moveq	#0,d2
	;-- check each pattern
.lp	move.l	(a0)+,a1
	cmp.l	#0,a1
	beq.s	.done		; 0=end
	cmp.l	#-1,a1		;-1=repeat
	beq.s	.done
	move	(a1),d0		;check for tag
	cmp	#"ET",d0
	bne.s	.err
	addq.l	#1,d2
	bra.s	.lp
	
.done
	;-- the patternlist is ok
	move.l	d1,ETpatternlist
	move.l	d2,ETlen
	move.l	-4(a0),ETloop
	move.l	_d2(a6),d2
	rts

.err
	SERROR	Effecttracker:_error_in_patternlist
	rts

ETpatternlist	dc.l	0
ETloop		dc.l	0	;indicates: -1=loop, 0=end
ETlen		dc.l	0	;number of patterns

ETVBI:
	moveq	#1,d1
	moveq	#1,d2
	move	Position(pc),d1
	move	Row(pc),d2
	
	; row change since last VBI?
	move.l	lastRow,d3
	cmp.l	d3,d2
	beq.s	.noETcall	; still the same row, don't trigger again
	move.l	d2,lastRow	; save for next check

	;-- match position in mod and patternlist (-> d1 is new position)
	moveq	#0,d4		;any loop neccessary?
	move.l	ETlen,d0
	subq.l	#1,d0
	move.l	ETloop,d3
.l1	cmp	d1,d0		;higher position than etpatterns?
	bhs.s	.l1out
	sub.l	ETlen,d1
	addq.l	#1,d4
	bra.s	.l1		;loop until position is valid
.l1out	
	;-- shall we loop?
	cmp.l	#-1,ETloop
	beq.s	.l2out		;loop=on

	;- stop here if d4<>0 (end mode)
	tst	d4
	beq	.l2out
	rts			;--> out of pattern-data in END mode

.l2out
	;-- match row in mod (d2) and pattern
	move.l	ETpatternlist,a0
	move.l	(a0,d1.l*4),a1	;get ptr to ETpattern
	moveq	#0,d1
	move.b	(2,a1),d1	;number of rows in ETpattern
	move.l	d1,d3
	subq.l	#1,d1
	moveq	#0,d4		;any loops?
.l3	cmp.l	d2,d1
	bhs.s	.l3out
	sub.l	d3,d2
	addq.l	#1,d4
	bra.s	.l3		;loop until row is valid
.l3out


	;-- shall we loop?
	cmp.b	#-1,(3,a1)
	beq.s	.l4out		;loop=on

	;- stop here if d4<>0 (end mode)
	tst	d4
	beq	.l4out
	rts			;--> out of row-data in END mode
.l4out


	;--pattern
	move.l	(4,a1,d2.l*4),a2
	cmp.l	#0,a2
	beq.s	.noETcall

	lea	_wosbase(pc),a6
	jsr	(a2)
	
.noETcall
	rts
;----------------------------- SaveFrames as BMP
;also occupies a bss section at the bottom of this source

	ifd	SAVEFRAMES
_saveframe:
; in: a0 - buffer to save
;     a1 - colors to use
;     d0 - width
;     d1 - height
;
; will save to the current path (use asmone`s "v" command to change it)
	pushns
	move.l	d0,d4	;x
	move.l	d1,d5	;y
	move.l	d5,d6
	muls.l	d4,d6	;x*y
	move.l	a0,a3	;buf
	move.l	a1,a4	;col

	;--- make a unique name (8+3)
	move.l	Timer(pc),d0
	lea	bmpstring(pc),a0
	bsr	bmpmakename
	move	#$743a,bmpstring	;"t:"

	;--- convert to bmp
	move.l	d4,d0	;x
	move.l	d5,d1	;y
	move.l	a3,a0	;buf
	lea	bmp,a1
	move.l	a4,a2	;col
	pushns
	bsr.l SaveBMP
	pullns

	;--- save it
	bsr	lenableloading
	lea	bmp,a0
	move.l	#1024+54,d0
	add.l	d6,d0
	bsr	dosave
	bsr	ldisableloading

	pullns
	rts

_saveqd:
	move.l	#320,d0
	move.l	#200,d1
	lea	Buffer,a0
	lea	Cols,a1
	bsr	_saveframe
	rts

	WOSINCLUDE	sub/misc/savebmp.s	;written by Darken
bmpfilehandle	dc.l	0
bmpstring	blk.b	2,-1
bmpfilename	blk.b	8,-1	;8+3 names (FAST Videomachine compatible)
	dc.b	".bmp",0
	even
;
;this version is modified to output save-names. it doesn`t do its original job!
;

;IntToDec:
bmpmakename:
	move.l	a0,d1		;\
	subq	#1,d1		;/für die längenberechnung am schluß
	move.l	d1,-(sp)
	moveq	#9,d1		
.l1	move.b	#0,(a0)+	;der String wird erstmal mit Nullen gefüllt
	dbra	d1,.l1
	sub.l	#10,a0		;der pointer ist ja um 12 zu weit gewesen

	movem.l	d2-d3,-(sp)	;D2-3 retten (D0-1 + A0-1 sind Trashregister!)
	lea	.pottab(pc),a1	;wo ist die tabelle !?!
	move.l	(a1)+,d1	;1. vergleichszahl (eine Milliarde)
	moveq	#0,d2		;ziffer (hält die Stellenergebnisse)
	moveq	#0,d3		;ist schon eine andere zahl als 0 vorgekommen?
	
	tst.l	d0
	bpl.s	.again		;positiv ?
	neg.l	d0		;nein,negieren
	move.b	#"-",(a0)+	;"-" davor

.again	cmp.l	d1,d0		;zahl kleiner als vergleichszahl ???
	blo.s	.makeascii	;ziffer ausgeben + nächste stelle weitermachen

	addq	#1,d2		;stellenergebnis erhöhen	
	sub.l	d1,d0		;vergleichszahl abziehen
	bra.s	.again		;nochmal vergleichen
	
.makeascii
	tst.b	d2		;<>0
	beq.s	.goon	
	addq	#1,d3		
.goon	tst.b	d3		;schon mal eine zahl <> 0 dagewesen?
;	beq.s	.skipnill	;nein , dann auch keine 0 ausgeben
	add.b	#$30,d2		;ziffer nach ascii wandeln
	move.b	d2,(a0)+	;und in den string schreiben

.skipnill moveq	#0,d2		;ziffer wieder löschen

	move.l	(a1)+,d1	; nächste vergleichszahl holen	
	tst.l	d1		; ist die vergleichszahl schon 0 ???
				; (d.h., wir sind fertig)
	bne.s	.again		; nein, also nochmal
	tst.b	d3		; schon mal eine zahl ausgegeben?
	bne.s	.ok
	move.b	#"0",(a0)+	; die zahl war eine 0...
.ok	movem.l	(sp)+,d2-d3
	move.l	(sp)+,d1		
	move.l	a0,d0
	sub.l	d1,d0		; ergibt die länge des strings
	rts			; endlich fertig , zurückspringen

	even
.pottab				;10er Potenz-Tabelle
	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	1

	dc.l	0			; als endmarkierung ...

***************************************************************************

dosave                          ; speichert eine Datei ab
                                ; in:
                                ;       A0 - Adresse
                                ;       D0 - Länge
                                ; out:  D0=0 - Error

***************************************************************************
***************************************************************************

************** jetzt abspeichern...
	pushns
	movem.l	a0/d0,-(a7)
;        lea     datastream(a5),a1       ;datastream
;	move.l	cliname(a5),(a1)
;        move.l  d0,4(a1)                ;Länge
;        lea     fsave(pc),a0            ;formatstring
;        lea     stuffchar(pc),a2        ;kopierroutine
;        lea     ostring(a5),a3          ;outputstring
;        call    RawDoFmt,exec           
;        print   ostring(a5)         ; alles ausgeben ("Writing ??? (...bytes)...")

;        lea     fdst(a5),a0
	lea	bmpfilename(pc),a0
;	lea	bmpstring(pc),a0
        move.l  a0,d1
        move.l  #1006,d2        ; modus: neue datei (alte wird gelöscht)
        call    Open,dos        ; datei öffnen
;        move.l  d0,filehandle(a5)         ; handle merken
	move.l	d0,bmpfilehandle
        bne     .openok2

;        bsr     freebufferinfo
;        bsr     freetargetbuffer
	movem.l	(a7)+,a0/d0
	pullns
;        error   noopen          ; "unable to open file..."
        rts

.openok2
	; move.l  filehandle(a5),d1               ; welches file? d1
	move.l	bmpfilehandle(pc),d1
	
        movem.l (a7)+,a0/d0                     ; Adresse+Länge
        move.l  a0,d2
        move.l  d0,d3
        call    Write,dos                       ; und endlich schreiben (phew!)
        tst.l   d0
        bge     .writeok                         ; größer/gleich 0 = geglückt    
                                                ; negativ = fehler
;        bsr     freebufferinfo
;        bsr     freetargetbuffer
        bsr     .closefile
;        error   nowrite                         ; "unable to write..."
	pullns
        rts

.writeok
;	bsr     freebufferinfo
;        bsr     freetargetbuffer        
        bsr     .closefile
	pullns
*       print   ok
;        bsr     return
        moveq   #-1,d0                          ; kein Error...
        rts                                     ; hier ist alles gelaufen!!!

.closefile
        move.l  bmpfilehandle(pc),d1
        cmp.l   #0,d1
        beq.s   .skip
        call    Close,dos
.skip   rts



	endc ;of SAVEFRAMES (miles above)


;----------------------------- Display.s


_DisplayM1	macro
	ifnd	NOMODE\1
		cmp.b	#\1,d0
		beq	.m\1
	endc
	endm

_DisplayM2	macro
	ifnd	NOMODE\1
.m\1
		move.l	(mode\1c2p,a0),a2
		cmp	#0,a2
		beq	.cont
		move.l	(mode\1ptr,a0),a0
		move.l	PlanarLogic1(pc),a1
		jsr	(a2)			;do the c2p!
		bra	.cont
	endc
	endm

_DisplayM2stat	macro
	ifnd	NOMODE\1
.m\1
		move.l	(mode\1c2p,a0),a2
		cmp	#0,a2
		beq	.cont
		move.l	(mode\1ptr,a0),a0
		move.l	mem1blk,a1		;3 buffers+ 1 blitbufffer lowres
		jsr	(a2)			;do the c2p!
		bra	.cont
	endc
	endm

;-------------- Den aktuellen ScreenMode konvertieren und anzeigen 
	even
_Display:
	move.l	a2,-(a7)

;	move.w	d0,Delay
	move.l	d0,d1			;Display, Display1 or Display2	
	beq.s	.dp0			;Display
	cmp	#1,d1
	beq.s	.dp1
	bsr	_Check2Frames
	bra.s	.dp0
.dp1	bsr	_CheckFrame
.dp0

.waitforsync:
	ifnd	FRAMETEST
		move.w	SwapMark(pc),d1
		bne.s	.waitforsync
	endc

	moveq	#0,d0
	move.b	ScreenMode(pc),d0	;mode 1-25 (0 for NoMode)
	beq	.cont


;	WINUAEBREAKPOINT
;	move.l	#2,bufstate	;!!! c2p in progress
	move.l	b1state,a0
	move.l	#2,(a0)

	lea	_wosbase(pc),a0
	
	_DisplayM1	25
	_DisplayM1	24
	_DisplayM1	23
	_DisplayM1	22
	_DisplayM1	21
	_DisplayM1	20
	_DisplayM1	19
	_DisplayM1	18
	_DisplayM1	17
	_DisplayM1	16
	_DisplayM1	15
	_DisplayM1	14
	_DisplayM1	13
	_DisplayM1	12
	_DisplayM1	11
	_DisplayM1	10
	_DisplayM1	9
	_DisplayM1	8
	_DisplayM1	7
	_DisplayM1	6
	_DisplayM1	5
	_DisplayM1	4
	_DisplayM1	3
	_DisplayM1	2
	_DisplayM1	1
	bra	.cont		;unsupported mode requested

	_DisplayM2	1	;1x1 - mode1
	_DisplayM2	2	;1x2
	_DisplayM2	3	;2x2
	_DisplayM2stat	4	;hires (unsupported,yet)
	_DisplayM2stat	5	;hires-laced (partly supported)
	_DisplayM2	6	;160x100 18bit
	_DisplayM2	7	;320x200 6 bit
	_DisplayM2	8	;320x180 8 bit, (intended framesynced c2p)
	_DisplayM2	9	;320x90 8 bit
	_DisplayM2	10	;160x90 8 bit
	_DisplayM2	11	;160x90 18 bit
	_DisplayM2stat	12	;hires (unsupported,yet (was meinte ich denn damit - ed.?))
	_DisplayM2stat	13	;hires-laced (partly supported)
	_DisplayM2	14	;320x180 6 Bit
	_DisplayM2	15	;320x180 Upper 5 Bit
	_DisplayM2	16	;320x180 8 Bit + copper cols 0, 249..255
	_DisplayM2	17	;220x180 15 Bit from 24 bit ARGB
	_DisplayM2	18	;220x180 15 Bit from 18 bit ARGB
	_DisplayM2	19	;220x90  15 Bit from 18 bit ARGB
	_DisplayM2	20	;220x180 18 Bit from 24 bit ARGB
	_DisplayM2	21	;220x180 18 Bit from 18 bit ARGB
	_DisplayM2	22	;220x90 18 Bit from 18 bit ARGB
	_DisplayM2	23	;220x180 12 Bit from 18 bit ARGB
	_DisplayM2	24	;320x180 5 Bit
   _DisplayM2	25	;320x180 5 Bit + copper cols 0, 25..31
	nop			;just leave this here
.cont	
;	WINUAEBREAKPOINT
;	move.l	#0,bufstate	;c2p from buffer done	2->0
	move.l	b1state,a0
	move.l	#0,(a0)

	bsr	_PlanarSwap	;will be performed in the next VBI

	add.l	#1,framesDisplayed

	move.l	(a7)+,a2
	rts

Delay:	dc.w	0
SwapMark:	dc.w	0
PlanarPhysic:	dc.l	0
PlanarLogic1:	dc.l	0
;PlanarLogic2:	
	dc.l	0

; DisplayCurrent is reset by setmode
DisplayCurrent	dc.l	0	; set by setmode. modified by display. is positive if c2p of a new screen has reached the front planar buffer. do not allow colour changes before (avoid vbi race conditions). 

; PageFlips is constantly increasing
PageFlips		dc.w	0	; counter of back- to front-buffer page-flips. thus increased by 1 after each fully completed display call
	even
;-------------- Den Screenmode in den Registern auffrischen (aus dem Level3)
_RefreshDisplay:
;in: a6 - $dff000
	bsr	_VBIPlanarSwap

	; debug code !!!
	;tst.l	DisplayCurrent
   cmp.l #0,DisplayCurrent ; 1 is too late the other way
	bpl.s	.normal
	
	; transition / grace period, show last screenmode
	;move  #$f00,$dff180 ; cmp1 und -1 als init scheint zu funzen
   move.b	lastScreenMode(pc),d0	;mode 1-25
	bra.s	.ok
.normal
	move.l	wosbase,a0
	move.l	coplist(a0),$dff080	; !!! debug
	move.b	ScreenMode(pc),d0	;mode 1-25
.ok
	lea	_wosbase(pc),a0
	cmp.b	#25,d0
	beq	.m25
	cmp.b	#24,d0
	beq	.m24
	cmp.b	#23,d0
	beq	.m23
	cmp.b	#22,d0
	beq	.m22
	cmp.b	#21,d0
	beq	.m21
	cmp.b	#20,d0
	beq	.m20
	cmp.b	#19,d0
	beq	.m19
	cmp.b	#18,d0
	beq	.m18
	cmp.b	#17,d0
	beq	.m17
	cmp.b	#16,d0
	beq	.m16
	cmp.b	#15,d0
	beq	.m15
	cmp.b	#14,d0
	beq	.m14
	cmp.b	#13,d0
	beq	.m13
	cmp.b	#12,d0
	beq	.m12
	cmp.b	#11,d0
	beq	.m11
	cmp.b	#10,d0
	beq	.m10
	cmp.b	#9,d0
	beq	.m9
	cmp.b	#8,d0
	beq	.m8
	cmp.b	#7,d0
	beq	.m7
	cmp.b	#6,d0
	beq	.m6
	cmp.b	#5,d0
	beq	.m5
	cmp.b	#4,d0
	beq	.m4
	cmp.b	#3,d0
	beq	.m3
	cmp.b	#2,d0
	beq	.m2
	cmp.b	#1,d0
	beq	.m1

	move	#0,$dff1fc
	move	#0,$dff106
	move	#0,$dff100
	move.w	#0,$dff180	;888
	bra	.norefresh


;-------mode1 - 1x1
.m1
	move.l	PlanarPhysic(pc),d0
	move.l	#mode1size,d1	;Bitplane-size
	bra	.cont

;-------mode2 - 1x2
.m2
	move.l	PlanarPhysic(pc),d0
	move.l	#mode2size,d1	;Bitplane-size
	bra	.cont

;-------mode3 - 2x2
.m3
	move.l	PlanarPhysic(pc),d0
	move.l	#mode3size,d1	;Bitplane-size
	bra	.cont

;-------mode4 - hires
.m4

	move.l	mem1blk,d0
	move.l	#mode4size,d1	;Bitplane-size
	bra	.cont

;-------mode5 - hires INTERLACE
.m5
	move.l	PlanarPhysic(pc),d0

	move.l	mem1blk,d0
	move.l	#mode5size,d1	;Bitplane-size

	btst	#7,$dff004	;long- or short-frame?
	bne	.cont
	add.l	#80,d0		;eine Zeile weiter zeigen
	bra	.cont
	
;-------mode6 - 2x2 18bit
.m6
	ifnd	NOMODE6
	move.l	PlanarPhysic(pc),d0
	move.l	#mode6size,d1	;Bitplane-size

	move.l  #m6mask1,bplpt+$00(a6)	;0
        move.l  #m6mask2,bplpt+$04(a6)	;4

	;00,04..08,0c,10,14,18,1c
	;.......08,10,18,0c,14,1c


;        move.l  d0,bplpt+$08(a6)	;8
;		add.l	d1,d0
;        move.l  d0,bplpt+$10(a6)	;c
;		add.l	d1,d0
;        move.l  d0,bplpt+$18(a6)	;10
;		add.l	d1,d0
;        move.l  d0,bplpt+$0c(a6)	;14
;		add.l	d1,d0
;        move.l  d0,bplpt+$14(a6)	;18
;		add.l	d1,d0
;        move.l  d0,bplpt+$1c(a6)	;1c



        move.l  d0,bplpt+$08(a6)	;8
		add.l	d1,d0
        move.l  d0,bplpt+$0c(a6)	;c
		add.l	d1,d0
        move.l  d0,bplpt+$10(a6)	;10
		add.l	d1,d0

        move.l  d0,bplpt+$14(a6)	;14
		add.l	d1,d0
        move.l  d0,bplpt+$18(a6)	;18
		add.l	d1,d0
        move.l  d0,bplpt+$1c(a6)	;1c

	endc
	bra	.norefresh

;-------mode7 - 1x1 64 cols
.m7
	move.l	PlanarPhysic(pc),d0
	move.l	#mode7size,d1	;Bitplane-size
	bra	.cont

;-------mode8 - 320x180, 8 bit
.m8
	move.l	PlanarPhysic(pc),d0
	move.l	#mode8size,d1	;Bitplane-size
	bra	.cont

;-------mode9 - 320x90, 8 bit
.m9
	move.l	PlanarPhysic(pc),d0
	move.l	#mode9size,d1	;Bitplane-size
	bra	.cont

;-------mode10 - 160x90, 8 bit
.m10
	move.l	PlanarPhysic(pc),d0
	move.l	#mode10size,d1	;Bitplane-size
	bra	.cont
	
;-------mode11 - 160x90, 18 bit
.m11
	ifnd	NOMODE11
	move.l	PlanarPhysic(pc),d0
	move.l	#mode11size,d1	;Bitplane-size

	move.l  #m6mask1,bplpt+$0(a6)			; mode6 recycle, don't use NOMODE6 then!!!
        move.l  #m6mask2,bplpt+$4(a6)

	;00,04..08,0c,10,14,18,1c
	;.......08,10,18,0c,14,1c


;        move.l  d0,bplpt+$08(a6)	;8
		add.l	d1,d0
        move.l  d0,bplpt+$0c(a6)	;c
		add.l	d1,d0
        move.l  d0,bplpt+$10(a6)	;10
		add.l	d1,d0
        move.l  d0,bplpt+$014(a6)	;14
		add.l	d1,d0
        move.l  d0,bplpt+$18(a6)	;18
		add.l	d1,d0
        move.l  d0,bplpt+$1c(a6)	;1c
	endc
	bra	.norefresh
	
;-------mode12 - hires 640x180
.m12
	move.l	mem1blk,d0
	move.l	#mode12size,d1	;Bitplane-size
	bra	.cont
	
;-------mode13 - hires INTERLACE 640x360
.m13
	move.l	PlanarPhysic(pc),d0

	move.l	mem1blk,d0
	move.l	#mode13size,d1	;Bitplane-size

	btst	#7,$dff004	;long- or short-frame?
	bne.w	.cont
	add.l	#80,d0		;eine Zeile weiter zeigen
	bra	.cont

;-------mode14 - 1x1 64 cols
.m14
	move.l	PlanarPhysic(pc),d0
	move.l	#mode14size,d1	;Bitplane-size
   
;   add.l d1,d0
;   add.l d1,d0

        move.l  d0,bplpt+$00(a6)	;8
		add.l	d1,d0
        move.l  d0,bplpt+$04(a6)	;c
		add.l	d1,d0
        move.l  d0,bplpt+$08(a6)	;10
		add.l	d1,d0

        move.l  d0,bplpt+$0c(a6)	;14
		add.l	d1,d0
        move.l  d0,bplpt+$10(a6)	;18
		add.l	d1,d0
        move.l  d0,bplpt+$14(a6)	;1c

;        move.l  d0,bplpt+$08(a6)	;8
;		add.l	d1,d0
;        move.l  d0,bplpt+$0c(a6)	;c
;		add.l	d1,d0
;        move.l  d0,bplpt+$10(a6)	;10
;		add.l	d1,d0

;        move.l  d0,bplpt+$14(a6)	;14
;		add.l	d1,d0
;        move.l  d0,bplpt+$18(a6)	;18
;		add.l	d1,d0
;        move.l  d0,bplpt+$1c(a6)	;1c


	;bra	.cont
   bra   .norefresh

;-------mode15 - 1x1 32 cols (upper 5 Bit)
.m15
	move.l	PlanarPhysic(pc),d0
	move.l	#mode15size,d1	;Bitplane-size
	bra	.cont

;-------mode16 - 1x1 256 cols (+ copper colours)
.m16
	move.l	PlanarPhysic(pc),d0
	move.l	#mode16size,d1	;Bitplane-size
	bra	.cont

;-------mode17 - 220x180 15 bit (640 bits per line)
.m17
	ifnd	NOMODE17
;	lea	$dff000,a6
	move.l	PlanarPhysic(pc),d0
	move.l	#mode17size,d1	;Bitplane-size

	;=== mask in lower planes

	move.l  #m17mask1,bplpt+$00(a6)
        move.l  #m17mask2,bplpt+$04(a6)

	;00,04..08,0c,10,14,18,1c
	;.......08,10,18,0c,14,1c


        move.l  #empty,bplpt+$08(a6)	;8
	;	add.l	d1,d0
        move.l  d0,bplpt+$0c(a6)	;c
		add.l	d1,d0
        move.l  d0,bplpt+$10(a6)	;10
		add.l	d1,d0
        move.l  d0,bplpt+$14(a6)	;14
		add.l	d1,d0
        move.l  d0,bplpt+$18(a6)	;18
		add.l	d1,d0
        move.l  d0,bplpt+$1c(a6)	;1c

	endc
	bra	.norefresh

;-------mode18 - 220x180 15 bit (640 bits per line)
.m18
	ifnd	NOMODE18
;	lea	$dff000,a6
	move.l	PlanarPhysic(pc),d0
	move.l	#mode18size,d1	;Bitplane-size

	;=== mask in lower planes

	move.l  #m17mask1,bplpt+$00(a6)
        move.l  #m17mask2,bplpt+$04(a6)

	;00,04..08,0c,10,14,18,1c
	;.......08,10,18,0c,14,1c


        move.l  #empty,bplpt+$08(a6)	;8
	;	add.l	d1,d0
        move.l  d0,bplpt+$0c(a6)	;c
		add.l	d1,d0
        move.l  d0,bplpt+$10(a6)	;10
		add.l	d1,d0
        move.l  d0,bplpt+$14(a6)	;14
		add.l	d1,d0
        move.l  d0,bplpt+$18(a6)	;18
		add.l	d1,d0
        move.l  d0,bplpt+$1c(a6)	;1c

	endc
	bra	.norefresh

;-------mode19 - 220x90 15 bit (640 bits per line)
.m19
	ifnd	NOMODE19
	move.l	PlanarPhysic(pc),d0
	move.l	#mode19size,d1	;Bitplane-size

	;=== mask in lower planes

	move.l  #m17mask1,bplpt+$00(a6)
        move.l  #m17mask2,bplpt+$04(a6)

	;00,04..08,0c,10,14,18,1c
	;.......08,10,18,0c,14,1c


        move.l  #empty,bplpt+$08(a6)	;8
	;	add.l	d1,d0
        move.l  d0,bplpt+$0c(a6)	;c
		add.l	d1,d0
        move.l  d0,bplpt+$10(a6)	;10
		add.l	d1,d0
        move.l  d0,bplpt+$14(a6)	;14
		add.l	d1,d0
        move.l  d0,bplpt+$18(a6)	;18
		add.l	d1,d0
        move.l  d0,bplpt+$1c(a6)	;1c

	endc
	bra	.norefresh

;-------mode20 - 220x180 18 bit (640 bits per line)
.m20
	ifnd	NOMODE20
;	lea	$dff000,a6
	move.l	PlanarPhysic(pc),d0
	move.l	#mode17size,d1	;Bitplane-size

	;=== mask in lower planes

	move.l  #m17mask1,bplpt+$00(a6)
        move.l  #m17mask2,bplpt+$04(a6)

        move.l  d0,bplpt+$08(a6)	;8
		add.l	d1,d0
        move.l  d0,bplpt+$0c(a6)	;c
		add.l	d1,d0
        move.l  d0,bplpt+$10(a6)	;10
		add.l	d1,d0
        move.l  d0,bplpt+$14(a6)	;14
		add.l	d1,d0
        move.l  d0,bplpt+$18(a6)	;18
		add.l	d1,d0
        move.l  d0,bplpt+$1c(a6)	;1c

	endc
	bra	.norefresh

;-------mode21 - 220x180 18 bit (640 bits per line)
.m21
	ifnd	NOMODE21
;	lea	$dff000,a6
	move.l	PlanarPhysic(pc),d0
	move.l	#mode17size,d1	;Bitplane-size

	;=== mask in lower planes

	move.l  #m17mask1,bplpt+$00(a6)
        move.l  #m17mask2,bplpt+$04(a6)

        move.l  d0,bplpt+$08(a6)	;8
		add.l	d1,d0
        move.l  d0,bplpt+$0c(a6)	;c
		add.l	d1,d0
        move.l  d0,bplpt+$10(a6)	;10
		add.l	d1,d0
        move.l  d0,bplpt+$14(a6)	;14
		add.l	d1,d0
        move.l  d0,bplpt+$18(a6)	;18
		add.l	d1,d0
        move.l  d0,bplpt+$1c(a6)	;1c

	endc
	bra	.norefresh

;-------mode22 - 220x90 18 bit (640 bits per line)
.m22
	ifnd	NOMODE22
	move.l	PlanarPhysic(pc),d0
	move.l	#mode22size,d1	;Bitplane-size

	;=== mask in lower planes

	move.l  #m17mask1,bplpt+$00(a6)
        move.l  #m17mask2,bplpt+$04(a6)

	;00,04..08,0c,10,14,18,1c
	;.......08,10,18,0c,14,1c


        move.l  d0,bplpt+$08(a6)	;8
		add.l	d1,d0
        move.l  d0,bplpt+$0c(a6)	;c
		add.l	d1,d0
        move.l  d0,bplpt+$10(a6)	;10
		add.l	d1,d0
        move.l  d0,bplpt+$14(a6)	;14
		add.l	d1,d0
        move.l  d0,bplpt+$18(a6)	;18
		add.l	d1,d0
        move.l  d0,bplpt+$1c(a6)	;1c

	endc
	bra	.norefresh

;-------mode23 - 220x180 12 bit (640 bits per line)
.m23
	ifnd	NOMODE23
	move.l	PlanarPhysic(pc),d0
	move.l	#mode17size,d1	;Bitplane-size

	;=== mask in lower planes

	move.l  #m17mask1,bplpt+$00(a6)
        move.l  #m17mask2,bplpt+$04(a6)

        move.l  #empty,bplpt+$08(a6)	;8
		;add.l	d1,d0
        move.l  #empty,bplpt+$0c(a6)	;c
		add.l	d1,d0
        move.l  d0,bplpt+$10(a6)	;10
		add.l	d1,d0
        move.l  d0,bplpt+$14(a6)	;14
		add.l	d1,d0
        move.l  d0,bplpt+$18(a6)	;18
		add.l	d1,d0
        move.l  d0,bplpt+$1c(a6)	;1c

	endc
	bra	.norefresh


;-------mode24 - 1x1 32 cols (OCS)
.m24
      move.l	PlanarPhysic(pc),d0
      move.l	#mode24size,d1	;Bitplane-size
      
      move.l  d0,bplpt+$00(a6)	;8
      add.l	d1,d0
      move.l  d0,bplpt+$04(a6)	;c
      add.l	d1,d0
      move.l  d0,bplpt+$08(a6)	;10
      add.l	d1,d0
      
      move.l  d0,bplpt+$0c(a6)	;14
      add.l	d1,d0
      move.l  d0,bplpt+$10(a6)	;18
      add.l	d1,d0
      move.l  d0,bplpt+$14(a6)	;1c

   bra   .norefresh

;-------mode25 - 1x1 32 cols (OCS) + copper 0,25..31
.m25
      move.l	PlanarPhysic(pc),d0
      move.l	#mode25size,d1	;Bitplane-size
      
      move.l  d0,bplpt+$00(a6)	;8
      add.l	d1,d0
      move.l  d0,bplpt+$04(a6)	;c
      add.l	d1,d0
      move.l  d0,bplpt+$08(a6)	;10
      add.l	d1,d0
      
      move.l  d0,bplpt+$0c(a6)	;14
      add.l	d1,d0
      move.l  d0,bplpt+$10(a6)	;18
      add.l	d1,d0
      move.l  d0,bplpt+$14(a6)	;1c

	;bra	.cont
   bra   .norefresh



;-------Bitplane-Pointer in die Register eintragen
.cont:
	move.l  d0,bplpt+$0(a6)
		add.l	d1,d0
        move.l  d0,bplpt+$4(a6)
		add.l	d1,d0
        move.l  d0,bplpt+$8(a6)
		add.l	d1,d0
        move.l  d0,bplpt+$c(a6)
		add.l	d1,d0
        move.l  d0,bplpt+$10(a6)
		add.l	d1,d0
        move.l  d0,bplpt+$14(a6)
		add.l	d1,d0
        move.l  d0,bplpt+$18(a6)
		add.l	d1,d0
        move.l  d0,bplpt+$1c(a6)


.norefresh:

	rts

;-------------- Misc subs
_PlanarSwap:
	lea	SwapMark(pc),a0
	move.w	#$1,(a0)
	rts

_VBIPlanarSwap:
	move.w	SwapMark(pc),d0
	beq.s	.quit

	add.l	#1,DisplayCurrent
	add	#1,PageFlips

	lea	SwapMark(pc),a0
	move.w	#0,(a0)

	;// simple double-buffering code
	move.l PlanarPhysic(pc),a0
	move.l	PlanarLogic1(pc),PlanarPhysic
	move.l	a0,PlanarLogic1

.quit	rts

_NoMode:
	rts	


;----------------------------- Set.s

_SetBuffer:
; in: a0 - ^buffer
	lea	_wosbase(pc),a1
	move.l	modeptrptr(a1),a1
	move.l	a0,(a1)

	rts


;SetMode and SetColors are in this source
_SetMaCM1	macro
	ifnd	NOMODE\1
		cmp	#\1,d0
		beq	.m\1
	endc
	endm
_SetMaCM2	macro
	ifnd	NOMODE\1
.m\1	
		lea	mode\1ptr(a0),a2
		;move.l	d4,mode\1ptr(a0)
		move.l	d4,(a2)
		bra	.m0
	endc
	endm

_SetModeAndColors:
;in: d0 - mode
;    a0 - ^buffer	
;    a1 - ^palette
;    d1 - brightness
	movem.l	d2-d7/a2-a6,-(a7)
	move.l	d0,d2
	move.l	d1,d3
	move.l	a0,d4
	move.l	a1,d5
	
	bsr	_SetMode

	move.l	d2,d0	;mode
	lea	_wosbase(pc),a0
	lea	modeptr(pc),a1

	_SetMaCM1	1
	_SetMaCM1	2
	_SetMaCM1	3
	_SetMaCM1	4
	_SetMaCM1	5
	_SetMaCM1	6
	_SetMaCM1	7
	_SetMaCM1	8
	_SetMaCM1	9
	_SetMaCM1	10
	_SetMaCM1	11
	_SetMaCM1	12
	_SetMaCM1	13
	_SetMaCM1	14
	_SetMaCM1	15
	_SetMaCM1	16
	_SetMaCM1	17
	_SetMaCM1	18
	_SetMaCM1	19
	_SetMaCM1	20
	_SetMaCM1	21
	_SetMaCM1	22
	_SetMaCM1	23
	_SetMaCM1	24
   _SetMaCM1	25
	bra	.m0

	_SetMaCM2	25
	_SetMaCM2	24
	_SetMaCM2	23
	_SetMaCM2	22
	_SetMaCM2	21
	_SetMaCM2	20
	_SetMaCM2	19
	_SetMaCM2	18
	_SetMaCM2	17
	_SetMaCM2	16
	_SetMaCM2	15
	_SetMaCM2	14
	_SetMaCM2	13
	_SetMaCM2	12
	_SetMaCM2	11
	_SetMaCM2	10
	_SetMaCM2	9
	_SetMaCM2	8
	_SetMaCM2	7
	_SetMaCM2	6
	_SetMaCM2	5
	_SetMaCM2	4
	_SetMaCM2	3
	_SetMaCM2	2
	_SetMaCM2	1
	
.m0
	move.l	d4,(a1)		;modeptr (#buffer)
	move.l	a2,modeptrptr(a0)	;!!!fs

	move.l	d5,a0		;colors
	move.l	d3,d0		;brigthness

	ifnd	NOMODE6		; todo:!!! fixme for mode11
	cmp	#6,d2		;18bit mode 6?
		beq.s	.18bit
	cmp	#11,d2		;18bit mode 10?
		beq.s	.18bit
	cmp	#17,d2
		beq.s	.18bit	;well 15, whatever
	cmp	#18,d2
		beq.s	.18bit	;well 15, whatever

	bra.s	.no18bit
	nop
.18bit
	;lea	m6col,a0	;256 white
	;move.l	#255,d0

.no18bit
	endc
	lea	PalOrig(pc),a1
	move.l	a0,(a1)
	bsr	_SetColors

.quit	movem.l	(a7)+,d2-d7/a2-a6	
	rts


;---------------Screenmode setzen
;(etwas protzig, aber vielleicht will ich ja mal auf CGX umsteigen)

;----- capture from c2p-init-routine ---
; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	(bplsize) [bytes] -- offset between one row in one bpl and the next bpl

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	scroffsx [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.l	rowlen [bytes] -- offset between one row and the next in a bpl
; d5.l	bplsize [bytes] -- offset between one row in one bpl and the next bpl
; d6.l	chunkylen [bytes] -- offset between one row and the next in chunkybuf

_SetModeMac	Macro
	ifnd	NOMODE\1
.m\1
		;move.l	#Copm\1,$dff080		;init the coplist
		;moved to vbi
		
		move.l	#Copm\1,coplist(a6)	;for later modifications
		move.l	#sprm\1,sprlist(a6)	;for SetSprites
		bsr	testcopptr	;req. for SETSCREENY + X

		move.l	#mode\1xsize,d0
		move.l	#mode\1ysize,d1
		move.l	#mode\1xoff,d2
		move.l	#mode\1yoff,d3
		move.l	#mode\1rowlen,d4
		move.l	#mode\1size,d5
		move.l	#mode\1xsize*4,d6
		
		move.l	c2p_blitbuf,a0	;needed by c3b1
		lea	c2p_tempbuf,a1	;needed by optimized 6bpl c5
		lea	_PlanarSwap,a2	;needed by c3b1
		move.l	mode\1init(a3),a3
		cmp	#0,a3
		beq	.cont	;on error (not defined)
 		jsr	(a3)	;Init the c2p
		ifnd	NO020C2P
			lea	m\1c2p+12,a0
			lea	c2p_queue,a1
			move.l	a0,(a1)	;Point to the Queue routine for c3b1 (rts for c5)
		else
			lea	c2p_queue,a1
			move.l	#0,(a1)
		endc
	
;		move.l	#\1,RegisteredMode
;		move.b	\1,ScreenMode
		bra	.cont	;we are finished here
	endc
	endm

_CallSetModeMac	Macro
	ifnd	NOMODE\1
		cmp.b	#\1,d0
		beq	.m\1
	endc
	endm

_SetMode:
;in: d0 - screenmode
	movem.l	d2-d5,-(a7)

	lea	ScreenMode(pc),a0	;set screenmode
	move.b	(a0),lastScreenMode	;store for grace priod refreshdisplay
	move.b	d0,(a0)
	lea	_wosbase(pc),a3

	_CallSetModeMac	25
	_CallSetModeMac	24
	_CallSetModeMac	23
	_CallSetModeMac	22
	_CallSetModeMac	21
	_CallSetModeMac	20
	_CallSetModeMac	19
	_CallSetModeMac	18
	_CallSetModeMac	17
	_CallSetModeMac	16
	_CallSetModeMac	15
	_CallSetModeMac	14
	_CallSetModeMac	13
	_CallSetModeMac	12
	_CallSetModeMac	11
	_CallSetModeMac	10
	_CallSetModeMac	9
	_CallSetModeMac	8
	_CallSetModeMac	7
	_CallSetModeMac	6
	_CallSetModeMac	5
	_CallSetModeMac	4
	_CallSetModeMac	3
	_CallSetModeMac	2
	_CallSetModeMac	1

	bra	.cont

.m0	move.l	#Copm0,$dff080		;init the nomode coplist
;	move.l	#0,RegisteredMode
	bra	.cont

	_SetModeMac	1
	_SetModeMac	2
	_SetModeMac	3
	_SetModeMac	4
	_SetModeMac	5
	_SetModeMac	6
	_SetModeMac	7
	_SetModeMac	8
	_SetModeMac	9
	_SetModeMac	10
	_SetModeMac	11
	_SetModeMac	12
	_SetModeMac	13
	_SetModeMac	14
	_SetModeMac	15
	_SetModeMac	16
	_SetModeMac	17
	_SetModeMac	18
	_SetModeMac	19
	_SetModeMac	20
	_SetModeMac	21
	_SetModeMac	22
	_SetModeMac	23
	_SetModeMac	24
 	_SetModeMac	25

	nop
.cont:

	; reset planar-pointers
	lea	PlanarPhysic(pc),a0	
	move.l	Bpl1(pc),(a0)+
	move.l	Bpl2(pc),(a0)+
	;//!!! double-buffer
	;move.l	Bpl3(pc),(a0)+
	
	; reset copper on mode 16
	cmp.b	#16,ScreenMode
	bne.s	.nocopper
	
	move.l	#0,d0
	lea	blackCopper,a0
	jsr	_SetCopper
	move.l	#1,d0
	lea	blackCopper,a0
	jsr	_SetCopper
	move.l	#2,d0
	lea	blackCopper,a0
	jsr	_SetCopper


.nocopper
	; initiate display grace period (no colour changes before c2p has completed the next pass)
	move.l	#-1,DisplayCurrent	;!!! number of c2p frames, -1 is good

	movem.l	(a7)+,d2-d5
	rts

;---
testcopptr:	;searches the coplist for the pos. of diwstrt and diwstop
		;for later manipulation through setscreenx+y
	lea	dummy,a0
	move.l	a0,diwstrtptr
	move.l	a0,diwstopptr	

	move.l	coplist(a6),a0
.lp	move.l	(a0)+,d0
	move.l	a0,a1
	sub.l	#2,a1

	cmp.l	#-2,d0
	beq.s	.quitout	

	and.l	#$ffff0000,d0
	cmp.l	#$008e0000,d0
	bne.s	.skipstrt

	move.l	a1,diwstrtptr

.skipstrt
	cmp.l	#$00900000,d0
	bne.s	.skipstop

	move.l	a1,diwstopptr

.skipstop
	bra	.lp

.quitout
	rts

_SetScreen	;in: d0-rel. x-pos / d1- rel. y-pos
	movem.l	d2-d3,-(a7)
	move.l	diwstrtptr,a0
	move.l	diwstopptr,a1

	;!!!todo: introduce automatic switch based on current screenmode
	; 22.5.2010
	;move.l	#$4671,d2	; original for modes with 200 lines
	;move.l	#$0cd1,d3

	move.l	#$5081,d2	; prototype 1 modes with 180 lines
	move.l	#$02c1,d3

	lsl.l	#8,d1
	add.l	d1,d2
	add.l	d1,d3
	add.l	d0,d2
	add.l	d0,d3
	move	d2,(a0)
	move	d3,(a1)

	movem.l	(a7)+,d2-d3
	rts

_Error:	;in: a0 - ^errorstring
	ifnd	ABSOLUTELYNOERRORS
		cmp.l	#0,a0
;		tst	a0
		beq.s	.nomatter	;no string supplied -> using builtin string
		move.l	a0,errstr	;loke it in the easystruct
		;this replaces the "\" from the ERROR macro with spaces
.loop		move.b	(a0)+,d0
		cmp.b	#$5f,d0		;$5c=\ $5f=_
		bne.s	.nospace
		move.b	#$20,-1(a0)
.nospace	tst	d0
		bne.s	.loop
.nomatter:
	endc
	sub.l	a0,a0	
	bsr	_VBIHook	;get rid of Level3 childs
	bsr	_WaitVBL
	bsr	_WaitVBL

	move.w	#1,ErrorFlag
	bra	errout		;continue the exit procedure

InitialStack	dc.l	0	;stores a7 just before _Main gets called
ErrorFlag	dc.w	0	;nonzero if an error occurs. checked at exit

;---------------Daten
;copptr:	dc.l	0
diwstrtptr	dc.l	0	;008e
diwstopptr	dc.l	0	;0090
dummy:		dc.l	0	;to be trashed

;RegisteredMode:	dc.l	0	;wird von SetMode registriert und von Display geprüft
modeptr:	dc.l	0
ScreenMode:	dc.b	75
lastScreenMode:	dc.b	0
	even
PalLog:	ds.b	1024
PalPhy:	ds.b	1024
PalOrig:	dc.l	0
;---------------Farb Routinen
_SetColM1	Macro
	ifnd	NOMODE\1
		cmp.b	#\1,d0
		beq	.m\1
	endc
	endm
_SetColM2	Macro
	ifnd	NOMODE\1
.m\1
		lea	colm\1,a1
		bra	.cont
	endc
	endm

_SetColors:
;in: a0 - palette in pure format
;    d0 - start brightness (0-65535)
	
	tst	PageFlips		; pass through on init (before any c2p display has happened)
	beq.s	.ok
	
	tst.l	DisplayCurrent	; only allow colour changes when c2p display after latest screenmode change has reached the front buffer
	bpl.s	.ok
	rts
.ok
	movem.l	d0-a6,-(a7)
	lea	PalLog(pc),a1

	move.l	#255,d7
.loop	move.l	(a0)+,(a1)+
	dbf	d7,.loop	

	move.l	d0,d1	;helligkeit
	move.l	#256,d0	;#farben
	lea	PalLog(pc),a0
	
	lea	PalPhy(pc),a1
	bsr	AGA_Brightness

	move.b	ScreenMode(pc),d0
   _SetColM1	25
	_SetColM1	24
	_SetColM1	23
	_SetColM1	22
	_SetColM1	21
	_SetColM1	20
	_SetColM1	19
	_SetColM1	18
	_SetColM1	17
	_SetColM1	16
	_SetColM1	15
	_SetColM1	14
	_SetColM1	13
	_SetColM1	12
	_SetColM1	11
	_SetColM1	10
	_SetColM1	9
	_SetColM1	8
	_SetColM1	7
	_SetColM1	6
	_SetColM1	5
	_SetColM1	4
	_SetColM1	3
	_SetColM1	2
	_SetColM1	1
	rts			;requested mode is not supported/included

	_SetColM2	25
   _SetColM2	24
	_SetColM2	23
	_SetColM2	22
	_SetColM2	21
	_SetColM2	20
	_SetColM2	19
	_SetColM2	18
	_SetColM2	17
	_SetColM2	16
	_SetColM2	15
	_SetColM2	14
	_SetColM2	13
	_SetColM2	12
	_SetColM2	11
	_SetColM2	10
	_SetColM2	9
	_SetColM2	8
	_SetColM2	7
	_SetColM2	6
	_SetColM2	5
	_SetColM2	4
	_SetColM2	3
	_SetColM2	2
	_SetColM2	1

	nop
.cont
	;-- check if OCS or AGA update
	cmp.b	#24,d0	; 24 is the first OCS mode
	blt	.agaupdate

.ocsupdate:
	lea	OCSConv(pc),a0
	move.b	#1,(a0)
	lea	OCSPtr(pc),a0
	move.l	a1,(a0)
	movem.l	(a7)+,d0-a6
	rts


.agaupdate:

	lea	AGAConv(pc),a0
	move.b	#1,(a0)
	lea	AGAPtr(pc),a0
	move.l	a1,(a0)
	movem.l	(a7)+,d0-a6
	rts

AGAPtr:		dc.l	0
AGAConv:	dc.b	0
	even
OCSPtr:		dc.l	0
OCSConv:	dc.b	0

	even
;----------------------------- Checkframes.s



;---------------Einfache Warteroutine
Timer:	dc.l	0
TimerSwitch:	dc.b	1
Esc:	dc.b	0
FrameTimer:	dc.l	0

_Init:
	move.l	#-1,Timer	; Timer starts now :)
	lea	FrameTimer(pc),a0
	move.l	Timer(pc),(a0)
	rts

_Exit:
;	bsr	ClearPlanes	;remove the display errors while switching

.wait	btst	#6,$dff002	;Blitter
	bne.s   .wait

	ifnd	NOMMS
		bsr	_EraseAll
		move.l	#0,_mmstabptr(a6)
	endc			;free the effects memory banks

	rts

_CheckFrame:				;check if it is still the same frame
	move.l	FrameTimer(pc),d0
	move.l	Timer(pc),d1
	sub.l	d0,d1
	bpl.s	.frameok
	bra.s	_CheckFrame
.frameok
	lea	FrameTimer(pc),a0
	add.l	#1,(a0)
	rts	

_Check2Frames:
	move.l	FrameTimer(pc),d0
	move.l	Timer(pc),d1
	sub.l	d0,d1
	bpl.s	.frameok
	bra.s	_Check2Frames
.frameok
	lea	FrameTimer(pc),a0
	add.l	#2,(a0)
	rts	

_wait:  move.l  Timer(pc),d1                ; ne tolle Warteroutine...
;	CHECKEXIT
	beq.s	.waiton
;	add.l	#4,a7
;	bra.w	ende
	nop
.waiton:
        cmp.l   d0,d1                   ; Zeit in 1/50s bitte in D0
        blo.s   _wait
        rts

_check:	move.l	Timer(pc),d1
	sub.l	d0,d1
	bmi	.notyet			;die Zeit ist noch nicht Reif
	moveq	#0,d0
	rts
.notyet	moveq	#1,d0
	rts	

;.waiton:
;        cmp.l   d0,d1                   ; Zeit in 1/50s bitte in D0
;        blo.s   _wait
;        rts


_ClearPlanes:
	WINUAEBREAKPOINT
	move.l	mem1blk(pc),a0
	move.l	mem1siz(pc),d0
	lsr.l	#5,d0
	bra	clear32

;
; clear32
;
; loescht speicher
;
; in :  a0      = *memory
;       d0.w    = bytes/32
; out : --
;
        cnop 0,4
clear32:        moveq #0,d1             

;
; fill32
;
; füllt speicher
;
; in :  a0      = *memory
;       d0.w    = bytes/32
;       d1.l    = füllwert
; out : --
;
fill32: subq.w #1,d0
        bls.s .end
.l0	move.l d1,(a0)+
        move.l d1,(a0)+
        move.l d1,(a0)+
        move.l d1,(a0)+
        move.l d1,(a0)+
        move.l d1,(a0)+
        move.l d1,(a0)+
        move.l d1,(a0)+
        dbra d0,.l0
.end    rts


;-------------- color conversion

;Pure Format               RR  GGBB
;               dc.w    $0041,$81FE ...
;                          12  1212
;Copper Format                              RGB (1) 
;               dc.w    $0106,$0C00,$0180,$048F ...
;                                           RGB (2)
;               dc.w    $0106,$0E00,$0180,$011E ...

;a0.l - Farbtabelle im Pure Format
;a1.l - Platz in der Copperlist
;d0.l - Anzahl der Farben

;Der benötigte Platz in der CopList in Bytes ist:
;Anzahl der Farben * 8 + 8   (nicht, sondern: 256*16!!!)

AGAPALCONDIST = 32*4+4

AGA_PalCon:

        movem.l d2-d7/a2-a3,-(a7)

        ;Berechnen wo der 2te Teil der Farbwerte geschrieben werden soll
        ;Ergebnis in a2
;       lsl.l   #2,d0   ;*4 (4 Bytes pro Farbe und Durchgang)
;       add.l   #4,d0   ;+4 (für $0106,$0c00)
        move.l  a1,a2
        add.l   #AGAPALCONDIST,a2
;       add.l   d0,a2   ;Coplist+Offset

        ;Schleife vorbereiten
        move.l  d0,d7
        subq    #1,d7           ;Schleifenzähler (Anzahl der Farben)

        move.l  #$0180,d4       ;Adresse des 1. Farbregisters
        move.l  #$0c00,d1       ;hierraus wird BPLCON3 zusammengesetzt  
        move.l  #32,a3          ;Farb-Bank-Zähler
        move.l  #$01060c00,(a1)+
        move.l  #$01060e00,(a2)+

        ;DIE SCHLEIFE...
.loop   move.l  (a0)+,d2

;	tst.w   a3
	cmp	#0,a3
        bne.s   .ok1
        
        move.l  #31,a3
        ;BPLCON3 schon mal setzen
        add.l   #$2000,d1
        move.l  #$0180,d4
        move.w  d1,d0
        or.l    #$01060000,d0
        add.l   #AGAPALCONDIST,a1
        add.l   #AGAPALCONDIST,a2
        move.l  d0,(a1)+        ;für den 1. Teil
        bset    #9,d0
        move.l  d0,(a2)+        ;für den 2. Teil
        bra.w   .ok2
        
.ok1    sub.w   #1,a3   ;Farb-Bank-Zähler um Eins erniedrigen
.ok2
        ;Blau
        move.l  d2,d3   ;B2 (siehe oben bei den Farbtabellen)
        and.l   #$f,d3  ;überflüssiges ausmaskieren      
        move.b  d3,d5   ;d5 ist für alle (2) Werte
        ror.l   #4,d5

        ror.l   #4,d2   ;B1
        move.l  d2,d3
        and.l   #$f,d3
        move.b  d3,d6   ;d6 ist für alle (1) Werte
        ror.l   #4,d6
                
        ;Grün
        ror.l   #4,d2   ;G2     
        move.l  d2,d3
        and.l   #$f,d3
        move.b  d3,d5
        ror.l   #4,d5

        ror.l   #4,d2   ;G1
        move.l  d2,d3
        and.l   #$f,d3
        move.b  d3,d6
        ror.l   #4,d6

        ;Rot
        ror.l   #4,d2   ;R2     
        move.l  d2,d3
        and.l   #$f,d3
        move.b  d3,d5
        ror.l   #4,d5

        ror.l   #4,d2   ;R1
        move.l  d2,d3
        and.l   #$f,d3
        move.b  d3,d6
        ror.l   #4,d6

        ;Jetzt noch den korrekten Register eintragen
        ror.l   #4,d5
        ror.l   #4,d6
        move.w  d4,d5
;       or.l    d4,d5
        swap    d5
        move.w  d4,d6
;       or.l    d4,d6
        swap    d6

        ;Werte in die CopList schreiben
        move.l  d6,(a1)+
        move.l  d5,(a2)+
        add.l   #2,d4   ;Register-Offset korrigieren

        dbf     d7,.loop

        movem.l (a7)+,d2-d7/a2-a3
        rts


	;-- OCS
;Pure Format               RR  GGBB
;               dc.w    $0041,$81FE ...
;                          12  1212
;Copper Format                              RGB (1) - just the upper nibble
;               dc.w    $0180,$048F ...

;a0.l - Farbtabelle im Pure Format
;a1.l - Platz in der Copperlist
;d0.l - Anzahl der Farben

;Der benötigte Platz in der CopList in Bytes ist:
;Anzahl der Farben * 4


OCS_PalCon:
	WINUAEBREAKPOINT

        movem.l d2-d7/a2-a3,-(a7)

        ;Schleife vorbereiten
        move.l  d0,d7
        subq    #1,d7           ;Schleifenzähler (Anzahl der Farben)

        move.l  #$0180,d4       ;Adresse des 1. Farbregisters

.loop   move.l  (a0)+,d2	; get 8:8:8 colour

        ;Blau
        ror.l   #4,d2   ;B1
        move.l  d2,d3
        and.l   #$f,d3
        move.b  d3,d6   ;d6 ist für alle (1) Werte
        ror.l   #4,d6
                
        ;Grün
        ror.l   #8,d2   ;G1
        move.l  d2,d3
        and.l   #$f,d3
        move.b  d3,d6
        ror.l   #4,d6

        ;Rot
        ror.l   #8,d2   ;R1
        move.l  d2,d3
        and.l   #$f,d3
        move.b  d3,d6
        ror.l   #4,d6

        ;Jetzt noch den korrekten Register eintragen
        ror.l   #4,d6
        move.w  d4,d6
        swap    d6	; -->e.g. $180,$48f

	WINUAEBREAKPOINT

	
        ;Werte in die CopList schreiben
        move.l  d6,(a1)+
        add.l   #2,d4   ;Register-Offset korrigieren

        dbf     d7,.loop

        movem.l (a7)+,d2-d7/a2-a3
        rts
       

;-------------- include WOS sub-routines

;a0.l - source color palette in pure format (4 bytes per color...use ArtPro)
;a1.l - space for destination palette

;d0.l - number of colors
;d1.l - brightness (0 to 65535)


MakeBrightFull	Macro	;\1 Name für den Label angeben
	moveq	#0,d4	;Arbeitsregister löschen
	move.b	d2,d4	;Farbwert holen
	mulu.w	d1,d4	;Farbwert mit Helligkeit multiplizieren
	lsr.w	#8,d4	;und durch die max. Helligkeit teilen
	cmp.l	#255,d4
;	bls.s	.mb\@
	bls.s	*+6
	move.w	#255,d4
;.mb\@
	move.b	d4,d3	;neuen Farbwert im Zielregister speichern
	EndM

AGA_Brightness:

	movem.l	d2-d4,-(a7)
		
	subq.l	#1,d0	;Anzahl der Farben als Schleifenzähler 

.loop	;.RGB holen
	move.l	(a0)+,d2

	MakeBrightFull	;Blau
	ror.l	#8,d2	;zum nächsten Byte
	ror.l	#8,d3
	
	MakeBrightFull	;Grün
	ror.l	#8,d2	;zum nächsten Byte
	ror.l	#8,d3

	MakeBrightFull	;Rot

	swap	d3	;richtige Reihenfolge wieder herstellen
	move.l	d3,(a1)+	;neuen Farbwert speichern

	dbf	d0,.loop		

	movem.l	(a7)+,d2-d4
	rts
	


;--- CrM2 decrunching routine
	ifnd	NODECRUNCH
_Decrunch:

;In:  a0 - Source
;     a1 - Destination
;Out: d0 - 0: Error
	        movem.l d1-a6,-(sp)
	
	        bsr     UnpackLZH
	        move.l  a1,d0

	        movem.l (sp)+,d1-a6
	        rts


UnpackLZH:
		WOSINCBIN	sub/misc/unpacklzh.bin
		;WOSINCLUDE	sub/misc/unpacklzh.s

	else
_Decrunch:
		moveq	#0,d0	;error
		rts
	endc
			
;--- Player 6.104
	ifne	WOS_P61
		even
		ifne	use+1
P61Bin:
			WOSINCLUDE	sub/replay/610.4.asm
			even
		else
			ifd	P61BINARY
P61Bin:				P61BINARY
			else
P61Bin:				WOSINCBIN	sub/replay/p610.4.bin
			endc
		endc
	endc

;--- the Memory Management System MMS

	ifnd	NOMMS
	ifnd	bnknum
bnknum	set	32			; 32 banks for each client
	endc
sysbnknum	set	256		; at least 256 banks for the system
	ifd	WOSASSIGN
		include	wos:sub/wos_mms.s
	else
		include	sub/wos_mms.s
	endc
sysmmstable	dc.l	sysbnknum
		ds.l	sysbnknum*2	;(pointer and size)

	endc
;--- the loading system (needs MMS)
	ifnd	NOLOADING
		WOSINCLUDE	sub/wos_load.s
	else
_Load:	SERROR	"You disabled the loading routines!"
	rts
	endc


;--- Tracker Packer 3.1
	ifne	WOS_TP3
	even
TP3Bin:	WOSINCBIN	sub/replay/tp3.bin
FixCIABug:
	;---Musik mit Volume 0 um den CIA bug zu umgehen
	lea     tp_antibugmod,a0
	move.l	vbroffset(pc),a1
			
	move.w  #0,tp_volume+TP3Bin
	bsr.w   tp_init+TP3Bin
	;	beq	.error
	move.l  #0,Timer
	rts
	endc

;--- THX 1.27
	ifne	WOS_THX
	even
othxReplayer:
	WOSINCBIN	sub/replay/oldthx-replayer.bin
	even
othxVertb:
	bsr	othxReplayer+othxInterrupt
	rts
	endc

;--- AHX 2.3d
	ifne	WOS_AHX
	even
thxReplayer:
	WOSINCBIN	sub/replay/thx-replayer000.bin
	even
thxVertb:
	bsr	thxReplayer+thxInterrupt
	rts
	endc

;--- DK3D engine
	ifd	DK3D
	WOSINCLUDE	sub/dk3d/Wos_DK3D_v1.32.i
	even
dk3dbin:
	WOSINCLUDE	sub/dk3d/wos_dk3d_v1.32+.s
	endc


;--- Speedychip 1.0.6 by Harry "Piru" Sintonen
	ifnd	NOSPEEDYCHIP
SpeedyChipBin:	WOSINCBIN	sub/misc/speedychip.bin
	endc
	

;--- Profiler by Bartman/Abyss
	ifd	PROFILER
		ifd	WOSASSIGN
			include	wos:sub/misc/_pr_profiler.
		else
			include	sub/misc/_pr_profiler.x
		endc
	endc

;--- the Relocator

	ifnd	NORELOC

hunk_unit       =       $3e7
hunk_name       =       $3e8
hunk_code       =       $3e9
hunk_data       =       $3ea
hunk_bss        =       $3eb
hunk_reloc32    =       $3ec
hunk_reloc16    =       $3ed
hunk_reloc8     =       $3ee
hunk_ext        =       $3ef
hunk_symbol     =       $3f0
hunk_debug      =       $3f1
hunk_end        =       $3f2
hunk_header     =       $3f3
hunk_lsdheader  =       "WOS!"
hunk_overlay    =       $3f5
hunk_break      =       $3f6

;               lea     file(pc),a0             ; File to Relocate
;               bsr     _LVOHunkLength          ; get size requirements...
;                                               ; d0=org`ed size
;               lea     file(pc),a0
;               lea     buffer,a1
;               bsr.b   _LVOHunkRelocate        ; relocate file...
;               bne.s   RelocFailed             ; did relocation fail?
;
;               jsr     (a0)                    ; run relocated program.

RelocFailed:    rts


_LVOHunkLength: suba.l  a1,a1                   ; Get length of relocated...
_LVOHunkRelocate:
                move.l  a1,-(sp)                ;preserve dest adr
                move.l  a1,a4                   ; erase a1
                move.l  a1,a3                   ; erase a3
                move.l  (a0)+,d0                ; read longword from file
                cmp.l   #hunk_header,d0         ; must start with a hunk_header
                beq.s   hunkname                ; if not we`ve got problems!
                cmp.l   #hunk_lsdheader,d0      ; must start with a hunk_header
                bne.w   relocerror              ; if not we`ve got problems!
hunkname        move.l  (a0)+,d0                ; if its named, skip name
                beq.s   hunkok                  ; if 0 its alright!
                add.l   d0,d0                   ; x2
                add.l   d0,d0                   ; x4 (convert BCPL pointer)
                add.l   d0,a0                   ; add to ptr
                bra.s   hunkname                ; deal with hunk name...
 
hunkok          move.l  (a0)+,d7                ; read no. hunks from file
                move.l  d7,d6                   ; d6=copy of no.hunks...
                add.l   d7,d7
                add.l   d7,d7
                add.l   d7,d7                   ; 2 long words per hunk
                sub.l   d7,sp
                addq.w  #8,a0                   ; skip first/last hunk nos
                move.l  sp,a1
                move.l  sp,a5
hunksetuplp     move.l  (a0)+,d0                ; get hunk length
                add.l   d0,d0
                add.l   d0,d0                   ; x4 Get address from BCPL ptr
                move.l  d0,(a1)+                ; length
                addq.l  #8,a3                   ; add segment header
                move.l  a3,(a1)+                ; ptr
                add.l   d0,a3
                subq.l  #1,d6
                bne.s   hunksetuplp

                cmpa.l  #0,a4                   ; are we going to reloc or get length ?
                bne.s   hunkdoit                ; getlength - hunklen in header (.l)
                move.l  d7,d0                   ; zero count+8 bytes per hunk
hunksumlp       add.l   (sp)+,d0                ; add lengths etc.
                addq.l  #4,sp                   ; recover stack at same time!
                subq.l  #8,d7
                bne.s   hunksumlp
                bra.w   relocok

hunkdoit        move.l  d7,d6
hunkproclp      move.l  (a0)+,d0                ; read hunk type
                bsr.s   idproc_hunk
                bne.s   hunkproclp
                bra.w   relocdone

idproc_hunk     cmp.w   #hunk_unit,d0
                beq.w   hunkskip
                cmp.w   #hunk_name,d0
                beq.w   hunkskip
                cmp.w   #hunk_code,d0
                beq.b   hunkcode
                cmp.w   #hunk_data,d0
                beq.b   hunkcode
                cmp.w   #hunk_bss,d0
                beq.b   hunkbss
                cmp.w   #hunk_reloc32,d0
                beq.b   hunkreloc
                cmp.w   #hunk_symbol,d0 ; implemented 6/2/92
                beq.b   hunksymb
                cmp.w   #hunk_debug,d0  ; 6/2/92
                beq.b   hunkskip
                cmp.w   #hunk_end,d0    ; eof
                beq.w   hunkend 
                bra.b	hunkfin         ; id has failed! must be ext/16/8/reloc16
                                        ; or something not in exe files!
hunkcode        move.l  (a0)+,d0                ; get length
                move.l  (a5),d1                 ; get length ii
                move.l  4(a5),a6
hunkcodelp      move.l  (a0)+,(a6)+             ; copy though
                subq.l  #4,d1
                subq.l  #1,d0
                bne.s   hunkcodelp
                tst.l   d1                      ; if length mismatch, wipe rest
                beq.s   hunkcodeok
hunkcodelp2     clr.l   (a6)+
                subq.l  #4,d1
                bne.s   hunkcodelp2
hunkcodeok      moveq.l #1,d0
                rts     
 
hunkreloc       move.l  (a0)+,d0                ; get no of relocs
                beq.s   hunkrelocfin
                move.l  (a0)+,d1                ; get hunk
                add.l   d1,d1
                add.l   d1,d1
                add.l   d1,d1                   ; x8
                move.l  8(sp,d1.l),d3           ; get hunk base
                move.l  4(a5),a6
hunreloclp      move.l  (a0)+,d2                ; get offset
                add.l   d3,0(a6,d2.l)
                subq.l  #1,d0
                bne.s   hunreloclp
                bra.s   hunkreloc
hunkrelocfin    moveq.l #1,d0
                rts     

hunkbss         move.l  (a0)+,d0                ; get length
                move.l  4(a5),a6                ; get start

                move.l  d1,-(sp)                ; save d1 to stack
                moveq   #0,d1                   ; erase d1
hunkbsslp       move.l  d1,(a6)+                ; wipe d0 longwords using d1
                subq.l  #1,d0                   ; decrease counter
                bne.s   hunkbsslp               ; is it zero?

                moveq.l #1,d0                   ; set d0 as 1
                move.l  (sp)+,d1                ; restore d1 from stack
                rts     
 
hunkskip        move.l  (a0)+,d0                ; get length, add to file ptr
                add.l   d0,d0
                add.l   d0,d0                   ; get Address from BCPL ptr
                add.l   d0,a0
                moveq.l #1,d0
                rts     

hunksymb        move.l  (a0)+,d0                ; flush symbol name
                add.l   d0,d0
                add.l   d0,d0                   ; get Address from BCPL ptr
                lea     (a0,d0.l),a0
                tst.l   d0
                beq.s   donesym
                addq.l  #4,a0                   ; flush symbol value
                bra.s   hunksymb
donesym         moveq   #1,d0
                rts             

hunkfin         moveq.l #0,d0
                rts     
hunkend         addq.w  #8,a5
                subq.l  #8,d6
                rts     
relocdone
fixsegs         move.l  (sp)+,d0        ; length
                move.l  (sp)+,a0        ; ptr
                addq.l  #8,d0           ; length incldues header info
                move.l  d0,-8(a0)       ; punch out segment length
                move.l  4(sp),d1        ; next ptr      
                subq.l  #4,d1           ; ptrs point to each other not actual code/data
                lsr.l   #2,d1           ; make bcpl
                move.l  d1,-4(a0)       ; put in next ptr
                subq.l  #8,d7           ; d7=8*numsegs
                bne.s   fixsegs

                clr.l   -4(a0)          ; kill last 'next ptr',crap from stack
                moveq   #0,d0           ; erase d0
                bra.s   relocok 
 
relocerror      moveq   #-1,d0
relocok         move.l  (sp)+,a0        ;get dest, put in a0
                addq.l  #8,a0           ;a0=jmp address
                tst.l   d0              ; did it fail?
                rts     

;file           incbin  'df0:1'
;buffer          dcb.b   338722,0
;	section Relocate,bss
;RelocP:	ds.b	RELOCPSIZE

	;	;features a 2mb (default-size) bss-hunk
	endc

;-------------- Hardware Abstraction Layer
	ifd	KILLER
		ifd	WOSASSIGN
			include	wos:sub/wos_hal_killer.s
		else
			include	sub/wos_hal_killer.s
		endc
	else

		ifd	WOSASSIGN
			include	wos:sub/wos_hal_system.s
		else
			include	sub/wos_hal_system.s
		endc
	endc


;-------------- incbin the c2p Plug-Ins
Modes:
MODES	set	0	;for internal use (conditional assembling)
	ifnd	NOMODE1
MODES		set	MODES!1
	endc
	ifnd	NOMODE2
MODES		set	MODES!1<<1
	endc
	ifnd	NOMODE3
MODES		set	MODES!1<<2
	endc
	ifnd	NOMODE4
MODES		set	MODES!1<<3
	endc
	ifnd	NOMODE5
MODES		set	MODES!1<<4
	endc
	ifnd	NOMODE6
MODES		set	MODES!1<<5
	endc
	ifnd	NOMODE7
MODES		set	MODES!1<<6
	endc
	ifnd	NOMODE8
MODES		set	MODES!1<<7
	endc
	ifnd	NOMODE9
MODES		set	MODES!1<<8
	endc
	ifnd	NOMODE10
MODES		set	MODES!1<<9
	endc
	ifnd	NOMODE11
MODES		set	MODES!1<<10
	endc
	ifnd	NOMODE12
MODES		set	MODES!1<<11
	endc
	ifnd	NOMODE13
MODES		set	MODES!1<<12
	endc
	ifnd	NOMODE14
MODES		set	MODES!1<<13
	endc
	ifnd	NOMODE15
MODES		set	MODES!1<<14
	endc
	ifnd	NOMODE16
MODES		set	MODES!1<<15
	endc
	ifnd	NOMODE17
MODES		set	MODES!1<<16
	endc
	ifnd	NOMODE18
MODES		set	MODES!1<<17
	endc
	ifnd	NOMODE19
MODES		set	MODES!1<<18
	endc
	ifnd	NOMODE20
MODES		set	MODES!1<<19
	endc
	ifnd	NOMODE21
MODES		set	MODES!1<<20
	endc
	ifnd	NOMODE22
MODES		set	MODES!1<<21
	endc
	ifnd	NOMODE23
MODES		set	MODES!1<<22
	endc
	ifnd	NOMODE24
MODES		set	MODES!1<<23
	endc
   ifnd	NOMODE25
MODES		set	MODES!1<<24
	endc
	
MODE1OR2	set	MODES&3		;mode1 or mode2 requested...
	ifnd	NOMODE1
m1c2p:
		WOSINCBIN	sub/chunky/1x1x8_c5.bin
	endc

	ifnd	NOMODE2
m2c2p:
		WOSINCBIN	sub/chunky/1x2x8_c5.bin
	endc


	ifnd	NOMODE3
m3c2p:		WOSINCBIN	sub/chunky/2x1x8_c5.bin
	endc

	ifnd	NOMODE4
m4c2p:		WOSINCBIN	sub/chunky/mode4.bin
	endc

	ifnd	NOMODE5
m5c2p:		WOSINCBIN	sub/chunky/mode5.bin
	endc

	ifnd	NOMODE6
m6c2p:
		WOSINCBIN	sub/chunky/mode6-2016.bin
m6col:		dc.l	0
		dcb.l	255,$ffffff
	endc

	ifnd	NOMODE7
m7c2p:		WOSINCBIN	sub/chunky/1x1x6_c5.bin
	endc
	
	ifnd	NOMODE8
m8c2p:
		WOSINCBIN	sub/chunky/mode8_1x1_8_c5_040.bin
	endc
	
	ifnd	NOMODE9
m9c2p:		WOSINCBIN	sub/chunky/mode9_1x2x8_c5.bin
	endc

	ifnd	NOMODE10
m10c2p:		WOSINCBIN	sub/chunky/mode10_2x1x8_c5.bin
	endc
	
	ifnd	NOMODE11
m11c2p:
		WOSINCBIN	sub/chunky/mode11_18bit-2016.bin
m11col:		dc.l	0
		dcb.l	255,$ffffff
	endc

	ifnd	NOMODE12
m12c2p:		WOSINCBIN	sub/chunky/mode12_hires.bin
	endc
	
	ifnd	NOMODE13
m13c2p:	
	WOSINCBIN	sub/chunky/mode13_hiresinterlace.bin
	endc

	ifnd	NOMODE14
m14c2p:		WOSINCBIN	sub/chunky/mode14_1x1x6_c5.bin
	endc

	ifnd	NOMODE15
m15c2p:		WOSINCBIN	sub/chunky/mode15_1x1x5_c5.bin
	endc
	
	ifnd	NOMODE16
m16c2p:		WOSINCBIN	sub/chunky/mode16_1x1x8_c5.bin
	endc
	ifnd	NOMODE17
m17c2p:		WOSINCBIN	sub/chunky/mode17_c2p_15bit.bin
	endc

	ifnd	NOMODE18
m18c2p:	
		WOSINCBIN	sub/chunky/mode18_c2p_15bit.bin
	endc

	ifnd	NOMODE19
m19c2p:	
		WOSINCBIN	sub/chunky/mode19_c2p_15bit.bin
	endc

	ifnd	NOMODE20
m20c2p:	
		WOSINCBIN	sub/chunky/mode20_c2p_18bit.bin
	endc

	ifnd	NOMODE21
m21c2p:	
		WOSINCBIN	sub/chunky/mode21_c2p_18bit.bin
	endc

	ifnd	NOMODE22
m22c2p:	
		WOSINCBIN	sub/chunky/mode22_c2p_18bit.bin
	endc
	ifnd	NOMODE23
m23c2p:	
		WOSINCBIN	sub/chunky/mode23_c2p_12bit.bin
	endc
	ifnd	NOMODE24
m24c2p:		WOSINCBIN	sub/chunky/mode24_1x1x5.bin
	endc
  	ifnd	NOMODE25
m25c2p:		WOSINCBIN	sub/chunky/mode25_1x1x5.bin
	endc

;-------------- Defaults and copperlists
        section WOS-Defaults,data_c
Init_coplist:  dc.w    $01fc,0,$106,0                  ;die Init-Copperliste
        dc.w    $0180,0		;$133!!!
        dc.l    -2

	ifd	WOSASSIGN
		include	wos:sub/wos_copperlists_v1.6.s
	else
	        include sub/wos_copperlists_v1.6.s
	endc

	ifne	WOS_TP3
tp_antibugmod:	WOSINCBIN	dat/antibugmod.tp3	;fixes a cia-tempo problem
	endc

;-------------- Incbin the required module
	ifd	MUSIC
		ifeq	MUSIC-P61
p61_module:
			ifd     P61MOD
				P61MOD
			else
				WOSINCBIN	dat/haupex.p61
			endc
		even
	endc

	ifeq	MUSIC-TP3
tp_module:
		ifd     TP3MOD
			TP3MOD
		else
			WOSINCBIN	dat/Virgill-Noxious.tp3
		endc
		even
	endc

	ifeq	MUSIC-THX
thx_module:
		ifd     THXMOD
			THXMOD
		else
			WOSINCBIN	dat/pink-hawkeyeloader.thx
;			WOSINCBIN	dat/geirtjelta-iloveholydaze.thx
		endc
		even
	endc

	ifeq	MUSIC-AHX
ahx_module:
		ifd     AHXMOD
			AHXMOD
		else
			WOSINCBIN	dat/jazzcat-electriccity.ahx
;			WOSINCBIN	dat/pink-agonyend.ahx
		endc
		even
	endc

	endc

	ifd	WTEST
leif:	dc.l	0	; !!!nur zum testen
	endc

;-------------- BSS Areas for c2p and bitplanes
	section ChunkyBSS,bss
c2p_tempbuf	ds.b	mode1xsize*mode1ysize/4


   ifd   FRAMESYNC
	section	stackspace,bss
	ds.l	100000
stack_c2p:	
	ds.l	100000
;	dc.l	$deadc0de
;	dc.l	$deadc0de
;	dc.l	$deadc0de
;	dc.l	$deadc0de
;	dc.l	$deadc0de
;	dc.l	$deadc0de
;	dc.l	$deadc0de
;	dc.l	$deadc0de
;	dc.l	$deadc0de
;	dc.l	$deadc0de
;	dc.l	$deadc0de
;	dc.l	$deadc0de
	endc


	ifnd	NOMODE6
	section	maskplanes,bss_c
m6mask1	ds.b	(mode6xsize/8*mode6ysize)
m6mask2	ds.b	(mode6xsize/8*mode6ysize)
	endc
	ifnd	NOMODE17	;!!! or NOMODE18
m17mask1:	ds.b	mode17size	;(mode17linexsize/8*mode17ysize)
m17mask2:	ds.b	mode17size	;(mode17linexsize/8*mode17ysize)
empty:	ds.b	mode17size
	endc

;-------------- END of WOS

deb1:	ds.l	1
deb2:	ds.l	1

	ifd	P61BUFFERSIZE
	section	P61SampleBuffer,bss_c
P61SampleBuffer:	ds.b	P61BUFFERSIZE
	endc


	ifd	SAVEFRAMES
	section	BMPBUFFER,bss
bmp	ALLOCBMP	mode5size*8+128000	;128000 for safety
	endc
	
        section Effect,code
