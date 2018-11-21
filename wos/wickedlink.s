; wickedlink.s (27.11.2017 & 21.11.2018)
; wos-side assembly link layer, i.e. this file get assembled as part of building a wos object (currently requires Amiga-side Devpac assembler)
; demo-side assembly stuff removed from this file, so that that can be assembled with vasm and included in PC-makefile

; layering of code is as follows:
; - wos_v1.6.s (lowest layer, needs building on Amiga with Devpac)
; -- wickedlink.s (wos-side assembly link-layer, needs building on Amiga with Devpac)

; --- assembly-bridge.s (can be assembled on PC, part of makefile)
; ---- main.c (do your demo here)
; note together wos_v1.6.s and wickedlink.s form the wickedlink.o which can be linked on PC

; based on Beam Riders file "wicked3.s"

REPLAY=0	; no legacy music support, here (you probably want adpcm anyway)
;DEBUG		; do stop at program end and allow searching for Enforcer hits
;KILLER		; build display using killer hardware abstraction layer (HAL)
		; defaults to using system-friendly mode

	; main interface
	xdef	_wosInit	; won't return, will call mainDemo though
	xref	_mainDemo		; demo in there
	
	xdef	_installCVBI	; to have a C-routine run in the VBI
	xdef	_removeCVBI

	; bridge interfaces
	xref _wosInitAssemblyBridge
	xref _wosReleaseAssemblyBridge
	xdef _wosBridgeSetVBI
	xdef	_customVBI

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
	xdef	_wosClearPlanes

	xdef	_wosSetupBitplaneLine
	xdef	_wosSetupCopper
;	xdef	_bplloaderror
	
	; for sprites.s
	xdef	wosbase
	
	xdef	_g_renderedFrames
	xdef	_cVBI

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


	section code,code
_wosInit:
	include	wos.i
	
	;--- take system
	INITWOS

	;--- init mode15 extra bitplanes
	;jsr	initMode15BPL	; todo
	
	;///// bridge init-routine, might install VBI and such
	move.l	#0,Lev3Timer		; reset timer to zero after potentially long init
	jsr _wosInitAssemblyBridge
		
	;--- call mainDemo
	jsr	_mainDemo

	;///// bridge release
	jsr _wosReleaseAssemblyBridge

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

_wosBridgeSetVBI:
	; wraps up VBIHOOK, set to function-pointer or 0
	;move.l	4(a7),_thisVBIptr
	move.l	a0,_thisVBIptr
	rts

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
	move.l	4(a7),a0	; ^Palette
	move.l	8(a7),d0	; Brightness
	push	a6
	wcall	SetColors
	pull	a6
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
		xdef	_g_renderedFrames
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
	;todo:!!! noch evtl. verspaetung mit in childtimer rein rechnen
	rts
	
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

_wosAlloc:
;        move.l	4(a7),d1	;banknummer
;        move.l	8(a7),d0	;groeﬂe
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


;----------------------------------------------------	
_cVBI:	dc.l	0		; will be execute if !=0 (use installVBI / removeVBI)
_customVBI:	dc.l	0	; will be executed if !=0 (use directly, take care)

_g_renderedFrames
renderedFrames	dc.l	0	; incremented by 1 every frame


;----------------------------------------------------	
_removeCVBI:
	move.l	#0,_cVBI
	rts
	
_installCVBI:
	move.l	4(a7),d0
	move.l	d0,_cVBI
	rts
	
