; wos hardware abstraction layer
; killer mode

; for display, interrupts, etc.
	rts


; required functions:
; - wosInitHAL
; - wosActivateHAL
; - wosReleaseHAL

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

wbview:	dc.l	0
oldcop1:
	dc.l	0
oldcop2:
	dc.l	0
oldlev3:
	dc.l	0
oldlev1:
	dc.l	0
old80:	dc.l	0
oldintena:
	dc.w	0
olddmacon:
	dc.w	0
oldadkcon:
	dc.w	0
oldintreq:
	dc.w	0


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

; display abstration, to allow killer and system-friendly displays
; to be plugged into WOS at take: and give:
; also activate interrupts

; everything else should be transparent

; in: a0 - ptr to level3server (to end on rts)
; returns d0=0 on success, otherwise error

wosActivateHAL:
	move.l	a0,hallev3ptr

	lea	wbview(pc),a0
	move.l	$22(a6),(a0)
	lea	oldcop1(pc),a0
	move.l	$26(a6),(a0)
	lea	oldcop2(pc),a0
	move.l	$32(a6),(a0)
	sub.l	a1,a1
	jsr	-222(a6)		;loadview
	jsr	-270(a6)		;waittof
	jsr	-270(a6)		;waittof

.wait:	btst	#6,$bfe001		;Mouse
	beq.s	.wait
	btst	#6,$dff002		;Blitter
	bne.s	.wait

	lea	olddmacon(pc),a0
	move	$dff002,(a0)
	lea	oldintena(pc),a0
	move	$dff01c,(a0)
	lea	oldadkcon(pc),a0
	move	$dff010,(a0)
	lea	oldintreq(pc),a0
	move	$dff01e,(a0)

	move	#$7fff,$dff09a		; disable all interrupts
	move	#$7fff,$dff096		; disable all dma

	move.l	vbroffset,a0
	lea	oldlev3(pc),a1		;lev3
	move.l	$6c(a0),(a1)
	lea	oldlev1(pc),a1		;lev1
	move.l	$64(a0),(a1)
	lea	old80(pc),a1		;$80 - trap to supervisor mode
	move.l	$80(a0),(a1)


	;        lea   Level3Server(pc),a1

	lea	hallev3(pc),a1
	move.l	a1,$6c(a0)


	ifd	FRAMESYNC
	move.l	execbase,a6
	lea	Level1Init(pc),a5
	jsr	_LVOSupervisor(a6)
	endc

	move.l	#Init_coplist,$dff080

	;move #$c020,$dff09a
	;move #$83e0,$dff096     ; Sprites erstmal anlassen


	move.w	Init_dmacon(pc),$dff096	; enable dma

;        move.w  #%0111111111111111,$dff09c      ;interrupt request schreiben
	;move.w  #%1110000000101100,$dff09a      ;interrupt enable schreiben
	move.w	Init_intena(pc),$dff09a	; enable interrupts

	move.b	#%11111001,$bfd100	;Laufwerke
	move.b	#%10000001,$bfd100	;aus
	move.b	#%01111001,$bfd100

	moveq.l	#0,d0
	rts

hallev3ptr:
	dc.l	0
hallev3:
;	push	d0-a6
	push	d0/d1/a0/a1/a5/a6

	;!!! FPU context save
	fsave	-(a7)
	fmovem	fp0-fp7,-(a7)


; vertical blanc or blitter interrupt?
	move.w	$dff01e,d0		;intreq-read    
	btst	#5,d0			;VBI?
	bne	.vertb
	btst	#6,d0			;Blitter?
	bne	.blit

	bra	.quithalL3

;----   Blitter
.blit:
;	move.l	c2p_queue(pc),a0
;	cmp.l	#0,a0
;	beq.s	.noPlanarSwap
;	moveq	#-1,d0		;if this is 0 after the call we are done
;	jsr	(a0)		;qblit for c3b1, rts for c5

.noPlanarSwap

;       jsr     qblit
;       lea     _wosbase(pc),a0
;       tst.l   L3_Blitter(a0)
;       beq.s   .noblituser
;       jmp     L3_Blitter(a0)

.noblituser:
	move.w	#$4040,$dff09c
	move.w	#$4040,$dff09c
	bra	.quithalL3


;----   Vertical Blanc
.vertb:	move.l	hallev3ptr(pc),a0
;	cmp.l	#0,a0
;	bne.s	.nolev3
	jsr	(a0)


	; check exit on keyboard and mouse
	lea	Esc(pc),a0
	ifnd	NORMB
;		btst.w	#10,$dff016
	btst.b	#2,$dff016
	bne.s	.c0
	move.b	#2,(a0)
	endc
.c0	
	ifnd	NOLMB
	btst	#6,$bfe001		;Maus ???
	bne.s	.c1
	move.b	#2,(a0)
	endc
.c1	
	ifnd	NOESC
	bsr	GetKey			;Tasten lesen
	cmp.b	#$45,d0
	bne.s	.c2
	lea	Esc(pc),a0
	move.b	#2,(a0)
	endc
.c2	bsr	Maus


.nolev3:
	move.w	#$4020,$dff09c
	move.w	#$4020,$dff09c

.quithalL3:

;
;	;!!! fpu context restore
	fmovem	(a7)+,fp0-fp7
	frestore (a7)+


	pull	d0/d1/a0/a1/a5/a6
;	pull	d0-a6
	nop
	rte


; as called by macro WAITVBL
wait_vert_blanc:
	btst	#0,$dff005
	beq.s	wait_vert_blanc
.lp	btst	#0,$dff005
	bne.s	.lp
	rts

;----------------------------- MouseKey.s


;---------------Maus-Routine

MXMax	=	640
MYMax	=	360

Maus:	lea	$dff00a,a0
	move	(a0),d0
	lea	oldmaus(pc),a1
	move	d0,d1
	lsr	#8,d1
	sub.b	(a1),d1
	ext	d1
	add	d1,-4(a1)
	bpl.s	.ok6
	move	#0,-4(a1)
.ok6:	cmp	#MYMax,-4(a1)
	ble.s	.ok7
	move	#MYMax,-4(a1)
.ok7:	sub.b	1(a1),d0
	ext	d0
	add	d0,-2(a1)
	bpl.s	.ok5
	move	#0,-2(a1)
.ok5:	cmp	#MXMax,-2(a1)
	ble.s	.ok4
	move	#MXMax,-2(a1)
.ok4:	move	(a0),(a1)
	rts


MY:	dc.w	0
MX:	dc.w	0
oldmaus:
	dc.w	0


;---------------Keyboard-Routine
code:	dc.b	0
old:	dc.b	0
	even
KEYREPEAT =	1

GetKey:	;Rawkey-Code in "Code" and d0.l
keys:	move.l	d2,-(a7)
	ifeq	KEYREPEAT
	clr.b	code(pc)
	endc
	move.b	$bfed01,d0
	move.w	#8,$dff09c
;        move.w	#8,$dff09c	;!!!
	move.b	$bfec01,d0
	bset	#6,$bfee01
	not.w	d0
	ror.b	#1,d0
	ifeq	KEYREPEAT
	cmp.b	old(pc),d0
	beq	keyw
	endc
	;move.b	              d0,code
	moveq	#0,d2
	move.b	d0,d2
	lea	code(pc),a0
	move.b	d0,d1
	rol.w	#8,d1
	ifeq	KEYREPEAT
keyw:	;move.b	   d0,old
	move.b	d0,d1
	endc
	move.w	d1,(a0)
	moveq	#1,d1			;kann man auch auf 1 setzen (#Rasterzeilen)
keylp:	move.b	$dff006,d0
keylp1:	cmp.b	$dff006,d0
	beq.s	keylp1
	dbra	d1,keylp
	bclr	#6,$bfee01
	move.l	d2,d0
	move.l	(a7)+,d2
	rts




Init_dmacon:
	dc.w	%1000000111101111!$8200
;			 -----a-bcdefghij
;		a: Blitter hat Priorität
;		b: Bitplane DMA
;		c: Copper DMA
;		d: Blitter DMA
;		e: Sprite DMA
;		f: Disk DMA
;		g-j Audio 3-0 DMA
;Init_intena:       dc.w    %1100000001100000	;standard wos 1.0
Init_intena:
	dc.w	%1100000001100100	; also enable softint lev1

;Init_intena:       dc.w    %1100000001101100	;for THX-CIA

wosReleaseHAL:

	move	#$7fff,$dff09a
	move	#$7fff,$dff096
	move.l	vbroffset,a0
	move.l	oldlev3(pc),$6c(a0)
	move.l	oldlev1(pc),$64(a0)
	move.l	old80(pc),$80(a0)


	movem	oldintena(pc),d0/d1
	or	#$c000,d0
	or	#$8000,d1
	move	d0,$dff09a
	move	d1,$dff096
	move	oldadkcon(pc),$dff09e
	move	oldintreq(pc),$dff09c

	move.l	oldcop1(pc),$dff080
	move.l	oldcop1(pc),$dff080
	move.l	oldcop2(pc),$dff084
	move.l	oldcop2(pc),$dff084

	ifnd	NOSPRITESFIX
	jsr	ReturnSpritesToNormal
	endc


	move.l	wbview(pc),a1
	move.l	gfxbase(pc),a6
	jsr	-222(a6)		;loadview

	rts


