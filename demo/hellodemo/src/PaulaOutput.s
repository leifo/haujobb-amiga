
; Audio output driver for Paula
; Supports 8 or 14bit output, mono or stereo
;
; The screenmode must be standard PAL-interlace or PAL-noninterlace
;  (no NTSC, no DBLPAL etc) - otherwise the computation of "how far has the
;  audio hardware played" doesn't work

PaulaOutput_MixAheadFrames	= 6		; Number of frames which the mixer should mix ahead
; default: 2, did not work with Beam Riders on 060 machines of Slummy, Tfardy, Bifat
; 3..6 worked on Tfardys machins
; 7 bugged on Nonames machine


PaulaOutput_AudioBufferSizeLog2	= 14	; kalms: 12, but we use bigger buffers to avoid sound bugs
PaulaOutput_AudioBufferSize	= (1<<PaulaOutput_AudioBufferSizeLog2)

PaulaOutput_CyclesPerLine_PAL		= 227
PaulaOutput_LinesPerShortFrame_PAL	= 312

ciaa = $bfe001


PaulaOutput_Mode_8BitMono = 0
PaulaOutput_Mode_14BitMono = 1
PaulaOutput_Mode_8BitStereo = 2
PaulaOutput_Mode_14BitStereo = 3

PaulaOutput_Mode_14Bit_BIT = 0
PaulaOutput_Mode_Stereo_BIT = 1



		include	hardware/custom.i
		include	hardware/dmabits.i
		include	hardware/intbits.i
		include	hardware/cia.i


		section	code,code

;------------------------------------------------------------------------------
; Silence & setup audio hardware 
;
; in	a0	mix routine
; 	a1	mix state
; 	d0.w	replay period
; 	d1	mode (PaulaOutput_Mode_*)

PaulaOutput_Init
		move.l	a0,PaulaOutput_MixRoutine
		move.l	a1,PaulaOutput_MixState
		move.w	d0,PaulaOutput_ReplayPeriod
		move.b	d1,PaulaOutput_Mode
		
		sf	PaulaOutput_MixActive

		bsr	PaulaOutput_InitAudioReplay
		bsr.s	PaulaOutput_SetupAudioHardware
		bsr	PaulaOutput_Mix
		rts

;------------------------------------------------------------------------------
; Begin playback

PaulaOutput_Start
		st	PaulaOutput_MixActive
		bra	PaulaOutput_StartAudioHardware

;------------------------------------------------------------------------------
; Stop playback & silence audio hardware

PaulaOutput_ShutDown
		sf	PaulaOutput_MixActive
		bra	PaulaOutput_KillAudioHardware

;------------------------------------------------------------------------------
; VertB callback - call this routine every vblank to drive the audio mixer

PaulaOutput_VertBCallback
		tst.b	PaulaOutput_MixActive
		beq.s	.nMix
		move.l	d3,-(sp)
		move.l	d2,-(sp)

		move.l	PaulaOutput_PlayPosition,d0
		move.l	PaulaOutput_PlayPosition+4,d1

		move.l	PaulaOutput_SamplesPerShortFrame,d2	; Advance sample position by 1 short frame
		move.l	PaulaOutput_SamplesPerShortFrame+4,d3
		add.l	d3,d1
		addx.l	d2,d0

		move.w	vposr+$dff000,d2			; Is this a long frame?
		and.w	#$8000,d2
		beq.s	.shortFrame

		move.l	PaulaOutput_SamplesPerLine,d2		; Advance sample position by 1 extra scanline
		move.l	PaulaOutput_SamplesPerLine+4,d3
		add.l	d3,d1
		addx.l	d2,d0
.shortFrame

		move.l	d0,PaulaOutput_PlayPosition
		move.l	d1,PaulaOutput_PlayPosition+4

		bsr	PaulaOutput_Mix
		
		move.l	(sp)+,d2
		move.l	(sp)+,d3
.nMix
		rts

;------------------------------------------------------------------------------

PaulaOutput_SetupAudioHardware

		movem.l	d2-d3/a2-a3/a5,-(sp)
		move.l	#$dff000,a5

; Mute audio

		moveq	#0,d0
		move.w	d0,aud0+ac_vol(a5)
		move.w	d0,aud1+ac_vol(a5)
		move.w	d0,aud2+ac_vol(a5)
		move.w	d0,aud3+ac_vol(a5)

; Disable lowpass filter
	
		or.b	#CIAF_LED,ciaa+ciapra

; Ensure sound channels are not set to modulate each other

		move.w	#$ff,adkcon(a5)

; Set audio to play extremely quickly from an empty sample buffer

		lea	PaulaOutput_ZeroAudioSample,a0
		move.l	a0,aud0+ac_ptr(a5)
		move.l	a0,aud1+ac_ptr(a5)
		move.l	a0,aud2+ac_ptr(a5)
		move.l	a0,aud3+ac_ptr(a5)

		moveq	#2,d0
		move.w	d0,aud0+ac_len(a5)
		move.w	d0,aud1+ac_len(a5)
		move.w	d0,aud2+ac_len(a5)
		move.w	d0,aud3+ac_len(a5)

		moveq	#124,d0
		move.w	d0,aud0+ac_per(a5)
		move.w	d0,aud1+ac_per(a5)
		move.w	d0,aud2+ac_per(a5)
		move.w	d0,aud3+ac_per(a5)

; Enable audio DMA

		move.w	#DMAF_SETCLR|DMAF_AUD0|DMAF_AUD1|DMAF_AUD2|DMAF_AUD3,dmacon(a5)

; Wait for the audio change to take effect. this is not the
; world's most robust method to do so but it will work reasonably well.

		move.l	#3*1000*1000/50,d1
.wait
		move.b	$bfe001,d0	
		subq.l	#1,d1
		bne.s	.wait

; Disable audio DMA

		move.w	#DMAF_AUD0|DMAF_AUD1|DMAF_AUD2|DMAF_AUD3,dmacon(a5)

; Setup new audio buffers

; Channels 0123 go to LRRL speakers

		lea	PaulaOutput_AudioChipBuffers,a0
		move.l	a0,a1
		move.l	a0,a2
		move.l	a0,a3
		moveq	#64,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3

		btst	#PaulaOutput_Mode_14Bit_BIT,PaulaOutput_Mode
		beq.s	.output8Bit
		moveq	#1,d2					; if 14bit, let channels 2&3 send the low bits
		moveq	#1,d3
		add.l	#PaulaOutput_AudioBufferSize,a2
		add.l	#PaulaOutput_AudioBufferSize,a3
.output8Bit

		btst	#PaulaOutput_Mode_Stereo_BIT,PaulaOutput_Mode
		beq.s	.outputMono
		add.l	#PaulaOutput_AudioBufferSize*2,a1	; if stereo, let channels 1&2 play a separate sound source
		add.l	#PaulaOutput_AudioBufferSize*2,a2
.outputMono

		move.w	d0,aud0+ac_vol(a5)
		move.w	PaulaOutput_ReplayPeriod,aud0+ac_per(a5)
		move.w	#PaulaOutput_AudioBufferSize/2,aud0+ac_len(a5)
		move.l	a0,aud0+ac_ptr(a5)

		move.w	d1,aud1+ac_vol(a5)
		move.w	PaulaOutput_ReplayPeriod,aud1+ac_per(a5)
		move.w	#PaulaOutput_AudioBufferSize/2,aud1+ac_len(a5)
		move.l	a1,aud1+ac_ptr(a5)

		move.w	d2,aud2+ac_vol(a5)
		move.w	PaulaOutput_ReplayPeriod,aud2+ac_per(a5)
		move.w	#PaulaOutput_AudioBufferSize/2,aud2+ac_len(a5)
		move.l	a2,aud2+ac_ptr(a5)

		move.w	d3,aud3+ac_vol(a5)
		move.w	PaulaOutput_ReplayPeriod,aud3+ac_per(a5)
		move.w	#PaulaOutput_AudioBufferSize/2,aud3+ac_len(a5)
		move.l	a3,aud3+ac_ptr(a5)

		movem.l	(sp)+,d2-d3/a2-a3/a5
		rts

;------------------------------------------------------------------------------

PaulaOutput_StartAudioHardware

		move.l	a5,-(sp)
		move.l	#$dff000,a5

; Enable audio DMA

		move.w	#DMAF_SETCLR|DMAF_AUD0|DMAF_AUD1|DMAF_AUD2|DMAF_AUD3,dmacon(a5)

		move.l	(sp)+,a5
		rts

;------------------------------------------------------------------------------

PaulaOutput_KillAudioHardware

		move.l	a5,-(sp)
		move.l	#$dff000,a5

; Disable audio DMA

		move.w	#DMAF_AUD0|DMAF_AUD1|DMAF_AUD2|DMAF_AUD3,dmacon(a5)

; Silence all channels

		moveq	#0,d0
		move.w	d0,aud0+ac_vol(a5)
		move.w	d0,aud1+ac_vol(a5)
		move.w	d0,aud2+ac_vol(a5)
		move.w	d0,aud3+ac_vol(a5)

		move.l	(sp)+,a5
		rts

;------------------------------------------------------------------------------

PaulaOutput_InitAudioReplay

; Calculate number of samples played per line & per frame, in 32.32 fixed point

		move.l	#PaulaOutput_CyclesPerLine_PAL,d1
		moveq	#0,d2
		divu.w	d0,d1
		clr.w	PaulaOutput_SamplesPerLine
		move.w	d1,PaulaOutput_SamplesPerLine+2
		clr.w	d1
		divu.w	d0,d1
		move.w	d1,PaulaOutput_SamplesPerLine+4
		clr.w	d1
		divu.w	d0,d1
		move.w	d1,PaulaOutput_SamplesPerLine+6

		mulu.w	#PaulaOutput_LinesPerShortFrame_PAL,d1
		move.w	d1,PaulaOutput_SamplesPerShortFrame+6
		clr.w	d1
		swap	d1
		move.w	PaulaOutput_SamplesPerLine+4,d0
		mulu.w	#PaulaOutput_LinesPerShortFrame_PAL,d0
		add.l	d1,d0
		move.w	d0,PaulaOutput_SamplesPerShortFrame+4
		clr.w	d0
		swap	d0
		move.w	PaulaOutput_SamplesPerLine+2,d1
		mulu.w	#PaulaOutput_LinesPerShortFrame_PAL,d1
		add.l	d0,d1
		move.l	d1,PaulaOutput_SamplesPerShortFrame

		
		clr.l	PaulaOutput_PlayPosition
		clr.l	PaulaOutput_PlayPosition+4
		clr.l	PaulaOutput_MixPosition
		rts

;------------------------------------------------------------------------------

PaulaOutput_Mix

		movem.l	d2/a2-a5,-(sp)
		move.l	PaulaOutput_PlayPosition,d0
		move.l	PaulaOutput_MixPosition,d1
		move.l	PaulaOutput_SamplesPerShortFrame,d2
		muls.l	#PaulaOutput_MixAheadFrames,d2
		add.l	d2,d0

		add.l	#$f,d0				; Round up to the next higher multiple of 16 samples
		and.b	#$f0,d0

		cmp.l	d0,d1
		bge.s	.noMix

.mixSampleRun

		move.l	d1,d2
		add.l	#PaulaOutput_AudioBufferSize,d2
		and.l	#-PaulaOutput_AudioBufferSize,d2
		cmp.l	d0,d2
		blo.s	.clampAgainstBufferEnd
		move.l	d0,d2
.clampAgainstBufferEnd

		sub.l	d1,d2

		movem.l	d0-d2,-(sp)

		move.l	d1,d0
		and.l	#PaulaOutput_AudioBufferSize-1,d0
		lea	PaulaOutput_AudioChipBuffers,a0
		add.l	d0,a0
		move.l	d2,d0
		move.l	a0,a1
		move.l	a1,a2
		move.l	a1,a3
		move.l	PaulaOutput_MixRoutine,a5
		add.l	#PaulaOutput_AudioBufferSize,a1
		add.l	#PaulaOutput_AudioBufferSize*2,a2
		add.l	#PaulaOutput_AudioBufferSize*3,a3
		move.l	PaulaOutput_MixState,a4
		jsr	(a5)

		movem.l	(sp)+,d0-d2

		add.l	d2,d1

		cmp.l	d0,d1
		blt.s	.mixSampleRun

		move.l	d1,PaulaOutput_MixPosition
.noMix
		movem.l	(sp)+,d2/a2-a5
		rts

	
		section	bss,bss

PaulaOutput_ReplayPeriod	ds.w	1
PaulaOutput_MixActive		ds.b	1
PaulaOutput_Mode		ds.b	1

PaulaOutput_SamplesPerLine	ds.l	2
PaulaOutput_SamplesPerShortFrame ds.l	2
PaulaOutput_PlayPosition	ds.l	2
PaulaOutput_MixPosition		ds.l	1
PaulaOutput_MixRoutine		ds.l	1
PaulaOutput_MixState		ds.l	1

		section	data_c,data_c

PaulaOutput_ZeroAudioSample
		dc.b	0,0,0,0

		section	bss_c,bss_c

PaulaOutput_AudioChipBuffers
		ds.b	PaulaOutput_AudioBufferSize*4
