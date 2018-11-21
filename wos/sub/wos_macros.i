;***************************************************************************
;* WOS_Macros.i by Leif Oppermann                                          *
;* use these in your source to access the WOS-functions                    *
;***************************************************************************

;Note1: a6 is RESERVED for wosbase FROM NOW ON!
;	
;       nevertheless the macros still start with "move.l wosbase,a6" unless
;       you set SHORTMACROS which will force the macros to rely on Note1.
;	i just wanted to point out that a6 is mine :)
;
;Note2: a0/a1/d0/d1 are SCRATCH-REGISTERS 
;
;       They will most probably not be the same after
;       calling one of the functions!!!


	ifnd	WOS_MACROS_I
WOS_MACROS_I	set	1

wcall	Macro	;
	ifnd	SHORTMACROS
		move.l	wosbase,a6	;let the assembler put in the "(pc)"
	endc
	jsr	_W\1(a6)
	endm
	
wbase	macro
	move.l	wosbase,a6
	endm

;-------------- The MOST important stuff:

INITWOS Macro
_Main:		;a0 - ^wosbase
		;a1 - ^where the WOS_MainVBI pointer must be written to
		;d0 - for your use!
		;d1 - effects time in ticks

	move.l	a1,a2
	movem.l	d0-d1,-(a7)

        lea     wosbase,a1
        move.l  a0,(a1)		;store the wosbase for use by the macros
	move.l	a0,a6		;WOSBASE in A6!!!

	ifd	DK3D
		lea	dk3dbase(pc),a0
		move.l	dk3dptr(a6),(a0)
		bne.s	.ispresent
		movem.l	(a7)+,d0-d1		
		move.l	#$bad3d,d0
		rts
.ispresent	
	endc

	lea	mmstable(pc),a0
	move.l	a0,_mmstabptr(a6)

	lea	WOS_MainVBI(pc),a0
	move.l	a0,(a2)		;register the VBI with the parent process
	
        jsr     _WInit(a6)	;call some small init routines (timer-reset,..)


        jmp	WOS_InitSkip

wosbase:	dc.l    0
	ifd	DK3D
dk3dbase:	dc.l	0
	endc

_thisVBIptr	dc.l	0	;filled if VBIHOOK is called

	;essential information for INITEFX CALLEFX EXITEFX
	;don't change the order of these 
CallEfxInfo:
_childVBIptr	dc.l	0	;filled if this effect calls another
Lev3Timer	dc.l	0	;only for kicking the clients
				;(reset each time we call a client)
ChildTimer	dc.l	0	;this is the exit time of our client
				;(will be compared with Lev3Timer)

WOS_MainVBI:			;driven by our parent
	move.l	Lev3Timer(pc),d0
	addq.l	#1,d0
	move.l	d0,Lev3Timer
	move.l	ChildTimer(pc),d1
	beq.s	.noquityet	;there is no child-process

	cmp.l	d0,d1
	bhs	.noquityet

.exi	SETEXIT			;tell the child to stop playing
		;NOTE: We don't need to figure out our own exit-time!
		;      This job is done by the parent-process.
.noquityet
	move.l	_thisVBIptr(pc),a0
	cmp.l	#0,a0		;VBIHOOK requested?
	beq.s	.n1
	nop
	jsr	(a0)		;VBI from VBIHOOK (not this MainVBI !!!)
.n1		
	move.l	_childVBIptr(pc),a0
	cmp.l	#0,a0
	beq.s	.n2
	nop
	jsr	(a0)		;child VBI (if the client is now a server)
.n2	
;	move.l	_childVBIptr,a0
;	tst.l	a0
;	beq.s	.skipnextl3
	bsr	_NextVBIL3
;.skipnextl3
	rts

	ifnd	bnknum
bnknum=32			;number of banks for this client
	endc
mmstable:
	dc.l	bnknum
	ds.l	bnknum*2

;--- NEXTVBI
MAX_NVBI	equ	1	;absolute max is 65535

;called from Level3
_NextVBIL3:
	move.l	nextptr,a0
	move.l	currentptr,a1
	move.l	a1,nextptr
	move.l	a0,currentptr	;this will be worked down now

	move.l	(a0),d0
	beq.s	.done
	move.l	#0,(a0)+	;clear num of nvbis
	subq.l	#1,d0		;loop counter	

.loop	move.l	(a0)+,a1
	move.l	#0,-4(a0)
	move.l	a0,-(a7)
	move.l	d0,-(a7)
	cmp.l	#0,a1
	beq.s	.nojump
	jsr	(a1)
.nojump
	move.l	(a7)+,d0
	move.l	(a7)+,a0
	dbf	d0,.loop	
.done	rts

;called from NEXTVBI macro
_NextVBI:	
;in: a0 - ptr to routine to call in next vertical blanc interrupt
	move.l	nextptr,a1
	move.l	(a1),d0
	cmp.l	#MAX_NVBI,d0
	bge	.error		;too much nvbi

	addq.l	#1,d0		;make d0 an offset
	lsl.l	#2,d0
	add.l	#1,(a1)		;it's one more nvbi now
	add.l	d0,a1		;point to the next free slot
	move.l	a0,(a1)		;save the pointer
	rts

.error:
	rts
;	SERROR	Too_much_NEXTVBI!

currentptr:	dc.l	nvbiptrs1
nextptr:	dc.l	nvbiptrs2

nvbiptrs1:
	dc.l	0		;num of routines to call
	ds.l	MAX_NVBI	;ptr to each routine


nvbiptrs2:
	dc.l	0		;num of routines to call
	ds.l	MAX_NVBI	;ptr to each routine

WOS_InitSkip:
   jsr _WaitVBL	; wait for display, esp. in winuae
	jsr _WaitVBL	; twice, just like waittof
	movem.l	(a7)+,d0-d1	;!!! your code starts here
        EndM



EXITWOS	Macro
_Quit:	move.l	d0,d2	;save the returncode

;	move.w	#$4000,$dff09a	; disable master interrupt (INTEN)
	
	VBIHOOK	#0	;kill the User-VBI
;	move.l	vbroffset,a0
;	move.l  oldlev1,$64(a0)	; kill level1 softint

;	move.w	#$C000,$dff09a	; enable master interrupt (INTEN)


	move.l	wosbase,a6	;just to be sure
	jsr	_WExit(a6)	;do some small cleanup (free membanks, wait for
				;Blitter, clear _mmstabptr(wosbase) ...)
	move.l	d2,d0
	rts		;exit the effect
	Endm

;*****************************************************************************

	ifnd	NOMMS

;-------------- Memory Allocation Routines (7 for you, 7 for the system)

;------ these are for you
ALLOCCHIP	macro           ; \1 + \2
        move.l  \1,d1		;banknummer
        move.l  \2,d0		;größe
        wcall	AllocChip

        endm

ALLOC	macro			; \1 + \2
        move.l  \1,d1		;banknummer
        move.l  \2,d0		;größe
        wcall	Alloc
        endm
                
START	macro			; \1
        move.l  \1,d0		;banknummer
        wcall	Start
        endm
        
LENGTH	macro			; \1
;	WMI
        move.l  \1,d0		;banknummer
        wcall	Length
        endm

ERASE	macro			; \1
;	WMI
        move.l  \1,d0		;banknummer
        wcall	Erase
        endm

ERASEALL	macro           ; keine parameter
        wcall	EraseAll
        endm

ALLOCANY	macro
;	WMI
	move.l	\1,d0
	wcall	AllocAny
	endm

ALLOCANYCHIP	macro
	move.l	\1,d0
	wcall	AllocAnyChip
	endm
	
;GETANY	macro			; keine Parameter
;	wcall	GetAny
;	endm

;------ these are for the system

SYSALLOCCHIP	macro           ; \1 + \2
        move.l  \1,d1		;banknummer
        move.l  \2,d0		;größe
        wcall	SYSAllocChip
        endm

SYSALLOC	macro		; \1 + \2
        move.l  \1,d1		;banknummer
        move.l  \2,d0		;größe
        wcall	SYSAlloc
        endm
                
SYSSTART	macro		; \1
        move.l  \1,d0		;banknummer
        wcall	SYSStart
        endm
        
SYSLENGTH	macro		; \1
        move.l  \1,d0		;banknummer
        wcall	SYSLength
        endm

SYSERASE	macro		; \1
        move.l  \1,d0		;banknummer
        wcall	SYSErase
        endm

SYSERASEALL	macro           ; keine parameter
        wcall	SYSEraseAll
        endm

SYSALLOCANY	macro
	move.l	\1,d0
	wcall	SYSAllocAny
	endm

SYSALLOCANYCHIP	macro
	move.l	\1,d0
	wcall	SYSAllocAnyChip
	endm

;SYSGETANY	macro		; keine Parameter
;	wcall	SYSGetAny
;	endm

	endc


;------- Macros for loading data

LOADANYCHIP	macro			; \1 \2 
	wbase
        move.l  \1,_a0(a6)		; adresse des dateinamens
        move.l  #2,_d0(a6)		; chip
	jsr	_WLoad(a6)
        endm

LOADANY	macro				; \1 \2
	wbase
        move.l  \1,_a0(a6)
        move.l  #1,_d0(a6)		; public
	jsr	_WLoad(a6)
        endm

LOADFROM	macro			; \1
	wbase
	move.l	\1,_a0(a6)
	jsr	_WLoadFrom(a6)
	endm

;*****************************************************************************

;-------------- These can be used happily by your effect

SETMODE Macro   ; Mode,^Buffer,^Palette,Brightness
        move.l  a6,-(a7)
        move.l  \1,d0
        move.l  \2,a0
        move.l  \3,a1
        move.l  \4,d1
        wcall	SetModeAndColors
	SETBUFFER \2
        move.l  (a7)+,a6
        EndM    

SETCOLS Macro   ;^Palette,Brightness
        move.l  \1,a0
        move.l  \2,d0
        wcall	SetColors
        EndM

SETBUFFER Macro   ;^Buffer,^Bufferstate 
;- change buffer for current mode, esp. for framesync
	move.l	wosbase,a6

	;--- wait for current buffer to be completed
.sbwaitbuf
	move.l	b1state,a0
	move.l	(a0),a0
	cmp	#0,a0
	bne	.sbwaitbuf
	

	;-- setup next buffer
	ifeq	NARG-1 ; just one argument, set everything to default values
		lea	bufstate,a1
		move.l	a1,buf1stateptr(a6)
		move.l	a1,buf2stateptr(a6)

		move.l	\1,buf1ptr(a6)
		move.l	\1,buf2ptr(a6)

	        move.l  \1,a0	
	else
		;- copy b2/b2state to b1/b1state
		move.l	buf2ptr(a6),buf1ptr(a6)
		move.l	buf2stateptr(a6),buf1stateptr(a6)

		;- slot in new buffer at b2/b2state
		move.l	\1,buf2ptr(a6)
		move.l	\2,buf2stateptr(a6)
		move.l	\1,a0
        endc

	jsr	_WSetBuffer(a6)
        EndM

WAITBUFFER	Macro
	move.l	wosbase,a0
.wblp:
	move	#$f00,$dff180
	move.l	buf1stateptr(a0),a1	;!!! wait for c2p to complete from buffer
	move.l	(a1),a1		; dereference pointer
	tst	a1		; should really handover time-slot to c2p 
	bne	.wblp
	EndM

DISPLAY Macro
;	move.l	#1,bufstate	; 1: effect rendered, c2p pending
	move.l	b1state,a0
	move.l	#1,(a0)
	ifd	FRAMESYNC
	
.idleDisplay	
		move.l	framesDisplayed,d0
		move.l	framesRendered,d1
		cmp.l	d0,d1
		beq	.idleDisplay		; wait until c2p done
	endc

	ifnd	FRAMESYNC
	        moveq   #0,d0
	        wcall	Display
	endc

	add.l	#1,framesRendered
        EndM

DISPLAY1        Macro
;	move.l	#1,bufstate	; 1: effect rendered, c2p pending
	move.l	b1state,a0
	move.l	#1,(a0)

	ifd	FRAMESYNC
.idleDisplay1
		move.l	framesDisplayed,d0
		move.l	framesRendered,d1
		cmp.l	d0,d1
		beq	.idleDisplay1	; wait until c2p done
	endc

	ifnd	FRAMESYNC
	        moveq   #1,d0
	        wcall	Display
	endc

	add.l	#1,framesRendered

        EndM

DISPLAY2        Macro
;	move.l	#1,bufstate	; 1: effect rendered, c2p pending
	move.l	b1state,a0
	move.l	#1,(a0)

	ifd	FRAMESYNC
.idleDisplay2	
;		move	#$f00,$dff180
		move.l	framesDisplayed,d0
		move.l	framesRendered,d1
		cmp.l	d0,d1
		beq	.idleDisplay2		; wait until c2p done
	endc
	move	#0,$dff180

	ifnd	FRAMESYNC
	        moveq   #2,d0
	        wcall	Display
	endc

	add.l	#1,framesRendered
        EndM

MOUSEX  Macro
        wcall	MouseX
        EndM

MOUSEY  Macro
        wcall	MouseY
        EndM

CHECKEXIT       Macro   ;-
        wcall	CheckExit
	tst	d0
        EndM

SETEXIT Macro	;sets an Effect Exit (#1 in contrary to user-exit which is #2)
        wcall	SetExit
        EndM

CLEAREXIT       Macro
        wcall	ClearExit
        EndM

NOMODE  Macro
        wcall	NoMode
        EndM

VBIHOOK	Macro
	move.l	\1,_thisVBIptr
	endm

WAITVBL	Macro
	wcall	WaitVBL
	endm	

CLEARPLANES	Macro
	wcall	ClearPlanes
	endm

;*****************************************************************************

;-------------- Wicked Soundsystem

PLAYMOD	macro			;module (,pattern)
        move.l  \1,a0
        ifeq	NARG-2
        	move.l	\2,d0
        else
        	move.l	#-1,d0
        endc
        wcall	PlayMod
        endm

STOPMOD	macro
	wcall	StopMod
	endm

VOLUME	macro			;volume (0-255)
	move.l	\1,d0
	wcall	Volume
	endm

GETPOS	macro
	wcall	GetPos
	endm

EFFECTTRACKER	macro
	move.l	\1,a0
	wcall	EffectTracker
	endm


NEXTVBI	macro	;\1 - ptr to a routine
	move.l	\1,a0
	;wcall	NextVBI		; moved from server
	bsr	_NextVBI		; to client (old server function deprecated)
	endm


;-------------- Here comes restricted area. You should be careful.
;               They are still pretty beta and untested!


DECRUNCH	macro	;from a0 to a1 - d0=0 means error
	wcall	Decrunch
	EndM

INITWPAC	Macro	;decrunch a0 - a0=0 means error
	wcall	InitwPAC
	EndM

INITHOOK	Macro
	ifnd	INITHOOKPRESENT
INITHOOKPRESENT
	endc
_Inithook:	jmp	\1
	endm

EXITHOOK	Macro
EITHOOKPRESENT
_Exithook:	jmp	\1
	endm

EXITEFX	macro
	lea	\1,a0		; Definitions for the Effect (DEFEFX.name)
	lea	CallEfxInfo,a1	; Information about VBI and Timers
	wcall	ExitEfx
	endm

CALLEFXONCE	macro
	lea	\1,a0		; Definitions for the Effect (DEFEFX.name)
	lea	CallEfxInfo,a1	; Information about VBI and Timers
	wcall	CallEfxOnce
	endm

INITEFX	macro
	lea	\1,a0		; Definitions for the Effect (DEFEFX.name)
	lea	CallEfxInfo,a1	; Information about VBI and Timers
	wcall	InitEfx
;	beq	_Quit		; !!! changed in v5 from bne to beq
	endm


CALLEFX Macro   ;\1 - 
	lea	\1,a0		; Definitions for the Effect (DEFEFX.name)
	lea	CallEfxInfo,a1	; Information about VBI and Timers
	wcall	CallEfx
	beq	_Quit		; !!! changed in v5 from bne to beq

	move.l	d0,a2
	CHECKEXIT
	cmp	#2,d0			; User Exit requested?
	beq	_Quit	; directly quit. if you need to clenup something,
			; you have to install an Exit-routine!
	move.l	#0,_childVBIptr
	CLEAREXIT
	move.l	a2,d0
	endm

SETSCREEN	macro	;\1 - rel. x pos of the screen
			;\2 - rel. y pos
	move.l	\1,d0
	move.l	\2,d1
	wcall	SetScreen
	endm

SETSPRITES	macro
	move.l	\1,a0
	wcall	SetSprites
	endm

;est	macro
;	nop
;	moveq	#0,d0
;	bra.s	.test\@
;	moveq	#-2,d0
;
;	ifne	NARG
;.str\@	dc.b	\1,0
;	even
;	endc
;.test\@
;	endm

ERROR	macro		;\1 - ^string	!!! macro doesn't return !!!
	ifnd	NOERRORS
		ifne	NARG
			move.l	wosbase,a6
			dc.l	$41fa0006	;lea 8(pc),a0 - leave the dc.l, this is the only way to get it work on asmpro,devpac and oma assemblers 	
			jmp	_WError(a6)
			dc.b	"\1"
			ifge	NARG-2
				dc.b	10,"\2"
			endc
			ifge	NARG-3
				dc.b	10,"\3"
			endc
			ifge	NARG-4
				dc.b	10,"\4"
			endc
			ifge	NARG-5
				dc.b	10,"\5"
			endc
			dc.b	0
			even
		else
			sub.l	a0,a0
			move.l	wosbase,a6
			jmp	_WError(a6)
		endc
	else
		sub.l	a0,a0
		move.l	wosbase,a6
		jmp	_WError(a6)
	endc
	endm

	;this is almost the same, but it can be used by the server before initwos is called
SERROR	macro		;\1 - ^string	!!! macro doesn't return !!!
	ifnd	NOERRORS
		ifne	NARG
			lea	_wosbase,a6
			dc.l	$41fa0006	;lea 8(pc),a0 - leave the dc.l, this is the only way to get it work on asmpro,devpac and oma assemblers 	
			jmp	_WError(a6)
			dc.b	"\1"
			ifge	NARG-2
				dc.b	10,"\2"
			endc
			ifge	NARG-3
				dc.b	10,"\3"
			endc
			ifge	NARG-4
				dc.b	10,"\4"
			endc
			ifge	NARG-5
				dc.b	10,"\5"
			endc
			dc.b	0
			even
		else
			sub.l	a0,a0
			lea	_wosbase,a6
			jmp	_WError(a6)
		endc
	else
		sub.l	a0,a0
		lea	_wosbase,a6
		jmp	_WError(a6)
	endc
	endm



DEFEFX	Macro
\1	dc.l	\2,\3	;\1 name - \2 ^incefx (wPAC or loadfile) - \3 ticks
	dc.l	0	;will point to relocated (and decrunched) binary or 0
			;(0 after exit done)
	dc.l	0	;banknumber of relocated effect (0 after exit done)
	dc.l	0	;-1 if Init done (0 after Exit done)
	dc.l	0	;-1 if Exit done
	endm	

INCEFX	Macro
	cnop	0,4
\1	incbin	\2	;\1 name - \2 filename
	cnop	0,4
	endm
	
waittime        macro
        move.l  \1,d0
        bsr     _wait
        endm

;-------------------------- some comfortable macros for your use

PRINT	macro
	wbase
	move.l	\1,_a0(a6)
	jsr	_WPrint(a6)
	endm


push	macro
	movem.l \1,-(a7)
	endm

pull	macro
	movem.l (a7)+,\1
	endm

pushns	macro
	push	d2-d7/a2-a6
	endm

pullns	macro
	pull	d2-d7/a2-a6
	endm

call	macro			; LVOs werden gebraucht!!!
	ifeq    NARG-2		; 2 Parameter ?
		move.l \2base(pc),a6	; Dann angegebene Library
	endc			; Sonst nichts ändern
	jsr     _LVO\1(a6)
	endm


openlib Macro
        lea     \1name,a1
        ifeq    NARG-2
         move.l \2,d0           ; LibVersion...
        else
         moveq  #0,d0           ; Egol...
        endif
        move.l  4.w,a6          ; Execbase-> A6
        jsr     -552(a6)        ; Openlib -> Ergebnis in D0
        move.l  d0,a6           ; Geöffnete Library gleich benutzen...
	lea	\1base,a1
        move.l  a6,(a1)
        EndM
        
closelib        Macro
        move.l  \1base,a1   ; Libbase -> A1
	cmp	#0,a1
	beq.s	.\1skip		; Library is not open
        move.l  4.w,a6          ; Execbase-> A6
        jsr     -414(a6)        ; Closelib
	lea	\1base,a1
	move.l	#0,(a1)		; remove the baseptr
.\1skip:
        EndM


	;---------------------- new stuff 2015++
SETLINE	Macro	;\1 bitplane id (0..7), \2 line number, \3 pointer to bitplane data
	; in: a0 - bitplane id (0..7) , d0 - pointer to bitplane data , d1 - line number
	move.l	\1,a0
	move.l	\2,d1
	move.l	\3,d0
	wcall SetLine
	endm

SETCOPPER	Macro	;	in: \1 - colour index, \2 - pointer to gradient / list of 180 colours (4 bytes each, 00rrggbb)
	move.l	\1,d0
	move.l	\2,a0
	wcall SetCopper
	endm


	; from Hannibal's WinUAE Demo Toolchain (http://www.pouet.net/prod.php?which=65625)
	;to stop here in WinUAE, enter w 4 4 4 w in the debugger window (shift+f12)

WINUAEBREAKPOINT	Macro
	move.l	4.w,4.w
	endm

	endc	;of WOS_MACROS_I

