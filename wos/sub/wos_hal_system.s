; wos hardwareabstractionlayer
; system mode

; for display, interrupts, etc.
	rts


; required functions:
; - wosInitHAL
; - wosActivateHAL
; - wosReleaseHAL


CALL:	MACRO
	jsr	_LVO\1(a6)
	ENDM

INTB_VERTB equ	5			; for vblank interrupt
INTB_COPER equ	4			; for copper interrupt




;
; ----	general init/release
;

; init hardware abstraction layer
wosInitHAL:
	; Get VBR (68010+)
	lea	_wosbase,a0
	move	CPU(a0),d0
	and	#1,d0
	beq.s	.no10

	lea	getvbr(pc),a5
	move.l	4.w,a6
	jsr	-30(a6)
	lea	vbroffset(pc),a0
	move.l	d0,(a0)
.no10:	
	ifnd	NOSPRITESFIX
		jsr	FixSpritesSetup
	endc

	rts

vbroffset
	dc.l	0
getvbr	;movec   vbr,d0
	dc.l	$4e7a0801
	rte

;-------------- v39 Sprites-Fix by CJ/SAE
	ifnd	NOSPRITESFIX
	ifd	WOSASSIGN
		include	wos:sub/fixsprites.s
	else
		include	sub/fixsprites.s
	endc
	endc


;
; ----	display stuff
;
wosReleaseHAL:
	ifnd	NOSPRITESFIX
                jsr	ReturnSpritesToNormal
	endc

	jsr	_displayRelease
	rts

; display abstration, to allow killer and system-friendly displays
; to be plugged into WOS at take: and give:
; also activate interrupts

; everything else should be transparent

; in: a0 - ptr to level3server (to end on rts)
; returns d0=0 on success, otherwise error

wosActivateHAL:
	move.l	a0,hallev3ptr
	jsr	_displayInit

	; install vbi
	lea	hallev3(pc),a1
	move.l	a1,_thisVBIptr2

	WINUAEBREAKPOINT

	moveq.l	#0,d0
	rts

hallev3ptr:
	dc.l	0
hallev3:
	;push  d0/d1/a0/a1/a5/a6
	push	d0-a6

	;!!! FPU context save
	fsave	-(a7)
	fmovem	fp0-fp7,-(a7)

;----   Vertical Blanc
.vertb:	move.l	hallev3ptr(pc),a0
	cmp.l	#0,a0
	beq.s	.nolev3
	jsr	(a0)

.nolev3:
.quithalL3:

	;!!! fpu context restore
	fmovem	(a7)+,fp0-fp7
	frestore (a7)+

	;pull  d0/d1/a0/a1/a5/a6
	pull	d0-a6
	nop
	rts				;rte


; as called by macro WAITVBL
wait_vert_blanc:
	move.l	gfxbase,a6
        jsr 	_LVOWaitTOF(a6)
	rts


	section	chip,data_c
miniCopList
	dc.w	$01fc,0,$106,0
	dc.w	$0180
miniCopListC0
	dc.w	$000
	dc.l	-2

	section	code,code
;
; routines from demolib.s
;

_displayInit:
	;WINUAEBREAKPOINT
	move.l	4.w,a6
	sub.l	a1,a1
	jsr	_LVOFindTask(a6)
	move.l	d0,a2

	; open intuition.library v39 for v39+ sprites fix
	lea	intname,a1
	moveq	#39,d0			;kick3.0
	move.l	4.w,a6
	jsr	_LVOOpenLibrary(a6)
	lea	intbasev39(pc),a0
	move.l	d0,(a0)

	; open graphics.library
	lea	gfxname,a1
	moveq	#33,d0			; Kickstart 1.2 or higher
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_GfxBase
	beq	.nogfx
	move.l	d0,a6

	; apply v39+ sprites fix
	tst.l	intbasev39
	beq.s	.cont
;   bsr   FixSpritesSetup
	nop
.cont	; init msgport
	move.l	4.w,a6
	moveq	#-1,d0
	jsr	_LVOAllocSignal(a6)
	move.b	d0,_sigbit
	bmi	.nosignal		; this actually fails sometimes when you forget to FreeSignal upon exit
	move.l	a2,_sigtask

	; hide possible requesters since user has no way to
	; see or close them.
	moveq	#-1,d0
	move.l	pr_WindowPtr(a2),_oldwinptr
	move.l	d0,pr_WindowPtr(a2)

	; set task priority
	move.l	a2,a1			;task
	move.l	#0,d0			;priority (20 seems like the maximum possible here, prevents loading already)
	jsr	_LVOSetTaskPri(a6)

	; open input.device
	lea	inputname(pc),a0
	moveq	#0,d0
	moveq	#0,d1
	lea	_ioreq(pc),a1
	jsr	_LVOOpenDevice(a6)
	tst.b	d0
	bne	.noinput

	; install inputhandler
	move.l	#0,_exitSignal

	lea	_ioreq(pc),a1
	move.w	#IND_ADDHANDLER,IO_COMMAND(a1)
	move.l	#_ih_is,IO_DATA(a1)
	jsr	_LVODoIO(a6)

	; save old view
	move.l	4.w,a6
	jsr	_LVOForbid(a6)

	move.l	_GfxBase,a6
	move.l	gb_ActiView(a6),_oldview

	; flush view
	sub.l	a1,a1
	jsr	_LVOLoadView(a6)
	jsr	_LVOWaitTOF(a6)
	jsr	_LVOWaitTOF(a6)
	move.l	#miniCopList,$dff080

	move.l	4.w,a6
	jsr	_LVOPermit(a6)

	; add vertical blank interrupt
	moveq.l	#INTB_VERTB,d0		; INTB_COPER for copper interrupt
	lea	VBlankServer(pc),a1
	CALL	AddIntServer		;Add my interrupt to system list

	move.l	#0,d0			; okay
	rts

;
; error cases for displayInit
;
.noinput:
.c1	move.l	_sigtask(pc),a0
	move.l	_oldwinptr(pc),pr_WindowPtr(a0)

	moveq	#0,d0
	move.b	_sigbit(pc),d0
	move.l	4.w,a6
	jsr	_LVOFreeSignal(a6)
.nosignal:
.nogfx	; sprites fix v39+ intuition base
	move.l	intbasev39(pc),d0
	beq.w	.out
	move.l	d0,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

.out	move.l	RETURN_FAIL,d0		; error
	rts


_displayRelease:
	; remove VBI
	move.l	$4.w,a6
	moveq.l	#INTB_VERTB,d0		;Change for copper interrupt.
	lea	VBlankServer(pc),a1
	CALL	RemIntServer		;Remove my interrupt

	; restore view & copper ptr
	move.l	_GfxBase,a6
	sub.l	a1,a1
	jsr	_LVOLoadView(a6)
	move.l	_oldview(pc),a1
	jsr	_LVOLoadView(a6)
	move.l	gb_copinit(a6),$DFF080
	jsr	_LVOWaitTOF(a6)
	jsr	_LVOWaitTOF(a6)

	; close graphics.library
	move.l	a6,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)

.nogfx:	; remove inputhandler
	lea	_ioreq(pc),a1
	move.w	#IND_REMHANDLER,IO_COMMAND(a1)
	move.l	#_ih_is,IO_DATA(a1)
	jsr	_LVODoIO(a6)

	lea	_ioreq(pc),a1
	jsr	_LVOCloseDevice(a6)

.noinput:
	move.l	_sigtask(pc),a0
	move.l	_oldwinptr(pc),pr_WindowPtr(a0)

	moveq	#0,d0
	move.b	_sigbit(pc),d0
	move.l	4.w,a6
	jsr	_LVOFreeSignal(a6)

	; v39 sprites fix
	move.l	intbasev39(pc),d0
	beq.s	.cont
	move.l	d0,a6
	;bsr   ReturnSpritesToNormal
	move.l	a6,a1
	move.l	4.w,a6
	jsr	_LVOCloseLibrary(a6)
.cont:	rts

; ==============================================================
; handler for vertical blank interrupt and input
; ==============================================================

;
; vertical blank interrupt
;
; http://jvaltane.kapsi.fi/amiga/howtocode/interrupts.html

vbitimer:
	dc.l	0
IntLevel3:
;      movem.l  d2-d7/a2-a4,-(sp)    ; all other registers can be trashed    
	movem.l	d0-a6,-(sp)

	; simple VBI timer
	add.l	#1,vbitimer

	; VBIHOOK requested?
	move.l	_thisVBIptr2,a0
	cmp.l	#0,a0
	beq.s	.n1
	nop
	jsr	(a0)			;VBI from VBIHOOK (not this MainVBI !!!)
.n1
;      ...
;      movem.l  (sp)+,d2-d7/a2-a4
	movem.l	(sp)+,d0-a6

;     If you set your interrupt to priority 10 or higher then
;     a0 must point at $dff000 on exit.

	moveq	#0,d0			; must set Z flag on exit!
	rts				;Not rte!!!

_thisVBIptr2:
	dc.l	0

VBlankServer:
	dc.l	0,0			;ln_Succ,ln_Pred
	dc.b	2,0			;ln_Type,ln_Pri
	dc.l	IntName			;ln_Name
	dc.l	0,IntLevel3		;is_Data,is_Code

IntName:
	dc.b	"Dexion	&SAEIntLevel3",0     ; :-)
	EVEN

_setVBI:
	move.l	4(a7),_thisVBIptr2
	rts



inputname:
	dc.b	'input.device',0
;gfxname:
;	dc.b	'graphics.library',0

	CNOP	0,4

MX	dc.w	0			; dummy mouse coordinates
MY	dc.w	0

_args:	dc.l	0,0
_oldwinptr:
	dc.l	0
_WBenchMsg:
	dc.l	0
_GfxBase:
	dc.l	0
_oldview:
	dc.l	0
intbasev39:
	dc.l	0

_msgport:
	dc.l	0,0			; LN_SUCC, LN_PRED
	dc.b	NT_MSGPORT,0		; LN_TYPE, LN_PRI
	dc.l	0			; LN_NAME
	dc.b	PA_SIGNAL		; MP_FLAGS
_sigbit:
	dc.b	-1			; MP_SIGBIT
_sigtask:
	dc.l	0			; MP_SIGTASK
.head:	dc.l	.tail			; MLH_HEAD
.tail:	dc.l	0			; MLH_TAIL
	dc.l	.head			; MLH_TAILPRED

_ioreq:	dc.l	0,0			; LN_SUCC, LN_PRED
	dc.b	NT_REPLYMSG,0		; LN_TYPE, LN_PRI
	dc.l	0			; LN_NAME
	dc.l	_msgport		; MN_REPLYPORT
	dc.w	IOSTD_SIZE		; MN_LENGTH
	dc.l	0			; IO_DEVICE
	dc.l	0			; IO_UNIT
	dc.w	0			; IO_COMMAND
	dc.b	0,0			; IO_FLAGS, IO_ERROR
	dc.l	0			; IO_ACTUAL
	dc.l	0			; IO_LENGTH
	dc.l	0			; IO_DATA
	dc.l	0			; IO_OFFSET

_exitSignal:
	dc.l	0			; 1 if we need to exit

_ih_is:	dc.l	0,0			; LN_SUCC, LN_PRED
	dc.b	NT_INTERRUPT,127	; LN_TYPE, LN_PRI ** highest priority is 127**
	dc.l	.ih_name		; LN_NAME
	dc.l	0			; IS_DATA
	dc.l	.ih_code		; IS_CODE


;
; input handler code
;
; http://amigadev.elowar.com/read/ADCD_2.1/Devices_Manual_guide/node00D3.html
.ih_code:
	move.l	a0,d0
.loop:
; see http://amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0055.html for InputEvent.ie_Class
; IECLASS_RAWKEY	   : $01
; IECLASS_RAWMOUSE	: $02
; IECLASS_TIMER      : $06 (often)
	cmp.b	#IECLASS_RAWKEY,ie_Class(a0)
	bne.s	.nokey
	cmp.w	#69,ie_Code(a0)		;pressed Escape?
	bne.s	.nokey
	move.l	#1,_exitSignal
	move.b	#2,Esc

	bra.s	.eat

.nokey	cmp.b	#IECLASS_RAWMOUSE,ie_Class(a0)
	bne.s	.nomouse
	cmp.w	#IECODE_LBUTTON,ie_Code(a0) ;pressed LMB?
	bne.s	.nomouse

	move.l	#1,_exitSignal
	move.b	#2,Esc


.nomouse

.eat	move.b	#IECLASS_NULL,ie_Class(a0)
	move.l	(a0),a0
	move.l	a0,d1
	bne.b	.loop

	; d0 is the original a0
	rts

.ih_name:
	dc.b	'eat-events inputhandler',0

	CNOP	0,4

_checkExit:
	move.l	_exitSignal,d0
	rts
