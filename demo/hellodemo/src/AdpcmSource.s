
; This file includes routines for decoding a mono IMA ADPCM stream to either
;  8 or 14bit, mono or stereo output. Decoding is done through a callback function that
;  should be called each vblank.
;
; CPU consumption:
;  22kHz 8bit mono - <1% on 68060/50
;  22kHz 14bit mono - 1% on 68060/50
;  22kHz 8bit mono - <2% on 68060/50
;  22kHz 14bit stereo - 2% on 68060/50

				rsreset
AdpcmMixState_SourceData	rs.l	1
AdpcmMixState_PredictorScale	rs.w	1
				rs.w	1
AdpcmMixState_PredictorValue	rs.l	1
AdpcmMixState_SIZEOF		rs.b	0


		section	code,code

;------------------------------------------------------------------------------
; Prepare for playing a 16bit ADPCM mono file, and output as 8bit mono
;
; in	a0	ADPCM 16bit mono file
;	d0.w	replay period

AdpcmSource_Init_16BitMonoInput_8BitMonoOutput
		lea	AdpcmSource_16BitMonoInput_8BitMonoOutput_MixState,a1
		move.l	a0,AdpcmMixState_SourceData(a1)
		clr.w	AdpcmMixState_PredictorScale(a1)
		clr.l	AdpcmMixState_PredictorValue(a1)

		move.w	d0,-(sp)
		bsr	AdpcmSource_InitTables
		move.w	(sp)+,d0

		lea	AdpcmSource_16BitMonoInput_8BitMonoOutput_MixSamples,a0
		lea	AdpcmSource_16BitMonoInput_8BitMonoOutput_MixState,a1
		moveq	#PaulaOutput_Mode_8BitMono,d1
		bsr	PaulaOutput_Init
		rts

;------------------------------------------------------------------------------
; Prepare for playing a 16bit ADPCM mono file, and output as 14bit mono
;
; in	a0	ADPCM 16bit mono file
;	d0.w	replay period

AdpcmSource_Init_16BitMonoInput_14BitMonoOutput
		lea	AdpcmSource_16BitMonoInput_14BitMonoOutput_MixState,a1
		move.l	a0,AdpcmMixState_SourceData(a1)
		clr.w	AdpcmMixState_PredictorScale(a1)
		clr.l	AdpcmMixState_PredictorValue(a1)

		move.w	d0,-(sp)
		bsr	AdpcmSource_InitTables
		move.w	(sp)+,d0

		lea	AdpcmSource_16BitMonoInput_14BitMonoOutput_MixSamples,a0
		lea	AdpcmSource_16BitMonoInput_14BitMonoOutput_MixState,a1
		moveq	#PaulaOutput_Mode_14BitMono,d1
		bsr	PaulaOutput_Init
		rts


;------------------------------------------------------------------------------
; Prepare for playing a pair of 16bit ADPCM mono files, and output as 8bit stereo
;
; in	a0	ADPCM 16bit mono file - left speaker
; 	a1	ADPCM 16bit mono file - right speaker
;	d0.w	replay period

AdpcmSource_Init_16BitStereoInput_8BitStereoOutput
		move.l	a2,-(sp)
		lea	AdpcmSource_16BitStereoInput_8BitStereoOutput_MixState+AdpcmMixState_SIZEOF*0,a2
		move.l	a0,AdpcmMixState_SourceData(a2)
		clr.w	AdpcmMixState_PredictorScale(a2)
		clr.l	AdpcmMixState_PredictorValue(a2)
		lea	AdpcmSource_16BitStereoInput_8BitStereoOutput_MixState+AdpcmMixState_SIZEOF*1,a2
		move.l	a1,AdpcmMixState_SourceData(a2)
		clr.w	AdpcmMixState_PredictorScale(a2)
		clr.l	AdpcmMixState_PredictorValue(a2)

		move.w	d0,-(sp)
		bsr	AdpcmSource_InitTables
		move.w	(sp)+,d0

		lea	AdpcmSource_16BitStereoInput_8BitStereoOutput_MixSamples,a0
		lea	AdpcmSource_16BitStereoInput_8BitStereoOutput_MixState,a1
		moveq	#PaulaOutput_Mode_8BitStereo,d1
		bsr	PaulaOutput_Init

		move.l	(sp)+,a2
		rts

;------------------------------------------------------------------------------
; Prepare for playing a pair of 16bit ADPCM mono files, and output as 14bit stereo
;
; in	a0	ADPCM 16bit mono file - left speaker
; 	a1	ADPCM 16bit mono file - right speaker
;	d0.w	replay period

AdpcmSource_Init_16BitStereoInput_14BitStereoOutput
		move.l	a2,-(sp)
		lea	AdpcmSource_16BitStereoInput_14BitStereoOutput_MixState+AdpcmMixState_SIZEOF*0,a2
		move.l	a0,AdpcmMixState_SourceData(a2)
		clr.w	AdpcmMixState_PredictorScale(a2)
		clr.l	AdpcmMixState_PredictorValue(a2)
		lea	AdpcmSource_16BitStereoInput_14BitStereoOutput_MixState+AdpcmMixState_SIZEOF*1,a2
		move.l	a1,AdpcmMixState_SourceData(a2)
		clr.w	AdpcmMixState_PredictorScale(a2)
		clr.l	AdpcmMixState_PredictorValue(a2)

		move.w	d0,-(sp)
		bsr	AdpcmSource_InitTables
		move.w	(sp)+,d0

		lea	AdpcmSource_16BitStereoInput_14BitStereoOutput_MixSamples,a0
		lea	AdpcmSource_16BitStereoInput_14BitStereoOutput_MixState,a1
		moveq	#PaulaOutput_Mode_14BitStereo,d1
		bsr	PaulaOutput_Init

		move.l	(sp)+,a2
		rts

;------------------------------------------------------------------------------
; in	d0	number of samples to mix
;	d1	current mix position
;	a0	output samples
;	a4	state

AdpcmSource_16BitMonoInput_8BitMonoOutput_MixSamples
		movem.l	d2-d7/a2-a6,-(sp)

		move.l	AdpcmMixState_SourceData(a4),a2
		move.w	AdpcmMixState_PredictorScale(a4),d2
		move.l	AdpcmMixState_PredictorValue(a4),d6
		
		move.l	a4,-(sp)
		bsr	AdpcmSource_DecodeSamples_8BitMonoOutput
		move.l	(sp)+,a4

		move.l	a2,AdpcmMixState_SourceData(a4)
		move.w	d2,AdpcmMixState_PredictorScale(a4)
		move.l	d6,AdpcmMixState_PredictorValue(a4)
		movem.l	(sp)+,d2-d7/a2-a6
		rts

;------------------------------------------------------------------------------
; in	d0	number of samples to mix
;	d1	current mix position
;	a0	output samples (hi 8bits)
;	a1	output samples (low 6bits)
;	a4	state

AdpcmSource_16BitMonoInput_14BitMonoOutput_MixSamples
		movem.l	d2-d7/a2-a6,-(sp)

		move.l	AdpcmMixState_SourceData(a4),a2
		move.w	AdpcmMixState_PredictorScale(a4),d2
		move.l	AdpcmMixState_PredictorValue(a4),d6

		move.l	a4,-(sp)
		bsr	AdpcmSource_DecodeSamples_14BitMonoOutput
		move.l	(sp)+,a4

		move.l	a2,AdpcmMixState_SourceData(a4)
		move.w	d2,AdpcmMixState_PredictorScale(a4)
		move.l	d6,AdpcmMixState_PredictorValue(a4)

		movem.l	(sp)+,d2-d7/a2-a6
		rts

;------------------------------------------------------------------------------
; in	d0	number of samples to mix
;	d1	current mix position
;	a0	output samples - left speaker (hi 8bits)
;	a2	output samples - right speaker (hi 8bits)
;	a4	state

AdpcmSource_16BitStereoInput_8BitStereoOutput_MixSamples
		movem.l	d2-d7/a2-a6,-(sp)

		move.l	a2,-(sp)

		move.l	d0,-(sp)
		move.l	a4,-(sp)

		move.l	AdpcmMixState_SourceData(a4),a2
		move.w	AdpcmMixState_PredictorScale(a4),d2
		move.l	AdpcmMixState_PredictorValue(a4),d6

		bsr	AdpcmSource_DecodeSamples_8BitMonoOutput

		move.l	(sp)+,a4
		move.l	(sp)+,d0

		move.l	a2,AdpcmMixState_SourceData(a4)
		move.w	d2,AdpcmMixState_PredictorScale(a4)
		move.l	d6,AdpcmMixState_PredictorValue(a4)

		add.l	#AdpcmMixState_SIZEOF,a4

		move.l	AdpcmMixState_SourceData(a4),a2
		move.w	AdpcmMixState_PredictorScale(a4),d2
		move.l	AdpcmMixState_PredictorValue(a4),d6

		move.l	(sp)+,a0

		move.l	a4,-(sp)
		
		bsr	AdpcmSource_DecodeSamples_8BitMonoOutput

		move.l	(sp)+,a4

		move.l	a2,AdpcmMixState_SourceData(a4)
		move.w	d2,AdpcmMixState_PredictorScale(a4)
		move.l	d6,AdpcmMixState_PredictorValue(a4)

		movem.l	(sp)+,d2-d7/a2-a6
		rts

;------------------------------------------------------------------------------
; in	d0	number of samples to mix
;	d1	current mix position
;	a0	output samples - left speaker (hi 8bits)
;	a1	output samples - left speaker (low 6bits)
;	a2	output samples - right speaker (hi 8bits)
;	a3	output samples - right speaker (low 6bits)
;	a4	state

AdpcmSource_16BitStereoInput_14BitStereoOutput_MixSamples
		movem.l	d2-d7/a2-a6,-(sp)

		move.l	a3,-(sp)
		move.l	a2,-(sp)

		move.l	d0,-(sp)
		move.l	a4,-(sp)

		move.l	AdpcmMixState_SourceData(a4),a2
		move.w	AdpcmMixState_PredictorScale(a4),d2
		move.l	AdpcmMixState_PredictorValue(a4),d6

		bsr	AdpcmSource_DecodeSamples_14BitMonoOutput

		move.l	(sp)+,a4
		move.l	(sp)+,d0

		move.l	a2,AdpcmMixState_SourceData(a4)
		move.w	d2,AdpcmMixState_PredictorScale(a4)
		move.l	d6,AdpcmMixState_PredictorValue(a4)

		add.l	#AdpcmMixState_SIZEOF,a4

		move.l	AdpcmMixState_SourceData(a4),a2
		move.w	AdpcmMixState_PredictorScale(a4),d2
		move.l	AdpcmMixState_PredictorValue(a4),d6

		move.l	(sp)+,a0
		move.l	(sp)+,a1

		move.l	a4,-(sp)
		
		bsr	AdpcmSource_DecodeSamples_14BitMonoOutput

		move.l	(sp)+,a4

		move.l	a2,AdpcmMixState_SourceData(a4)
		move.w	d2,AdpcmMixState_PredictorScale(a4)
		move.l	d6,AdpcmMixState_PredictorValue(a4)

		movem.l	(sp)+,d2-d7/a2-a6
		rts

;------------------------------------------------------------------------------

AdpcmSource_InitTables
		tst.b	AdpcmSource_TablesInitialized
		bne.s	.done
		movem.l	d2-d4,-(sp)
		lea	AdpcmSource_IndexTable,a0
		moveq	#16-1,d0
.index
		move.l	(a0),d1
		lsl.l	#6,d1
		move.l	d1,(a0)+
		dbf	d0,.index
		
		lea	AdpcmSource_StepTable+89*4,a0
		lea	AdpcmSource_StepTable+89*16*4,a1
		moveq	#89-1,d0
.index2
		move.l	-(a0),d1
		moveq	#16-1,d2
.delta
		move.l	d1,d3
		moveq	#0,d4
		btst	#2,d2
		beq.s	.nBit2
		add.l	d3,d4
.nBit2
		asr.l	#1,d3
		btst	#1,d2
		beq.s	.nBit1
		add.l	d3,d4
.nBit1
		asr.l	#1,d3
		btst	#0,d2
		beq.s	.nBit0
		add.l	d3,d4
.nBit0
		asr.l	#1,d3
		add.l	d3,d4
		btst	#3,d2
		beq.s	.nBit3
		neg.l	d4
.nBit3
		move.l	d4,-(a1)
		
		dbf	d2,.delta
		dbf	d0,.index2

		movem.l	(sp)+,d2-d4
.done		rts


;------------------------------------------------------------------------------
; in	d0.l	numsamples
;	d2.w	state part 1
;	d6.l	state part 2
;	a0	output (hi 8bit)
;	a2	input (state part 3)
; out	d2.w	state part 1
;	d6.l	state part 2
;	a2	input (state part 3)	

AdpcmSource_DecodeSamples_8BitMonoOutput
		move.l	d0,d7
		lsr.l	#2,d7

		lea	AdpcmSource_IndexTable,a3
		lea	AdpcmSource_StepTable,a6

		move.l	#-32768,a4
		move.l	#32767,a5
.sampleQuad

.sample0
		move.b	(a2)+,d0
		move.w	d0,d1
		and.w	#$00f0,d0
		and.w	#$000f,d1
		lsr.b	#2,d0
		lsl.b	#2,d1

		move.w	d2,d3
		add.w	d0,d3

		add.w	2(a3,d0.w),d2
		spl	d4
		ext.w	d4
		and.w	d4,d2
		cmp.w	#88<<6,d2
		bls.s	.indexClamp0Done
		move.w	#88<<6,d2
.indexClamp0Done

		add.l	(a6,d3.w),d6
		cmp.l	a4,d6
		bge.s	.clampMin0Done
		move.l	a4,d6
.clampMin0Done
		cmp.l	a5,d6
		ble.s	.clampMax0Done
		move.l	a5,d6
.clampMax0Done
		move.w	d6,d5

.sample1
		move.w	d2,d3
		lsl.l	#8,d5
		add.w	d1,d3

		add.w	2(a3,d1.w),d2
		spl	d4
		ext.w	d4
		and.w	d4,d2
		cmp.w	#88<<6,d2
		bls.s	.indexClamp1Done
		move.w	#88<<6,d2
.indexClamp1Done

		add.l	(a6,d3.w),d6
		cmp.l	a4,d6
		bge.s	.clampMin1Done
		move.l	a4,d6
.clampMin1Done
		cmp.l	a5,d6
		ble.s	.clampMax1Done
		move.l	a5,d6
.clampMax1Done
		move.w	d6,d5
		
.sample2
		move.b	(a2)+,d0
		move.w	d0,d1
		and.w	#$00f0,d0
		and.w	#$000f,d1
		lsr.b	#2,d0
		lsl.b	#2,d1

		move.w	d2,d3
		lsl.l	#8,d5
		add.w	d0,d3

		add.w	2(a3,d0.w),d2
		spl	d4
		ext.w	d4
		and.w	d4,d2
		cmp.w	#88<<6,d2
		bls.s	.indexClamp2Done
		move.w	#88<<6,d2
.indexClamp2Done

		add.l	(a6,d3.w),d6
		cmp.l	a4,d6
		bge.s	.clampMin2Done
		move.l	a4,d6
.clampMin2Done
		cmp.l	a5,d6
		ble.s	.clampMax2Done
		move.l	a5,d6
.clampMax2Done
		move.w	d6,d5

.sample3
		move.w	d2,d3
		add.w	d1,d3

		add.w	2(a3,d1.w),d2
		spl	d4
		ext.w	d4
		and.w	d4,d2
		cmp.w	#88<<6,d2
		bls.s	.indexClamp3Done
		move.w	#88<<6,d2
.indexClamp3Done

		add.l	(a6,d3.w),d6
		cmp.l	a4,d6
		bge.s	.clampMin3Done
		move.l	a4,d6
.clampMin3Done
		cmp.l	a5,d6
		ble.s	.clampMax3Done
		move.l	a5,d6
.clampMax3Done
		rol.w	#8,d6
		move.b	d6,d5
		rol.w	#8,d6

		move.l	d5,(a0)+

		subq.l	#1,d7
		bne	.sampleQuad

		rts

;------------------------------------------------------------------------------
; in	d0.l	numsamples
;	d2.w	state part 1
;	d6.l	state part 2
;	a0	output (hi 8bit)
;	a1	output (low 6bit)
;	a2	input (state part 3)
; out	d2.w	state part 1
;	d6.l	state part 2
;	a2	input (state part 3)	

AdpcmSource_DecodeSamples_14BitMonoOutput
		move.l	d0,d7
		lsr.l	#2,d7

		lea	AdpcmSource_IndexTable,a3
		lea	AdpcmSource_StepTable,a6

		move.l	#-32768,a4
		move.l	#32767,a5
.sampleQuad

.sample0
		move.b	(a2)+,d0
		move.w	d0,d1
		and.w	#$00f0,d0
		and.w	#$000f,d1
		lsr.b	#2,d0
		lsl.b	#2,d1

		move.w	d2,d3
		add.w	d0,d3

		add.w	2(a3,d0.w),d2
		spl	d4
		ext.w	d4
		and.w	d4,d2
		cmp.w	#88<<6,d2
		bls.s	.indexClamp0Done
		move.w	#88<<6,d2
.indexClamp0Done

		add.l	(a6,d3.w),d6
		cmp.l	a4,d6
		bge.s	.clampMin0Done
		move.l	a4,d6
.clampMin0Done
		cmp.l	a5,d6
		ble.s	.clampMax0Done
		move.l	a5,d6
.clampMax0Done
		move.w	d6,d0

.sample1
		move.w	d2,d3
		lsl.l	#8,d0
		add.w	d1,d3
		lsl.l	#8,d0

		add.w	2(a3,d1.w),d2
		spl	d4
		ext.w	d4
		and.w	d4,d2
		cmp.w	#88<<6,d2
		bls.s	.indexClamp1Done
		move.w	#88<<6,d2
.indexClamp1Done

		add.l	(a6,d3.w),d6
		cmp.l	a4,d6
		bge.s	.clampMin1Done
		move.l	a4,d6
.clampMin1Done
		cmp.l	a5,d6
		ble.s	.clampMax1Done
		move.l	a5,d6
.clampMax1Done
		move.w	d6,d5
		
.sample2
		move.b	(a2)+,d0
		move.w	d0,d1
		and.w	#$00f0,d0
		and.w	#$000f,d1
		lsr.b	#2,d0
		lsl.b	#2,d1

		move.w	d2,d3
		lsl.l	#8,d5
		add.w	d0,d3
		lsl.l	#8,d5

		add.w	2(a3,d0.w),d2
		spl	d4
		ext.w	d4
		and.w	d4,d2
		cmp.w	#88<<6,d2
		bls.s	.indexClamp2Done
		move.w	#88<<6,d2
.indexClamp2Done

		add.l	(a6,d3.w),d6
		cmp.l	a4,d6
		bge.s	.clampMin2Done
		move.l	a4,d6
.clampMin2Done
		cmp.l	a5,d6
		ble.s	.clampMax2Done
		move.l	a5,d6
.clampMax2Done
		move.w	d6,d0

.sample3
		move.w	d2,d3
		add.w	d1,d3

		add.w	2(a3,d1.w),d2
		spl	d4
		ext.w	d4
		and.w	d4,d2
		cmp.w	#88<<6,d2
		bls.s	.indexClamp3Done
		move.w	#88<<6,d2
.indexClamp3Done

		add.l	(a6,d3.w),d6
		cmp.l	a4,d6
		bge.s	.clampMin3Done
		move.l	a4,d6
.clampMin3Done
		cmp.l	a5,d6
		ble.s	.clampMax3Done
		move.l	a5,d6
.clampMax3Done
		move.w	d6,d5

		move.l	d5,d1
		lsr.l	#8,d1
		eor.l	d0,d1
		and.l	#$00ff00ff,d1
		eor.l	d1,d0

		move.l	d0,(a0)+
		lsl.l	#8,d1
		or.l	d1,d5

		lsr.l	#2,d5
		and.l	#$3f3f3f3f,d5

		move.l	d5,(a1)+

		subq.l	#1,d7
		bne	.sampleQuad

		rts

		section	data,data

AdpcmSource_TablesInitialized
		dc.b	0
		ds.b	3
		
AdpcmSource_IndexTable
		dc.l	-1, -1, -1, -1, 2, 4, 6, 8
		dc.l	-1, -1, -1, -1, 2, 4, 6, 8

AdpcmSource_StepTable
		dc.l	7, 8, 9, 10, 11, 12, 13, 14, 16, 17
		dc.l	19, 21, 23, 25, 28, 31, 34, 37, 41, 45
		dc.l	50, 55, 60, 66, 73, 80, 88, 97, 107, 118
		dc.l	130, 143, 157, 173, 190, 209, 230, 253, 279, 307
		dc.l	337, 371, 408, 449, 494, 544, 598, 658, 724, 796
		dc.l	876, 963, 1060, 1166, 1282, 1411, 1552, 1707, 1878, 2066
		dc.l	2272, 2499, 2749, 3024, 3327, 3660, 4026, 4428, 4871, 5358
		dc.l	5894, 6484, 7132, 7845, 8630, 9493, 10442, 11487, 12635, 13899
		dc.l	15289, 16818, 18500, 20350, 22385, 24623, 27086, 29794, 32767
		ds.l	89*15
		
		section	bss,bss

AdpcmSource_16BitMonoInput_8BitMonoOutput_MixState
		ds.b	AdpcmMixState_SIZEOF

AdpcmSource_16BitMonoInput_14BitMonoOutput_MixState
		ds.b	AdpcmMixState_SIZEOF

AdpcmSource_16BitStereoInput_8BitStereoOutput_MixState
		ds.b	AdpcmMixState_SIZEOF*2

AdpcmSource_16BitStereoInput_14BitStereoOutput_MixState
		ds.b	AdpcmMixState_SIZEOF*2
