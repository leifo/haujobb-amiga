; demo-side assembly stuff removed from wickedlink, so that it can be assembled with vasm and included in PC-makefile
; 12.10.15 (last train)
; 05.04.17 (rapture), cleanup
; 18.10.17 (beam riders sound)

	; from Hannibal's WinUAE Demo Toolchain (http://www.pouet.net/prod.php?which=65625)
	; to stop here in WinUAE, enter w 4 4 4 w in the debugger window (shift+f12)
WINUAEBREAKPOINT	Macro
	move.l	4.w,4.w
	endm

	include hardware/custom.i

	MC68020
	xdef _wosInitAssemblyBridge
	xdef _wosReleaseAssemblyBridge
	xdef _wosBridgeSetVBI
	xdef _wosCheckCPUFPU
	xdef _wosCheckAGA
	xdef _wosGetPlayPos
	xdef _oddeven

	xref	_customVBI
	xref  _updateDemo
	xref  _gfxbase

	; 1/50 s int timer
	xdef	_g_vbitimer
	;xdef	_g_renderedFrames

	; from c
	xref	_g_currentPal

	; Kalms replay
	xref PaulaOutput_Start
	xref PaulaOutput_ShutDown
	xref PaulaOutput_VertBCallback
	xref PaulaOutput_PlayPosition
   
	;xref WavSource_Init_16BitMonoInput_14BitMonoOutput
	;xref AdpcmSource_Init_16BitMonoInput_14BitMonoOutput
	;xref WavSource_Init_16BitStereoInput_14BitStereoOutput
	xref AdpcmSource_Init_16BitStereoInput_14BitStereoOutput


ADPCM		; uncheck to play ADPCM, check to play WAV
STEREO	; use the stereo instead of the mono version
;HQ28600

	

	ifnd HQ28600
ReplayPeriod = 161		; 161 means 22030.40 Hz
	else
ReplayPeriod = 124		; 124 means 28603.99 HZ
	endc

	section code,code
; called directly before mainDemo()
_wosInitAssemblyBridge:
	movem.l	d0-a6,-(a7)

	;--- init music
	;bra   skipInitMusic	

	ifd	ADPCM
		;--- ADPCM init
		ifnd	STEREO
			lea	AdpcmFile,a0
			move.w	#ReplayPeriod,d0
			jsr    AdpcmSource_Init_16BitMonoInput_14BitMonoOutput
		else
		   move.l	_AdpcmFileLeft,a0
			move.l	_AdpcmFileRight,a1
			move.w	#ReplayPeriod,d0
			jsr	AdpcmSource_Init_16BitStereoInput_14BitStereoOutput
		endc
	else
		;--- WAV init
		ifnd	STEREO
			lea	WavFile,a0
			move.w	#ReplayPeriod,d0
			jsr	WavSource_Init_16BitMonoInput_14BitMonoOutput
		else
			lea	WavFileLeft,a0
			lea	WavFileRight,a1
			move.w	#ReplayPeriod,d0
			jsr	WavSource_Init_16BitStereoInput_14BitStereoOutput
		endc

	endc

	;--- ADPCM/WAV start
	jsr    PaulaOutput_Start
skipInitMusic:

	;--- init vertical blanc interrupt, i.e. for the 50 Hz timer
	lea	vbi,a0
	jsr	_wosBridgeSetVBI

	movem.l	(a7)+,d0-a6
	rts
	
; called directly after mainDemo()
_wosReleaseAssemblyBridge:
	movem.l	d0-a6,-(a7)
	
	;--- ADPCM/WAV stop
	move.l	#0,a0
	jsr	_wosBridgeSetVBI
	jsr	PaulaOutput_ShutDown
	
	movem.l	(a7)+,d0-a6
	rts
		
_wosGetPlayPos:
	move.l	PaulaOutput_PlayPosition,d0
	rts

; check for AGA chipset
; returns 1 if present

; http://eab.abime.net/showthread.php?t=72300
_wosCheckAGA:
   WINUAEBREAKPOINT
	move.l   d2,-(a7)
	move.w $dff07c,d0
	moveq #31-1,d2
	and.w #$ff,d0
.check_loop:      
	move.w $dff07C,d1
	and.w #$ff,d1
	cmp.b d0,d1
	bne.b .not_AGA
	dbf d2,.check_loop
	or.b #$f0,d0
	cmp.b #$f8,d0
	bne.b .not_AGA
	move.l   (a7)+,d2
	moveq #1,d0
	rts
.not_AGA:
	move.l   (a7)+,d2
	moveq #0,d0
	rts

; check for 68020+ and FPU present
; returns 0 if present
_wosCheckCPUFPU:
	move.l   4.w,a0
	move.w	296(a0),d0
	and	#%10001111,d0		; fpu bits rausmaskieren
	rol	#1,d0           
	rol.b	#3,d0			; cpubits als 5 bit muster
	ror	#4,d0			; in d0 speichern

	; check for 68020 minimum
	cmp	#3,d0
	bge	.cpuok
	moveq.l	#-1,d0
	rts

.cpuok
	; check for FPU
	move.l  4.w,a0
	move.w	296(a0),d0
	and	#%01110000,d0
	tst	d0
	bne.s	.fpuok
	moveq.l	#-1,d0
	rts

.fpuok:
	moveq.l   #0,d0    ; here we have 68020+ and FPU (68881/68882/68040/68060/68080?)
	rts

 
;----------------------------------------------------	

vbi:
	movem.l	d0-a6,-(a7)
	move.l   vbitimer(pc),d0
	addq.l	#1,d0
	move.l   d0,vbitimer
	and.l    #1,d0
	move.l   d0,_oddeven
   
	jsr		PaulaOutput_VertBCallback  ;player
     
 	;--- custom VBI code
	move.l	_customVBI,a0
	cmp.l	#0,a0		;customVBI requested?
	beq		.n1
	jsr		(a0)
.n1:

	;--- C VBI code
	move.l	_cVBI,a0
	cmp.l	#0,a0		;cVBI requested?
	beq		.n2
	jsr		(a0)
.n2:
   
	;-- updateDemo
	jsr   _updateDemo   
			
	;move  #$333,$dff180
	movem.l	(a7)+,d0-a6
	rts

	
_g_vbitimer
vbitimer	dc.l	0	; incremented by 1 every tick

_oddeven
oddeven	dc.l	0	; toggles 0/1 every frame

;----------------------------------------------------
	;--- replayer
	include PaulaOutput.s
	include AdpcmSource.s
