 	include	wos_defines.i

; modified on 20.11.16 with saturation code
; as of ada.untergrund.net/?p=boardthread&id=469

; stripped down to 5 bpls with saturation for OCS use on 03.12.17

;SATURATE.kalms	macro	; /1 register to saturate, /2 temp register
;	move.l	\1,\2		; result ist in range 0..$7f, make temp copy
;	
;	and.l	#$40404040,\2	; isolate overflow bits
;				; $00 = no overflow, $40 = overflow
;	
;	lsr.l	#6,\2		; move overflow bits to bottom of each byte
;				; $00 = no overflow, $01 = overflow
;	
;	eor.l	#$81818181,\2	; set stop bits and flip overflow bits
;				; $81 = no overflow, $80 = overflow	
;	sub.l	#$01010101,\2	; convert overflow bits to bitmasks
;				; $80 = no overflow, $7f = overflow
;
;	or.l	\2,\1		; saturate components which have overflowed
;
;	and.l	#$3f3f3f3f,\1	; optional: ensure result is in 0..$3f range
;
;	endm

SATURATE	macro	; /1 register to saturate, /2 temp1, /3 temp2
	;\1 is c
	;\2 is mask
;	nop
	move.l	\1,\2		; result ist in range 0..$7f, make temp copy

	; build mask	
	lsr.l	#6,\2	
	and.l	#$03030303,\2
	not.l	\2
	add.l	#$40404041,\2
	
	; ab hier müsste es okay sein

	; c or mask
	or.l	\2,\1

	; and
	lsr.l	#1,\1		; shift from 6 to 5 bits
	and.l	#$3f3f3f3f,\1

	endm

; hellfire: c = (c or mask) and $3f3f3f3f)

;           o = c & $c0c0c0c0

;        mask = o - (o >> 6)


s:
	bra	c2p1x1_6_c5_init	;Init (Offset 0)
	bra	c2p1x1_6_c5		;Main (Offset 4)
	rts				;Exit (Offset 8)
	rts
	rts				;QBlit (Offset 12) 
	rts

;				modulo	max res	fscreen	compu
; c2p1x1_6_c5			no	320x256?  no	030

	IFND	BPLX
BPLX	EQU	320
	ENDC
	IFND	BPLY
BPLY	EQU	180
	ENDC
	IFND	BPLSIZE
BPLSIZE	EQU	BPLX*BPLY/8
	ENDC
	IFND	CHUNKYXMAX
CHUNKYXMAX EQU	BPLX
	ENDC
	IFND	CHUNKYYMAX
CHUNKYYMAX EQU	BPLY
	ENDC

;	section	c2p,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	(bplsize) [bytes] -- offset between one row in one bpl and the next bpl

c2p1x1_6_c5_init
	movem.l	d2-d3,-(sp)
	lea	c2p_datanew(pc),a0
	andi.l	#$ffff,d0
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p_scroffs-c2p_data(a0)
	mulu.w	d0,d1
	move.l	d1,c2p_pixels-c2p_data(a0)
	movem.l	(sp)+,d2-d3
	rts

; a0	c2pscreen
; a1	bitplanes

c2p1x1_6_c5
;	add.l	#mode11size*2,a1		;first 2 planes are 18bit mask planes
	
	move.w	#.x1end-.x1,d0
	move.w	#.x2end-.x2,d0

	movem.l	d2-d7/a2-a6,-(sp)

	bsr	c2p_copyinitblock

	lea	c2p_data(pc),a2

	;move.l	#$33333333,a6

	add.w	#BPLSIZE,a1
	add.l	c2p_scroffs-c2p_data(a2),a1
	lea	c2p_tempbuf(pc),a3

	move.l	c2p_pixels-c2p_data(a2),a2
	add.l	a0,a2
	cmp.l	a0,a2
	beq	.none

	move.l	a1,-(sp)


	move.l	(a0)+,d1
			SATURATE d1,d6
	
	move.l	(a0)+,d5
			SATURATE d5,d6
	
	move.l	(a0)+,d0
			SATURATE d0,d6

	move.l	(a0)+,d6
			SATURATE d6,d4
	

	move.l	#$0f0f0f0f,d4		; Swap 4x1, part 1
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d4,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d5

	move.l	d6,d7
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d6

	move.l	(a0)+,d3
			SATURATE d3,d7
	
	move.l	(a0)+,d2
			SATURATE d2,d7

	move.l	d2,d7			; Swap 4x1, part 2
	lsr.l	#4,d7
	eor.l	d3,d7
	and.l	d4,d7
	eor.l	d7,d3
	lsl.l	#4,d7
	eor.l	d7,d2

	move.w	d3,d7			; Swap 16x4, part 1
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	lsl.l	#2,d1			; Swap/Merge 2x4, part 1
	or.l	d1,d3
	move.l	d3,(a3)+

	move.l	(a0)+,d1
			SATURATE d1,d7
	
	move.l	(a0)+,d3
			SATURATE d3,d7

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d4,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3

	move.w	d1,d7			; Swap 16x4, part 2
	move.w	d0,d1
	swap	d1
	move.w	d1,d0
	move.w	d7,d1

	lsl.l	#2,d0			; Swap/Merge 2x4, part 2
	or.l	d0,d1
	move.l	d1,(a3)+

	bra.w	.start1
.x1
	move.l	(a0)+,d1
			SATURATE d1,d6
	
	move.l	(a0)+,d5
			SATURATE d5,d6
	
	move.l	(a0)+,d0
			SATURATE d0,d6
	
	move.l	(a0)+,d6
			SATURATE d6,d4

	move.l	d7,BPLSIZE(a1)	;!!!

	move.l	#$0f0f0f0f,d4		; Swap 4x1, part 1
	move.l	d5,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d4,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d5

	move.l	d6,d7
	lsr.l	#4,d7
	eor.l	d0,d7
	and.l	d4,d7
	eor.l	d7,d0
	lsl.l	#4,d7
	eor.l	d7,d6

	move.l	(a0)+,d3
			SATURATE d3,d7
	
	move.l	(a0)+,d2
			SATURATE d2,d7

	move.l	a4,(a1)+	;!!!

	move.l	d2,d7			; Swap 4x1, part 2
	lsr.l	#4,d7
	eor.l	d3,d7
	and.l	d4,d7
	eor.l	d7,d3
	lsl.l	#4,d7
	eor.l	d7,d2

	move.w	d3,d7			; Swap 16x4, part 1
	move.w	d1,d3
	swap	d3
	move.w	d3,d1
	move.w	d7,d3

	lsl.l	#2,d1			; Swap/Merge 2x4, part 1
	or.l	d1,d3
	move.l	d3,(a3)+

	move.l	(a0)+,d1
			SATURATE d1,d7
	
	move.l	(a0)+,d3
			SATURATE d3,d7

	move.l	a5,-BPLSIZE-4(a1)  ;!!!

	move.l	d3,d7
	lsr.l	#4,d7
	eor.l	d1,d7
	and.l	d4,d7
	eor.l	d7,d1
	lsl.l	#4,d7
	eor.l	d7,d3

	move.w	d1,d7			; Swap 16x4, part 2
	move.w	d0,d1
	swap	d1
	move.w	d1,d0
	move.w	d7,d1

	lsl.l	#2,d0			; Swap/Merge 2x4, part 2
	or.l	d0,d1
	move.l	d1,(a3)+

.start1
	move.w	d2,d7			; Swap 16x4, part 3 & 4
	move.w	d5,d2
	swap	d2
	move.w	d2,d5
	move.w	d7,d2

	move.w	d3,d7
	move.w	d6,d3
	swap	d3
	move.w	d3,d6
	move.w	d7,d3

	;move.l	a6,d0
	move.l	#$33333333,d0

	move.l	d2,d7			; Swap/Merge 2x4, part 3 & 4
	lsr.l	#2,d7
	eor.l	d5,d7
	and.l	d0,d7
	eor.l	d7,d5
	lsl.l	#2,d7
	eor.l	d7,d2

	move.l	d3,d7
	lsr.l	#2,d7
	eor.l	d6,d7
	and.l	d0,d7
	eor.l	d7,d6
	lsl.l	#2,d7
	eor.l	d7,d3

	move.l	#$00ff00ff,d4

	move.l	d6,d7			; Swap 8x2, part 1
	lsr.l	#8,d7
	eor.l	d5,d7
	and.l	d4,d7
	eor.l	d7,d5
	lsl.l	#8,d7
	eor.l	d7,d6

	move.l	#$55555555,d1

	move.l	d6,d7			; Swap 1x2, part 1
	lsr.l	#1,d7	;!
	eor.l	d5,d7
	and.l	d1,d7
	eor.l	d7,d5
	move.l	d5,BPLSIZE*2(a1) ;!!!
	add.l	d7,d7
	eor.l	d6,d7

	move.l	d3,d5			; Swap 8x2, part 2
	lsr.l	#8,d5
	eor.l	d2,d5
	and.l	d4,d5
	eor.l	d5,d2
	lsl.l	#8,d5
	eor.l	d5,d3

	move.l	d3,d5			; Swap 1x2, part 2
	lsr.l	#1,d5	;!
	eor.l	d2,d5
	and.l	d1,d5
	eor.l	d5,d2
	add.l	d5,d5
	eor.l	d5,d3

	move.l	d2,a4
	move.l	d3,a5

	cmpa.l	a0,a2
	bne	.x1
.x1end
	move.l	d7,BPLSIZE(a1)  ;!!!	might be unused, but not inner-loop
	move.l	a4,(a1)+	;!!!    ditto
	move.l	a5,-BPLSIZE-4(a1) ;!!!  ditto

	move.l	(sp)+,a1
	add.l	#BPLSIZE*3,a1

	move.l	#$00ff00ff,d4
	move.l	#$aaaaaaaa,d5

	lea	c2p_tempbuf(pc),a0
	move.l	c2p_pixels(pc),d0
	lsr.l	#2,d0
	lea	(a0,d0.l),a2

	move.l	(a0)+,d0
;			SATURATE d0,d3
	
	move.l	(a0)+,d1
;			SATURATE d1,d3

	move.l	d1,d3			; Swap 8x2
	lsr.l	#8,d3
	eor.l	d0,d3
	and.l	d4,d3
	eor.l	d3,d0
	lsl.l	#8,d3
	eor.l	d1,d3

	move.l	d0,d2			; Swap 1x2
	add.l	d2,d2
	eor.l	d3,d2
	and.l	d5,d2
	eor.l	d2,d3
	lsr.l	#1,d2
	eor.l	d0,d2

	bra.s	.start2
.x2
	move.l	(a0)+,d0
;			SATURATE d0,d7	;!!!
	
	move.l	(a0)+,d1		
;			SATURATE d1,d7	;!!!

	move.l	d3,(a1)+	;!!!

	move.l	d1,d3			; Swap 8x2
	lsr.l	#8,d3
	eor.l	d0,d3
	and.l	d4,d3
	eor.l	d3,d0
	lsl.l	#8,d3
	eor.l	d1,d3

;	move.l	d2,BPLSIZE-4(a1)	;!!! unused 6th bitplane

	move.l	d0,d2			; Swap 1x2
	add.l	d2,d2
	eor.l	d3,d2
	and.l	d5,d2
	eor.l	d2,d3
	lsr.l	#1,d2
	eor.l	d0,d2

.start2
	cmpa.l	a0,a2
	bne.s	.x2
.x2end
	move.l	d3,(a1)+	;!!!
	move.l	d2,BPLSIZE-4(a1) ;!!!

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

c2p_copyinitblock
	movem.l	a0-a1,-(sp)
	lea	c2p_datanew(pc),a0
	lea	c2p_data(pc),a1
	moveq	#16-1,d0
.copy	move.l	(a0)+,(a1)+
	dbf	d0,.copy
	movem.l	(sp)+,a0-a1
	rts

	cnop	0,4

c2p_data
c2p_screen dc.l	0
c2p_scroffs dc.l 0
c2p_pixels dc.l 0
	ds.l	16

	cnop 0,4
c2p_datanew
	ds.l	16

;	section	bss,bss

c2p_tempbuf ds.b CHUNKYXMAX*CHUNKYYMAX/4
e:
