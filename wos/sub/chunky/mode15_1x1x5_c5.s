; 27.09.2015, upper 5 bits version (some ror.l added)
; 05.10.2015, removed lower 3 bits

	include	wos_defines.i
s:
	bra	c2p1x1_5_c5_060_init	;Init (Offset 0)
	bra	c2p1x1_5_c5_060			;Main (Offset 4)
	rts						;Exit (Offset 8)
	rts
	rts						;QBlit (Offset 12) 
	rts

; c2p1x1_5_c5_060
;
; 2010-04-26: bugfixed bpl4 output


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

;	section	code,code

; d0.w	chunkyx [chunky-pixels]
; d1.w	chunkyy [chunky-pixels]
; d2.w	(scroffsx) [screen-pixels]
; d3.w	scroffsy [screen-pixels]
; d4.w	(rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l	(bplsize) [bytes] -- offset between one row in one bpl and the next bpl

c2p1x1_5_c5_060_init
	movem.l	d2-d3,-(sp)
	andi.l	#$ffff,d0
	mulu.w	d0,d3
	lsr.l	#3,d3
	move.l	d3,c2p1x1_5_c5_060_scroffs
	mulu.w	d0,d1
	move.l	d1,c2p1x1_5_c5_060_pixels
	movem.l	(sp)+,d2-d3
	rts

; a0	c2pscreen
; a1	bitplanes

c2p1x1_5_c5_060
	movem.l	d2-d7/a2-a6,-(sp)

;	move.l	#$33333333,d5
;	move.l	#$55555555,d6
;	move.l	#$00ff00ff,a6

	add.w	#BPLSIZE*2,a1
	add.l	c2p1x1_5_c5_060_scroffs,a1

	move.l	c2p1x1_5_c5_060_pixels,a2
	add.l	a0,a2
	cmp.l	a0,a2
	beq	.none

	move.l	(a0)+,d0
		and.l	#$f8f8f8f8,d0	; upper 5 bits only
		lsr.l	#3,d0
	move.l	(a0)+,d1
		and.l	#$f8f8f8f8,d1
		lsr.l	#3,d1
	move.l	(a0)+,d2
		and.l	#$f8f8f8f8,d2
		lsr.l	#3,d2
	move.l	(a0)+,d3
		and.l	#$f8f8f8f8,d3
		lsr.l	#3,d3
	move.l	(a0)+,d4
		and.l	#$f8f8f8f8,d4
		lsr.l	#3,d4
	move.l	(a0)+,d5
		and.l	#$f8f8f8f8,d5
		lsr.l	#3,d5
	move.l	(a0)+,d6
		and.l	#$f8f8f8f8,d6
		lsr.l	#3,d6
		move.l	d6,a5
	move.l	(a0)+,d6
		and.l	#$f8f8f8f8,d6
		lsr.l	#3,d6
		move.l	d6,a6

	swap	d4			; Swap 16x4
	swap	d5
	eor.w	d0,d4
	eor.w	d1,d5
	eor.w	d4,d0
	eor.w	d5,d1
	eor.w	d0,d4
	eor.w	d1,d5
	swap	d4
	swap	d5

	exg	d4,a5
	exg	d5,a6

	swap	d4
	swap	d5
	eor.w	d2,d4
	eor.w	d3,d5
	eor.w	d4,d2
	eor.w	d5,d3
	eor.w	d2,d4
	eor.w	d3,d5
	swap	d4
	swap	d5

	exg	d4,a5
	exg	d5,a6

	move.l	d2,d6			; Swap 8x2
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	#$00ff00ff,d6
	and.l	#$00ff00ff,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d2
	eor.l	d7,d3

	exg	d2,a5
	exg	d3,a6

	move.l	d2,d6
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d4,d6
	eor.l	d5,d7
	and.l	#$00ff00ff,d6
	and.l	#$00ff00ff,d7

	eor.l	d6,d4
	eor.l	d7,d5
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d2
	eor.l	d7,d3

	exg	d2,a5
	exg	d3,a6

	move.l	d1,d6
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	bra	.start1
; hacked by lop - todo: put to registers
.dirtytemp	dc.l	0
.x1
	move.l	(a0)+,d0
			and.l	#$f8f8f8f8,d0	; upper 5 bits only
			lsr.l	#3,d0
			move.l	d0,.dirtytemp
	move.l	(a0)+,d1
			and.l	#$f8f8f8f8,d1
			lsr.l	#3,d1
	move.l	(a0)+,d2
			and.l	#$f8f8f8f8,d2
			lsr.l	#3,d2
	move.l	(a0)+,d3
			and.l	#$f8f8f8f8,d3
			lsr.l	#3,d3
	move.l	(a0)+,d4
			and.l	#$f8f8f8f8,d4
			lsr.l	#3,d4
	move.l	(a0)+,d5
			and.l	#$f8f8f8f8,d5
			lsr.l	#3,d5
	move.l	(a0)+,d0
			and.l	#$f8f8f8f8,d0
			lsr.l	#3,d0
			move.l	d0,a5
	move.l	(a0)+,d0
			and.l	#$f8f8f8f8,d0
			lsr.l	#3,d0
			move.l	d0,a6
	move.l	.dirtytemp,d0

	move.l	d6,(a1)+

	swap	d4			; Swap 16x4
	swap	d5
	eor.w	d0,d4
	eor.w	d1,d5
	eor.w	d4,d0
	eor.w	d5,d1
	eor.w	d0,d4
	eor.w	d1,d5
	swap	d4
	swap	d5

	exg	d4,a5
	exg	d5,a6

	swap	d4
	swap	d5
	eor.w	d2,d4
	eor.w	d3,d5
	eor.w	d4,d2
	eor.w	d5,d3
	eor.w	d2,d4
	eor.w	d3,d5
	swap	d4
	swap	d5

	exg	d4,a5
	exg	d5,a6

	move.l	d7,-BPLSIZE*2-4(a1)

	move.l	d2,d6			; Swap 8x2
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	#$00ff00ff,d6
	and.l	#$00ff00ff,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d2
	eor.l	d7,d3

	exg	d2,a5
	exg	d3,a6

	move.l	d2,d6
	move.l	d3,d7
	lsr.l	#8,d6
	lsr.l	#8,d7
	eor.l	d4,d6
	eor.l	d5,d7
	and.l	#$00ff00ff,d6
	and.l	#$00ff00ff,d7

	move.l	a3,BPLSIZE-4(a1)

	eor.l	d6,d4
	eor.l	d7,d5
	lsl.l	#8,d6
	lsl.l	#8,d7
	eor.l	d6,d2
	eor.l	d7,d3

	exg	d2,a5
	exg	d3,a6

	move.l	d1,d6
	move.l	d3,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d0,d6
	eor.l	d2,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d0
	eor.l	d7,d2
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d1
	eor.l	d7,d3

	move.l	a4,-BPLSIZE-4(a1)
.start1
	add.l	d0,d0
	or.l	d2,d0

	exg	d1,a5
	exg	d3,a6

	move.l	d3,d6
	move.l	d5,d7
	lsr.l	#4,d6
	lsr.l	#4,d7
	eor.l	d1,d6
	eor.l	d4,d7
	and.l	#$0f0f0f0f,d6
	and.l	#$0f0f0f0f,d7
	eor.l	d6,d1
	eor.l	d7,d4
	lsl.l	#4,d6
	lsl.l	#4,d7
	eor.l	d6,d3
	eor.l	d7,d5

	add.l	d4,d4
	or.l	d4,d1

	lsl.l	#2,d0
	or.l	d1,d0

	move.l	d0,BPLSIZE*2(a1)

	move.l	a5,d0
	move.l	a6,d1

	move.l	d5,d6			; Swap 2x4
	move.l	d3,d7
	lsr.l	#2,d6
	lsr.l	#2,d7
	eor.l	d0,d6
	eor.l	d1,d7
	and.l	#$33333333,d6
	and.l	#$33333333,d7
	eor.l	d6,d0
	eor.l	d7,d1
	lsl.l	#2,d6
	lsl.l	#2,d7
	eor.l	d6,d5
	eor.l	d7,d3

	move.l	d1,d6			; Swap 1x2
	move.l	d3,d7
	lsr.l	#1,d6
	lsr.l	#1,d7
	eor.l	d0,d6
	eor.l	d5,d7
	and.l	#$55555555,d6
	and.l	#$55555555,d7
	eor.l	d6,d0
	eor.l	d7,d5
	add.l	d6,d6
	add.l	d7,d7
	eor.l	d1,d6
	eor.l	d3,d7

	move.l	d0,a3
	move.l	d5,a4

	cmpa.l	a0,a2
	bne	.x1
.x1end
	move.l	d6,(a1)+
	move.l	d7,-BPLSIZE*2-4(a1)
	move.l	a3,BPLSIZE-4(a1)
	move.l	a4,-BPLSIZE-4(a1)

.none
	movem.l	(sp)+,d2-d7/a2-a6
	rts

;	section	bss,bss


c2p1x1_5_c5_060_scroffs	ds.l	1
c2p1x1_5_c5_060_pixels	ds.l	1
e:
