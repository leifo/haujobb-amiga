;$VER: Haujobb.s (17.03.98 & 22.02.10) by Leif Oppermann
;
; an easy example for WOS

; graphics and music are included from the WickedOS distribution which can be found at assign wos: on the Amiga

;NO020C2P	; use only 040/060 routines
;MUSIC = 2
;DEBUG		; do stop at program end and allow searching for Enforcer hits

ADPCM		; uncheck to play ADPCM, check to play WAV
STEREOADPCM	; use the 28600 khz stereo adpcm instead of the 22khz mono version

KILLER

;DEBUG

;FRAMESYNC

	ifnd STEREOADPCM
;ReplayPeriod = 124		; 124 means 28603.99 HZ
ReplayPeriod = 161		; 161 means 22030.40 Hz
	else
ReplayPeriod = 124		; 124 means 28603.99 HZ
	endc

	ifnd	TEST

	; main interface
	xdef	_wosInit	; won't return, will call mainDemo though
	xref	_mainDemo		; demo in there
	
	;xdef	_thisVBIptr	; to allow VBIHOOK
	xdef	_customVBI
	
	xdef	_installCVBI	; to have a C-routine run in the VBI
	xdef	_removeCVBI
	
	; 1/50 s int timer
	xdef	_g_vbitimer
	xdef	_g_renderedFrames
	
	; some test-code
;	xdef	_wosTest
	endc
	
	; adpcm ms playtime to vbi time
	xdef	_playtime2VbiCalculate
	;xdef	_playtime2VbiInit
	
	; interfaces
	xdef	_wosSetMode
	xdef	_wosSetCols
	xdef	_wosDisplay
	xdef	_wosCheckExit

	xdef	_wosAlloc
	xdef	_wosAllocChipMem
	xdef	_wosFreeChipMem
	
	xdef	_wosSetExit
	xdef	_wosClearExit
	xdef	_wosEffectTime
	;xdef 	_wosResetLev3
	xdef	_wosClearPlanes

	xdef	_wosSetupBitplaneLine
	xdef	_wosSetupCopper
	xdef	_bplloaderror
	
	; for sprites.s
	xdef	wosbase
	
	; effects
	xdef	_optimaTunnel
	xdef	_optimaVoxel
	xdef	_optimaWobble
	
	
	; sync stuff for c
	xdef	_bounceSchwabbelOn
	xdef	_bounceSchwabbelOff

	
	; from c
	xref	_g_currentPal
	
	; sprite fix
	;xref	_clearAllSprites


;---------------------------------------------------------------------------
; WickedOS with VBCC, Leif Oppermann, 23.02.2010
; - mixed C/ASM program starts via standard startup.o at main()
; - ...do stuff in main..
; - call wosInit(), which will shut down the system and call mainDemo()
; - ...do demo in mainDemo...
; -- call other wos subroutines, e.g. for displaying the screen (need to be written)
; - upon leaving mainDemo() the system will be restored and control returns to main()
; - exit 


	incdir	includes:
	include	hardware/custom.i
	include	hardware/dmabits.i
	include	hardware/intbits.i

	; needs to be linked, not run directly
	;move.l	#$dead,d0
	;rts
	

_wosInit:
	include	NewestWos.s
	
	;--- take system
	INITWOS
	
	;--- init mode15 extra bitplanes
	jsr	initMode15BPL

	;--- init wos effects
	;INITEFX	efx_wobble
	;INITEFX	efx_voxel
	;INITEFX	efx_tunnel
	
	;--- init music
	
;	ifd	ADPCM
;		;--- ADPCM init
;		;jsr	PaulaOutput_Init_8BitMono 
;		;jsr	AdpcmSource_Init_16BitMonoInput_8BitMonoOutput
;		ifnd	STEREOADPCM
;			lea	AdpcmFile,a0
;			move.w	#ReplayPeriod,d0
;			jsr    AdpcmSource_Init_16BitMonoInput_14BitMonoOutput
;		else
;			lea	AdpcmFileLeft,a0
;			lea	AdpcmFileRight,a1
;			move.w	#ReplayPeriod,d0
;			jsr		AdpcmSource_Init_16BitStereoInput_14BitStereoOutput
;		endc
;	else
;		;--- WAV init
;		lea	WavFile,a0
;		move.w	#ReplayPeriod,d0
;		;jsr	PaulaOutput_Init_8BitMono 
;		;jsr	AdpcmSource_Init_16BitMonoInput_8BitMonoOutput
;		jsr    WavSource_Init_16BitMonoInput_14BitMonoOutput
;	endc

;	;--- setup playtime to vbi conversion routine
	move.l	#0,Lev3Timer		; reset timer to zero after potentially long init
	bsr	_playtime2VbiInit

	;--- init vertical blanc interrupt, i.e. for the 50 Hz timer
	VBIHOOK	#vbi
	bsr	vbi 
	
	;--- ADPCM/WAV start
;	jsr    PaulaOutput_Start
	
	;--- call mainDemo
	;ifnd	TEST
	jsr	_mainDemo
	;else	
	
	;--- ADPCM/WAV stop
	VBIHOOK	#0
;	jsr    PaulaOutput_ShutDown
	
	;--- release system
	EXITWOS
	rts


;wrap up:
;- setmode
;- setcols
;- display(1,2)
;- checkexit
;- waitvbl
;- alloc

;- clearplanes
;- nomode


;SETCOLS Macro   ;^Palette,Brightness
;        move.l  \1,a0
;        move.l  \2,d0
;        wcall	SetColors
;        EndM

;DISPLAY Macro
;        moveq   #0,d0
;        wcall	Display
;        EndM

_wosSetMode:
;	
	move.l	4(a7),d0	; Mode
	move.l	8(a7),a0	; ^Buffer
	move.l	12(a7),a1	; ^Palette
	move.l	16(a7),d1	; Brightness
	push	a6
	wcall	SetModeAndColors
	pull	a6
	rts
	
_wosSetCols:
;	
;	move.l	4(a7),a0	; ^Palette
;	move.l	8(a7),d0	; Brightness
;	push	a6
;	wcall	SetColors
;	pull	a6
;	rts
;_hack_vbipal:
	; ugly, ugly workaroung because I couldn't get SETCOLS work from vbi
	move.l	4(a7),nvbi_pal			; ^palette
	move.l	8(a7),nvbi_bright		; brightness
	NEXTVBI	#_eff_smokecol_nvbi
	rts

nvbi_pal:	dc.l	0
nvbi_bright	dc.l	0
_eff_smokecol_nvbi:
	SETCOLS nvbi_pal,nvbi_bright
	rts

_wosDisplay:
;	in:0,1, or 2 for number of waitvbls
	move.l	4(a7),d0	; 0,1, or 2
	wcall	Display
	addq.l	#1,renderedFrames
	rts

_wosCheckExit:
; out: 0= continue / 1=Efx Exit / 2=User Exit
	moveq	#0,d0
	wcall	CheckExit	
	rts

_wosSetExit:
; set signal to exit this effect only
	jsr	_SetExit
	rts
	
_wosClearExit:
	move.l	#0,Lev3Timer 		; reset lev3timer for next use (important)
	cmp.b	#2,Esc
	beq.s	.dontClearSysExit	; #1 is effect exit, #2 is system exit (user pressed esc or mouse)
	jsr	_ClearExit
.dontClearSysExit
	rts

_wosEffectTime:
;	in: request runtime of following effect (in 1/50 s)
	move.l	4(a7),d0
	move.l	d0,ChildTimer 
	move.l	#0,Lev3Timer 
	add.l	d0,AllEfxPseudoTimer
	;todo:!!! noch evtl. verspätung mit in childtimer rein rechnen
	rts
	
;_wosResetLev3:
;	move.l	#0,Lev3Timer 
;	rts

_wosClearPlanes:
	CLEARPLANES
	rts

_wosSetupBitplaneLine:
;	in: a0 - bitplane id (0..7) , d1 - line number, d0 - pointer to bitplane data 

	move.l	4(a7),a0	; bitplane id (0..7)
	move.l	8(a7),d1	; line number
	move.l	12(a7),d0	; ^bitplane data
	SETLINE	a0,d1,d0
	rts

_wosSetupCopper:
;	in: d0 - colour index, a0 - pointer to gradient / list of 180 colours (4 bytes each, 00rrggbb)

	move.l	4(a7),d0	; colour index (0..2)
	move.l	8(a7),a0	; 180 gradients
	SETCOPPER	d0,a0
	rts


initMode15BPL:
	; hacked in for the moment, until we have a proper default
	lea 	bpl,a5		; 3 bitplanes in 320x200x32 cols
	move.l	#320*200/8,d2	; plane size
	move.l	#179,d3		; loop over line
.loopy:	
	move.l	#179,d1
	sub.l	d3,d1	; line
	SETLINE	#5,d1,a5

	move.l	#179,d1
	sub.l	d3,d1	; line
	move.l	a5,d0	; bpl pointer
	add.l	#320*200/8,d0
	SETLINE	#6,d1,d0

	move.l	#179,d1
	sub.l	d3,d1	; line
	move.l	a5,d0	; bpl pointer
	add.l	#320*200/4,d0
	SETLINE	#7,d1,d0

	add.l	#320/8,a5
	dbf	d3,.loopy

	rts


_wosAlloc:
;        move.l	4(a7),d1	;banknummer
;        move.l	8(a7),d0	;größe
;	wcall Alloc

	ALLOC	4(a7),8(a7)
	move.l	d0,12(a7)	;return start of mem or 0
	rts

;*************** 
; in: size to allocate
;out: d0 - adr of memory or 0
_wosAllocChipMem:
	move.l	4(a7),d0			; bytesize
	;move.l	#$30002,d1			; attributes (MEMF_...) for cleared chip mem
	move.l	#%1110000001000000011,d1			; attributes (MEMF_...) for cleared chip mem, + public
	move.l  $4.w,a6
	jsr     _LVOAllocMem(a6)	; AllocVec is buggy!?
	rts

; in: adr to free
;out: none
_wosFreeChipMem:
	move.l	4(a7),a1			; memoryBlock
	move.l	8(a7),d0			; bytesize
	move.l  $4.w,a6
	jsr     _LVOFreeMem(a6)
	rts


_optimaTunnel:
	;;INITEFX	efx_tunnel
	;CALLEFX	efx_tunnel
	;EXITEFX	efx_tunnel
	rts
	
_optimaVoxel:
	;;INITEFX	efx_voxel
	;CALLEFX	efx_voxel
	;EXITEFX	efx_voxel
	rts
		
_optimaWobble:
	;;INITEFX	efx_wobble
	;CALLEFX	efx_wobble
	;EXITEFX	efx_wobble
	rts
		
;----------------------------------------------------	
; effect tracker for C-based effects
FAD=32		;fadein/out
FSTEP=12	;flash
FLEN=16
		
g_flashAndBounceIRQ_Enabled	dc.l	0

	
_bounceSchwabbelOn:
	EFFECTTRACKER	#patternlistSchwabbel
	move.l	#1,g_flashAndBounceIRQ_Enabled
	rts
	
_bounceSchwabbelOff:
	EFFECTTRACKER	#0
	SETSCREEN	#0,#0
	move.l	#0,g_flashAndBounceIRQ_Enabled
	rts	
	
flashAndBounceIRQ:
		; flashen und bouncen passiert im effecttracker
			
		;- geflashte farben nachfaden
		move.l	color1st,d0
		mulu.l	color2nd,d0
		lsr.l	#8,d0
		move.l	d0,colorresult
	
		move.l	color2nd,d1
		sub.l	#FSTEP,d1
		cmp.l	#255,d1
		bge.s	.colpos
		move.l	#255,d1
.colpos
		move.l	d1,color2nd
	
	
		;farben aktualisieren
		SETCOLS	_g_currentPal,colorresult
		
		rts

flash:	move.l	#255+FSTEP*FLEN,color2nd
	rts

	
flashOff	move.l	#0,g_flashAndBounceIRQ_Enabled
	rts
	
bounce1:
	move.l	#0,bounceCount
bounce1Int:
	move.l	bounceCount,d0
	move.w	bounce1dat,d1		; number of steps in bounce
	cmp.w	d1,d0
	beq.s	.fini

	add.l	#1,bounceCount
	lsl.l	#1,d0
	lea		bounce1dat(pc),a0
	move.l	(a0,d0.w),a1

	SETSCREEN	#0,a1
	NEXTVBI	#bounce1Int
	rts
.fini:	
	SETSCREEN	#0,#0
	rts

bounce2:
	move.l	#0,bounceCount
bounce2Int:
	move.l	bounceCount,d0
	move.w	bounce2dat,d1		; number of steps in bounce
	cmp.w	d1,d0
	beq.s	.fini

	add.l	#1,bounceCount
	lsl.l	#1,d0
	lea		bounce2dat(pc),a0
	move.l	(a0,d0.w),a1

	SETSCREEN	#0,a1
	NEXTVBI	#bounce2Int
	rts
.fini:	
	SETSCREEN	#0,#0
	rts
	
bounce3:
	move.l	#0,bounceCount
bounce3Int:
	move.l	bounceCount,d0
	move.w	bounce3dat,d1		; number of steps in bounce
	cmp.w	d1,d0
	beq.s	.fini

	add.l	#1,bounceCount
	lsl.l	#1,d0
	lea		bounce3dat(pc),a0
	move.l	(a0,d0.w),a1

	SETSCREEN	#0,a1
	NEXTVBI	#bounce3Int
	rts
.fini:	
	SETSCREEN	#0,#0
	rts
	
color1st	dc.l	256
color2nd	dc.l	256
colorresult	dc.l	0

;--- hier wird das bouncen und flashen getimed
bounceCount:	dc.l	0
	


schwabbelpat		dc.b	"ET",64,-1

		dc.l	0,0,0,0
		dc.l	bounce1,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,flash,0

		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	bounce2,0,0,0
		dc.l	0,0,flash,0

		dc.l	0,0,0,0
		dc.l	bounce1,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,flash,0

		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	bounce2,0,0,0
		dc.l	0,0,flash,0
		
patternlistSchwabbel:
	dc.l	schwabbelpat,schwabbelpat,schwabbelpat,schwabbelpat
	dc.l	schwabbelpat,schwabbelpat,schwabbelpat,patFlashOnly
	dc.l	-1
	

; with strong bounce
	
patFlashOff:	dc.b	"ET",64,-1
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,flash,0
		
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,flash,0

		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,flash,0

		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,flashOff,0

patFlashOnly:	dc.b	"ET",64,-1
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,flash,0
		
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,flash,0

		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,flash,0

		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,0,0
		dc.l	0,0,flash,0
				
bounce2dat:
	; schwächerer Sinus						(kurz und gut)
	dc.w	9
	dc.w	-6,-3,1,6,2,0,-2,-4,-2,0

	; noch besserer Sinus					(etwas härter)
;	dc.w	10
;	dc.w	-12,-6,2,11,5,1,-5,-8,-4,1,0


bounce1dat:
	;weicher Sinus (schwächer)				(kurz und gut, leichter heber)
	dc.w	10
	dc.w	-1,-4,-6,-4,-1,1,4,6,4,1,0

	;guter Sinus (ms00) - kommt zu verzögert, müsste im pattern früher gesetzt werden
;	dc.w	14
;	dc.w	-12,-8,-2,2,8,11,7,3,1,-5,-8,-6,-2,1,0
	
	;Vert. Flimmer
;	dc.w	29,0
;	dc.w	-28,27,-26,25,-24,23,-22,21,-20,19,-18,17,-16,15,-14,13,-12,11,-10,9,-8,7,-6,5,-4,3,-2,1,0

bounce3dat:
	;Vert. Flimmer
	dc.w	29,0
	dc.w	-28,27,-26,25,-24,23,-22,21,-20,19,-18,17,-16,15,-14,13,-12,11,-10,9,-8,7,-6,5,-4,3,-2,1,0


	even
	

;----------------------------------------------------	
_removeCVBI:
	move.l	#0,_cVBI
	rts
	
_installCVBI:
	move.l	4(a7),d0
	move.l	d0,_cVBI
	rts
	
	
vbi:
	movem.l	d0-a6,-(a7)
	addq.l	#1,vbitimer

	;jsr	_clearAllSprites

	;--- custom VBI code
	move.l	_customVBI(pc),a0
	cmp.l	#0,a0		;customVBI requested?
	beq		.n1
	jsr		(a0)
.n1:

	;--- C VBI code
	move.l	_cVBI(pc),a0
	cmp.l	#0,a0		;cVBI requested?
	beq		.n2
	jsr		(a0)
.n2:

	;--- effecttracker additional VBI code
	cmp.l	#1,g_flashAndBounceIRQ_Enabled
	bne.s	.n3
	jsr		flashAndBounceIRQ
.n3:

	;--- ADPCM
	;jsr		PaulaOutput_VertBCallback
		
	;--- calculate pattern and position from ADPCM VBI playtime
	jsr		_playtime2VbiCalculate
	
	move.l	currentpos,d0
	move	d0,_ETrow
	move.l	currentpat,d0
	move	d0,_ETposition
	
	movem.l	(a7)+,d0-a6
	rts

_cVBI:	dc.l	0		; will be execute if !=0 (use installVBI / removeVBI)
_customVBI:	dc.l	0	; will be executed if !=0 (use directly, take care)
	
_g_vbitimer:
vbitimer:	dc.l	0	; incremented by 1 every tick

_g_renderedFrames
renderedFrames	dc.l	0	; incremented by 1 every frame

;----------------------------------------------------
PATROWS			equ	64	; to mimick a tracker pattern (4 bars / takte)
	ifnd	STEREOADPCM
PAT4DURATION	equ	10975	; ms per 4 patterns (easier to spot in audio editor)
	else
PAT4DURATION	equ	10970	; ms per 4 patterns (easier to spot in audio editor)
	endc

_playtime2VbiCalculate:	
	; convert vbi to pat
	move.l	vbitimer,d0
	;move.l	Lev3Timer,d0
	
		move.l	d0,a0		; save for second calculation
	mulu	#20,d0			; 1 vbi is 20 ms
	divu	patduration,d0	
	and.l	#$ffff,d0
	move.l	d0,currentpat	;	>>> save result 1 (number of current pattern)

	; reduce vbi by pat * patduration 
	mulu	patduration,d0	; pat * patduration	  (patternduration * pattern)
	move.l	d0,d1		; save time to subtract   (in ms)

	; convert vbi time in d0 to row position
	; vbi 4 = pos 1, vbi 20 = pos 9
	move.l	a0,d0	; saved copy of vbitimer
	mulu	#20,d0								  (in ms)
	sub.l	d1,d0	; subtract time already spent in other patterns

	divu	rowduration,d0						  (in ms)
	and.l	#$ffff,d0
	move.l	d0,currentpos	;	>>> save result 2

	rts


_playtime2VbiInit:
	; estimate time of one pat in ms
	move.l	#PAT4DURATION,d0
	lsr.l	#2,d0
	move	d0,patduration

	; estimate time of one row in ms
	; (here 4x64 rows are 11000 ms, so one row is 42.96875 ms)
	
	move.l	#PAT4DURATION,d0
	divu	#PATROWS*4,d0

	; check for rounding up
	swap	d0
	cmp	#$80,d0		; .5 or higher?
	blt	.noround
	add.l	#$00010000,d0
.noround
	swap	d0
	and.l	#$ffff,d0	; mask out division remainder
	move	d0,rowduration

	rts
	
patduration:	dc.w	0
rowduration:	dc.w	0	; ms per "protracker" row position

	; results of this routine per vbi
currentpat:	dc.l	0
currentpos:	dc.l	0
;----------------------------------------------------
	ifd	ADPCM
		;include	AdpcmSource.s
	else
		;include	WavSource.s
	endc
	;include	PaulaOutput.s

;------ Data
	section	effects,data

	;DEFEFX	efx_tunnel,e_tunnel,1096+548-6	; +0/+4/+8
	;DEFEFX	efx_voxel,e_voxel,1097
	;DEFEFX	efx_wobble,e_wobble,1098
	
	;	    ^    ^        ^
	;       Name |        |
	;            Location |
	;                     Time in 1/50 sec.
	
	;INCEFX	e_tunnel:,"own:demo/asm/tunnel_quant.wos"
	;section	effects,data
	;INCEFX	e_voxel:,"own:demo/asm/voxel.wos"
	;section	effects,data
	;INCEFX	e_wobble:,"own:demo/asm/wobble.wos"
	;	^       ^
	;	Label   |
	;	        Filename 
	
;	section	music,data
;	ifd	ADPCM
;	ifnd STEREOADPCM
;AdpcmFile
;		incbin	music/muffler-melodrama.adpcm
;		;incbin	music/muffler-melodrama-28600-left.adpcm
;	else
;AdpcmFileLeft
;		incbin	music/muffler-melodrama-28600-left.adpcm
;AdpcmFileRight
;		incbin	music/muffler-melodrama-28600-right.adpcm
;	endc
;	else
;WavFile
;		incbin	music/melodrama75.wav
;	endc
	
	section	bpl,data_c
_bplloaderror:
bpl:	
	ds.l	64000
	;incbin	dat/loaderror_320x200x8.bpl
bpl_end:
