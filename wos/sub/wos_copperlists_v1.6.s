; 15.05.15: modified copm8 to disable bitplane dma for black parts of screen
;           actual screensize only approximated from 80 to 255 = 175 lines

; WickedOS copperlists for "Prototype 1", new screenmodes 8..13 in 320x180, 16:9, etc.
; sprite clipping fixed by setting diwstrt and diwstop correctly, from ahrm p.52:
; "The normal PAL DIWSTRT is ($2C81).
;  The normal PAL DIWSTOP is ($2CC1)."
; adjusted that to fit for out 180 lines screen: diwstrt is $5081,diwstop is $02c1

;	        dc.w    diwstrt,$4671,diwstop,$0bc1	;16:9-Größe
;	        dc.w    diwstrt,$2c81,diwstop,$2cc1	;PAL-Größe
;		dc.w    diwstrt,$2c81,diwstop,$f4c1	;NTSC-Größe

;========= mode 0, you are on your own
Copm0:
	dc.w    $01fc,0,$106,0                  ;die NoMode-Copperliste
        dc.w    $0180,$888
        dc.l    -2

;========= mode 1, 320x200, 8bit
	ifnd	NOMODE1	
Copm1:
        dc.w    fmode,$f,bplcon3,$60
;	dc.w	$1fc,3,$106,0
       	dc.w    diwstrt,$4681,diwstop,$0cc1	;16:9-Größe	(diwstop$0ec1)

        dc.w    ddfstrt,$38,ddfstop,$a0
	dc.w	bplcon0,%0000001000010000
	dc.w	bplcon1,0
        dc.w    bplcon2,$3f
	dc.w	bplcon4,$ff
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0

	; beginn des bildschirms (c2p>effekt)
	;dc.w	$460f,$fffe	; auf zeile 70 warten (beginn des screens)
	;dc.w	$9c,$8004	; softint
	;dc.w	$180,$7b	; col0 to blue
	
	;dc.w	$ffdf,$fffe	; auf zeile 255 warten
	;dc.w	$0c0f,$fffe	; und weitere 15 zeilen warten
	;dc.w	$9c,$8004	; softint
	;dc.w	$180,$0ff0	; col0 to yellow
	

sprm1:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm1:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1

	dc.l	-2


	endc
	
;========= mode 2, 320x100, 8bit
	ifnd	NOMODE2
Copm2:
	dc.w	$1fc,$400f,$106,0		;playfield scandoubling
       	dc.w    diwstrt,$4681,diwstop,$0ec1	;16:9-Größe	(diwstop$0ec1)

        dc.w    ddfstrt,$38,ddfstop,$a0
	dc.w	bplcon0,%0000001000010000
	dc.w	bpl1mod,-40
	dc.w	bpl2mod,0

sprm2:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm2:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 3, 160x100, 8bit
	ifnd	NOMODE3
Copm3:
	dc.w	$1fc,$400f,$106,$20		;playfield scandoubling
       	dc.w    diwstrt,$4681,diwstop,$0cc1	;16:9-Größe	(diwstop$0ec1)

        dc.w    ddfstrt,$30,ddfstop,$a0
	dc.w	bplcon0,%0000001000010000
	dc.w	bpl1mod,-40
	dc.w	bpl2mod,0

sprm3:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm3:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 4, 640x200, 8bit
	ifnd	NOMODE4
Copm4:
	dc.w	$1fc,$f,$106,4			;war $1fc,3
       	dc.w    diwstrt,$4681,diwstop,$0ec1	;16:9-Größe	(diwstop$0ec1)

        dc.w    ddfstrt,$30,ddfstop,$c0
	dc.w	bplcon0,%1000001000010000
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	
sprm4:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm4:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 5, 640x400, 8bit
	ifnd	NOMODE5	
Copm5:
	dc.w	$1fc,$d,$106,4			;war $1fc,1
      	dc.w    diwstrt,$4681,diwstop,$0ec1	;16:9-Größe	(diwstop$0ec1)

        dc.w    ddfstrt,$38,ddfstop,$d0
	dc.w	bplcon0,%1000001000010100
	dc.w	bpl1mod,80
	dc.w	bpl2mod,80

sprm5:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm5:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 6, 160x100, 18 bit
	ifnd	NOMODE6
Copm6:
	dc.w	$1fc,$400f,$106,4			;war $1fc,3
       	dc.w    diwstrt,$4681,diwstop,$0ec1	;16:9-Größe	(diwstop$0ec1)

        dc.w    ddfstrt,$30,ddfstop,$c0
;	dc.w	bplcon0,%1000101000010000
	dc.w	bplcon0,$8a11
	dc.w	bpl1mod,-80
	dc.w	bpl2mod,0
	
sprm6:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm6:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc
	
;========= mode 7, 320x200, 6 bit	
	ifnd	NOMODE7
Copm7:
        dc.w    fmode,$f,bplcon3,$60
;	dc.w	$1fc,3,$106,0
       	dc.w    diwstrt,$4681,diwstop,$0cc1	;16:9-Größe	(diwstop$0ec1)

        dc.w    ddfstrt,$38,ddfstop,$a0
	dc.w	bplcon0,%0000001000010000
	dc.w	bplcon1,0
        dc.w    bplcon2,$3f
	dc.w	bplcon4,$ff
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	
sprm7:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm7:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 8, 320x180, 8 bit, (intended to be framesync c2p at some point)
; dmacon: $100 is off, $8100 is on

	ifnd	NOMODE8
Copm8:
	; clear bitplane DMA bit at the start of black border
;	dc.w	dmacon,$7fff

;	dc.w	$180,$0

        dc.w    fmode,$f,bplcon3,$60
;	dc.w	$1fc,3,$106,0		

	;$4e81 passte gut, wenn man nicht bei $ff aufhören will
       	;dc.w    diwstrt,$4e81,diwstop,$02c1	;16:9-Größe, alte Position
       	;dc.w    diwstrt,$4981,diwstop,$fdc1	;16:9-Größe	(diwstop$0ec1)
	dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain

        dc.w    ddfstrt,$38,ddfstop,$a0
	dc.w	bplcon0,%0000001000010000
	dc.w	bplcon1,0
        dc.w    bplcon2,$3f
	dc.w	bplcon4,$ff
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0


	; enable bitplane DMA at the end of the black top border
	;$0a0f;$490f
;	dc.w	$400f,$fffe	; wait for line 80 (beginning of screen)
;	dc.w	dmacon,$8100


	; farb-bank wählen (noch zu debuggen)
	;dc.w	$0106,$2000
	
	; beginn des bildschirms (c2p>effekt)
;	dc.w	$450f,$fffe	; auf beginn des screens warten
;	dc.w	dmacon,$8100
;	dc.w	$9c,$8004	; softint
;	dc.w	$180,$f0	; col0 to green
	
	; switch to c2p
;	dc.w	$f8df,$fffe	; auf ende des screens warten (beam riders line bug)

;	dc.w	$a0df,$fffe	; test in middle of screen

;	dc.w	dmacon,$100
	
;	dc.w	$9c,$8004	; softint
;	dc.w	$180,$0ff0	; col0 to yellow

sprm8:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0



	; disable bitplane DMA (clear bit) for bottom black border
	;$ffdf
	;dc.w	$1fdf,$fffe	; wait for line xy (beginning of screen)
	;dc.w    $0180,$f00
	;dc.w	dmacon,$100

	;dc.w    $0106,$0C0
	;dc.w	$fff,$180

	; colours should be set before the screen start
colm8:	ds.b	256*16

	dc.l	-2

	endc

;========= mode 9, 320x90, 8 bit
	ifnd	NOMODE9
Copm9:
	dc.w	$1fc,$400f,$106,0		;playfield scandoubling
       	;dc.w    diwstrt,$5081,diwstop,$02c1	;16:9-Größe	(diwstop$0ec1) 180er höhe
			dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        dc.w    ddfstrt,$38,ddfstop,$a0

	dc.w	bplcon0,%0000001000010000
	dc.w	bpl1mod,-40
	dc.w	bpl2mod,0

sprm9:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm9:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc
	
;========= mode 10, 160x90, 8 bit
	ifnd	NOMODE10
Copm10:
	dc.w	$1fc,$400f,$106,$20		;playfield scandoubling
       	;dc.w    diwstrt,$5081,diwstop,$02c1	;16:9-Größe	(diwstop$0ec1) 180er höhe
			dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        dc.w    ddfstrt,$30,ddfstop,$a0
        
	dc.w	bplcon0,%0000001000010000
	dc.w	bpl1mod,-40
	dc.w	bpl2mod,0

sprm10:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm10:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc
	
;========= mode 11, 18 bit 160x90
	ifnd	NOMODE11
Copm11:
	dc.w	$1fc,$400f,$106,4			;war $1fc,3
       	;dc.w    diwstrt,$5081,diwstop,$02c1	;16:9-Größe	(diwstop$0ec1) 180er höhe
			dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        dc.w    ddfstrt,$30,ddfstop,$c0
        
;	dc.w	bplcon0,%1000101000010000
	dc.w	bplcon0,$8a11
		dc.w	bplcon1,0
        dc.w    bplcon2,$3f
		dc.w	bplcon4,$ff
	dc.w	bpl1mod,-80
	dc.w	bpl2mod,0
	
sprm11:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm11:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 12, 640x180, 8bit
	ifnd	NOMODE12
Copm12:
	dc.w	$1fc,$f,$106,4			;war $1fc,3
      	;dc.w    diwstrt,$5081,diwstop,$02c1	;16:9-Größe	(diwstop$0ec1) 180er höhe
			dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        dc.w    ddfstrt,$30,ddfstop,$c0
        
	dc.w	bplcon0,%1000001000010000
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	
sprm12:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm12:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 13, 640x360, 8bit
	ifnd	NOMODE13
Copm13:
	dc.w	$1fc,$d,$106,4			;war $1fc,1
      	;dc.w    diwstrt,$5081,diwstop,$02c1	;16:9-Größe	(diwstop$0ec1) 180er höhe
			dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        dc.w    ddfstrt,$38,ddfstop,$d0
        
	dc.w	bplcon0,%1000001000010100
	dc.w	bpl1mod,80
	dc.w	bpl2mod,80

sprm13:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm13:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 14, 320x180, 6 bit	
	ifnd	NOMODE14
Copm14:
        dc.w    fmode,$f,bplcon3,$60
;	dc.w	$1fc,3,$106,0
       	;dc.w    diwstrt,$5081,diwstop,$02c1	;16:9-Größe	(diwstop$0ec1) 180er höhe
			dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        dc.w    ddfstrt,$38,ddfstop,$a0

	dc.w	bplcon0,%0110001000000000
	dc.w	bplcon1,0
        dc.w    bplcon2,$23f	; KILLEHB required (bit 9=$200)
	dc.w	bplcon4,$ff
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	
sprm14:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm14:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 15, 320x180, upper 5 bit	
	ifnd	NOMODE15
Copm15:
        dc.w    fmode,$f,bplcon3,$60
	;	dc.w	$1fc,3,$106,0
	
	; Y-Zeilen müssen geändert werden, Standard in DIWSTRT und für Copperwaits WOS2015 war $50 = Zeile 80
	; - Y läuft bei $ff = 255 über, Screen-Höhe ist 180, 80+180 -> Überlauf
	; - 255-180=75($4b) 
	; X-Max is $E2!

	; 1) am unteren Ende (255-180) orientierter Screen: $4b-$ff
	; 2) viel Luft zum Wackeln nach unten und oben, $40-$F4
	; 3) 6 Pixel Luft zum Wackeln nach unten und oben, $45-$F9 (Prototype 1 bounce1dat und bounce2dat passen noch)
       	dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        dc.w    ddfstrt,$38,ddfstop,$a0

	dc.w	bplcon0,%0000001000010000
	dc.w	bplcon1,0
        dc.w    bplcon2,$3f
	dc.w	bplcon4,$ff
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	
	; todo: wait for line, write bpl-pointers (only 6,7,8 for a start)
	
	;dc.w	$450f,$fffe	; auf beginn des screens warten
	;dc.w	$180,0
	
LINEBPLPT678 Macro   ;Line
		dc.b	$45+\1,$0f,$ff,$fe; auf Beginn der Line warten	; 4 Bytes
		dc.w	$f4, 0, $f6,0	; bitplane 6					; 8 Bytes
		dc.w	$f8, 0, $fa,0	; bitplane 7					; 8 Bytes
		dc.w	$fc, 0, $fe,0	; bitplane 8					; 8 Bytes
        EndM

bplm15:
	; bitplane pointer registers must be reinitialized every vbl by copper or CPU
	; dc.w	$E0	; bitplane1  (high 5 bits)
	; dc.w	$E2	; bitplane1  (low 15 bits)
	; bitplane2: $e4/$e6
	; bitplane3: $e8/$ea
	; bitplane4: $ec/$ee
	; bitplane5: $f0/$f2	
	; bitplane6: $f4/$f6	; << start here
	; bitplane7: $f8/$fa
	; bitplane8: $fc/$fe

t_line678_start:	
	LINEBPLPT678 00
t_line678_end:

LINE678_LENGTH= (t_line678_end-t_line678_start)	
	;LINEBPLPT678 00
	; use bplm15+LINE678_LENGTH*Line to write to registers
	;  offset 6: high word of bitplane 6
	;  offset 10: low word of bitplane 6
	;   offset 14: high word of bitplane 7
	;   offset 18: low word of bitplane 7
	;    offset 22: high word of bitplane 8
	;    offset 26: low word of bitplane 8

	LINEBPLPT678 01
	LINEBPLPT678 02
	LINEBPLPT678 03
	LINEBPLPT678 04
	LINEBPLPT678 05
	LINEBPLPT678 06
	LINEBPLPT678 07
	LINEBPLPT678 08
	LINEBPLPT678 09
	LINEBPLPT678 10

	LINEBPLPT678 11
	LINEBPLPT678 12
	LINEBPLPT678 13
	LINEBPLPT678 14
	LINEBPLPT678 15
	LINEBPLPT678 16
	LINEBPLPT678 17
	LINEBPLPT678 18
	LINEBPLPT678 19

	LINEBPLPT678 20
	LINEBPLPT678 21
	LINEBPLPT678 22
	LINEBPLPT678 23
	LINEBPLPT678 24
	LINEBPLPT678 25
	LINEBPLPT678 26
	LINEBPLPT678 27
	LINEBPLPT678 28
	LINEBPLPT678 29

	LINEBPLPT678 30
	LINEBPLPT678 31
	LINEBPLPT678 32
	LINEBPLPT678 33
	LINEBPLPT678 34
	LINEBPLPT678 35
	LINEBPLPT678 36
	LINEBPLPT678 37
	LINEBPLPT678 38
	LINEBPLPT678 39

	LINEBPLPT678 40
	LINEBPLPT678 41
	LINEBPLPT678 42
	LINEBPLPT678 43
	LINEBPLPT678 44
	LINEBPLPT678 45
	LINEBPLPT678 46
	LINEBPLPT678 47
	LINEBPLPT678 48
	LINEBPLPT678 49

	LINEBPLPT678 50
	LINEBPLPT678 51
	LINEBPLPT678 52
	LINEBPLPT678 53
	LINEBPLPT678 54
	LINEBPLPT678 55
	LINEBPLPT678 56
	LINEBPLPT678 57
	LINEBPLPT678 58
	LINEBPLPT678 59

	LINEBPLPT678 60
	LINEBPLPT678 61
	LINEBPLPT678 62
	LINEBPLPT678 63
	LINEBPLPT678 64
	LINEBPLPT678 65
	LINEBPLPT678 66
	LINEBPLPT678 67
	LINEBPLPT678 68
	LINEBPLPT678 69

	LINEBPLPT678 70
	LINEBPLPT678 71
	LINEBPLPT678 72
	LINEBPLPT678 73
	LINEBPLPT678 74
	LINEBPLPT678 75
	LINEBPLPT678 76
	LINEBPLPT678 77
	LINEBPLPT678 78
	LINEBPLPT678 79

	LINEBPLPT678 80
	LINEBPLPT678 81
	LINEBPLPT678 82
	LINEBPLPT678 83
	LINEBPLPT678 84
	LINEBPLPT678 85
	LINEBPLPT678 86
	LINEBPLPT678 87
	LINEBPLPT678 88
	LINEBPLPT678 89

	LINEBPLPT678 90
	LINEBPLPT678 91
	LINEBPLPT678 92
	LINEBPLPT678 93
	LINEBPLPT678 94
	LINEBPLPT678 95
	LINEBPLPT678 96
	LINEBPLPT678 97
	LINEBPLPT678 98
	LINEBPLPT678 99


	LINEBPLPT678 100
	LINEBPLPT678 101
	LINEBPLPT678 102
	LINEBPLPT678 103
	LINEBPLPT678 104
	LINEBPLPT678 105
	LINEBPLPT678 106
	LINEBPLPT678 107
	LINEBPLPT678 108
	LINEBPLPT678 109
	LINEBPLPT678 110

	LINEBPLPT678 111
	LINEBPLPT678 112
	LINEBPLPT678 113
	LINEBPLPT678 114
	LINEBPLPT678 115
	LINEBPLPT678 116
	LINEBPLPT678 117
	LINEBPLPT678 118
	LINEBPLPT678 119

	LINEBPLPT678 120
	LINEBPLPT678 121
	LINEBPLPT678 122
	LINEBPLPT678 123
	LINEBPLPT678 124
	LINEBPLPT678 125
	LINEBPLPT678 126
	LINEBPLPT678 127
	LINEBPLPT678 128
	LINEBPLPT678 129

	LINEBPLPT678 130
	LINEBPLPT678 131
	LINEBPLPT678 132
	LINEBPLPT678 133
	LINEBPLPT678 134
	LINEBPLPT678 135
	LINEBPLPT678 136
	LINEBPLPT678 137
	LINEBPLPT678 138
	LINEBPLPT678 139

	LINEBPLPT678 140
	LINEBPLPT678 141
	LINEBPLPT678 142
	LINEBPLPT678 143
	LINEBPLPT678 144
	LINEBPLPT678 145
	LINEBPLPT678 146
	LINEBPLPT678 147
	LINEBPLPT678 148
	LINEBPLPT678 149

	LINEBPLPT678 150
	LINEBPLPT678 151
	LINEBPLPT678 152
	LINEBPLPT678 153
	LINEBPLPT678 154
	LINEBPLPT678 155
	LINEBPLPT678 156
	LINEBPLPT678 157
	LINEBPLPT678 158
	LINEBPLPT678 159

	LINEBPLPT678 160
	LINEBPLPT678 161
	LINEBPLPT678 162
	LINEBPLPT678 163
	LINEBPLPT678 164
	LINEBPLPT678 165
	LINEBPLPT678 166
	LINEBPLPT678 167
	LINEBPLPT678 168
	LINEBPLPT678 169

	LINEBPLPT678 170
	LINEBPLPT678 171
	LINEBPLPT678 172
	LINEBPLPT678 173
	LINEBPLPT678 174
	LINEBPLPT678 175
	LINEBPLPT678 176
	LINEBPLPT678 177
	LINEBPLPT678 178
	LINEBPLPT678 179


		
	;dc.w	$f4, 0, $f6,0	; bitplane 6
	;dc.w	$f8, 0, $fa,0	; bitplane 7
	;dc.w	$fc, 0, $fe,0	; bitplane 8
	
		
	; end of screen
	;dc.w	$ffdf,$fffe	; 
	dc.w	$f9df,$fffe	; auf ende des screens warten
	;dc.w	$180,$0	; col0 to black

sprm15:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

colm15:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2

emtpylinem15:	ds.l	40
	endc

;========= mode 16, 320x180, 8 bit plus copper colours 
;Pure Format               RR  GGBB
;               dc.w    $0041,$81FE ...
;                          12  1212
;Copper Format                              RGB (1) 
;               dc.w    $0106,$0C00,$0180,$048F ...
;                                           RGB (2)
;               dc.w    $0106,$0E00,$0180,$011E ...

LINECOL027 Macro   ;Line
		dc.b	$45+\1,$0f,$ff,$fe	; auf Beginn der Line warten	; 4 Bytes
		dc.w	$0106,$0C00	 ; bank switch					; 4 bytes
		dc.w	$180,0		 ; col 0 - upper 4 bit per channel	; 4 Bytes	-> write at 10,14,18,22, 26,30,34,38
		dc.w	$182,0		 ; col 1 - upper 4 bit				; 4 Bytes
		dc.w	$184,0		 ; col 2 - upper 4 bit				; 4 Bytes
      dc.w	$186,0		 ; col 3 - upper 4 bit				; 4 Bytes
      dc.w	$188,0		 ; col 4 - upper 4 bit				; 4 Bytes
      dc.w	$18a,0		 ; col 5 - upper 4 bit				; 4 Bytes
      dc.w	$18c,0		 ; col 6 - upper 4 bit				; 4 Bytes
      dc.w	$18e,0		 ; col 7 - upper 4 bit				; 4 Bytes
		dc.w  $106,$0E00	 ; bank switch					; 4 bytes   42
		dc.w	$180,0		 ; col 0 - lower 4 bit				; 4 Bytes	-> write at 46,50,54,58, 62,66,70,74
		dc.w	$182,0		 ; col 1 - lower 4 bit				; 4 Bytes
		dc.w	$184,0		 ; col 2 - lower 4 bit				; 4 Bytes
      dc.w	$186,0		 ; col 3 - lower 4 bit				; 4 Bytes
      dc.w	$188,0		 ; col 4 - lower 4 bit				; 4 Bytes
      dc.w	$18a,0		 ; col 5 - lower 4 bit				; 4 Bytes
      dc.w	$18c,0		 ; col 6 - lower 4 bit				; 4 Bytes
      dc.w	$18e,0		 ; col 7 - lower 4 bit				; 4 Bytes
        EndM

      ;colour 0 is on bank 0 (bplcon3 $0c00,$0e00)
      ;colours 244..255 are on bank 7 (bplcon3 $ec00,$ee00)
      ;per Line set copper colours 0, 249..255
LINECOLMODE16 Macro   
		dc.b	$45+\1,$0f,$ff,$fe	; wait for line start	; 4 Bytes
		dc.w	$106,$0C00	 ; bank 0, MSB                	; 4 bytes
		dc.w	$180,0		 ; col 0 - upper 4 bit        	; 4 Bytes	-> write at 10,18 (col 0)
		dc.w  $106,$0E00	 ; bank 0, LSB                   ; 4 bytes   
      dc.w	$180,0		 ; col 0 - lower 4 bit				; 4 Bytes	// block end: 20
      
      dc.w	$106,$EC00	 ; bank 3, MSB                	; 4 bytes
		dc.w	$1b2,0		 ; col 249 - upper 4 bit				; 4 Bytes   -> 26,30,34,38,42,46,50 (cols 249..255)
		dc.w	$1b4,0		 ; col 250 - upper 4 bit				; 4 Bytes
      dc.w	$1b6,0		 ; col 251 - upper 4 bit				; 4 Bytes
      dc.w	$1b8,0		 ; col 252 - upper 4 bit				; 4 Bytes
      dc.w	$1ba,0		 ; col 253 - upper 4 bit				; 4 Bytes
      dc.w	$1bc,0		 ; col 254 - upper 4 bit				; 4 Bytes
      dc.w	$1be,0		 ; col 255 - upper 4 bit				; 4 Bytes  // block end: 52
      
      dc.w	$106,$EE00	 ; bank 3, LSB                	; 4 bytes
		dc.w	$1b2,0		 ; col 249 - lower 4 bit				; 4 Bytes   -> write at 58,62,66,70,74,78,82 (cols 249..255)
		dc.w	$1b4,0		 ; col 250 - lower 4 bit				; 4 Bytes
      dc.w	$1b6,0		 ; col 251 - lower 4 bit				; 4 Bytes
      dc.w	$1b8,0		 ; col 252 - lower 4 bit				; 4 Bytes
      dc.w	$1ba,0		 ; col 253 - lower 4 bit				; 4 Bytes
      dc.w	$1bc,0		 ; col 254 - lower 4 bit				; 4 Bytes
      dc.w	$1be,0		 ; col 255 - lower 4 bit				; 4 Bytes
        EndM
        
	ifnd	NOMODE16
Copm16:
	; clear bitplane DMA bit at the start of black border
;	dc.w	dmacon,%0000000100000000
;	dc.w	$180,0	; col0 to green

        dc.w    fmode,$f,bplcon3,$60
;	dc.w	$1fc,3,$106,0		

	; Y-Zeilen müssen geändert werden, Standard in DIWSTRT und für Copperwaits WOS2015 war $50 = Zeile 80
	; - Y läuft bei $ff = 255 über, Screen-Höhe ist 180, 80+180 -> Überlauf
	; - 255-180=75($4b) 
	; X-Max is $E2!

	; 1) am unteren Ende (255-180) orientierter Screen: $4b-$ff
	; 2) viel Luft zum Wackeln nach unten und oben, $40-$F4
	; 3) 6 Pixel Luft zum Wackeln nach unten und oben, $45-$F9 (Prototype 1 bounce1dat und bounce2dat passen noch)
			dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        dc.w    ddfstrt,$38,ddfstop,$a0

	dc.w	bplcon0,%0000001000010000
	dc.w	bplcon1,0
        dc.w    bplcon2,$3f
	dc.w	bplcon4,$ff
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0


	; enable bitplane DMA at the end of the black top border
	;$0a0f;$490f
;	dc.w	$400f,$fffe	; wait for line 80 (beginning of screen)
;	dc.w	dmacon,%1000000100000000

sprm16:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0


	; farb-bank wählen (noch zu debuggen)
	;dc.w	$0106,$2000
	
	; beginn des bildschirms (c2p>effekt)
	;dc.w	$500f,$fffe	; auf zeile 80 warten (beginn des screens)
	;dc.w	$9c,$8004	; softint
	;dc.w	$180,$7b	; col0 to blue

coplinesm16:	
t_col027_start:	
	LINECOLMODE16 0
t_col027_end:

LINECOLMODE16_LENGTH= (t_col027_end-t_col027_start)	
	; use coplinesm16+LINECOLMODE16_LENGTH*Line to write to registers
	;  offset 10: high word of colour 0
	;  offset 14: high word of colour 1
	;  offset 18: high word of colour 2
	;   offset 26: low word of colour 0
	;   offset 30: low word of colour 1
	;   offset 34: low word of colour 2
	LINECOLMODE16 1
	LINECOLMODE16 2
	LINECOLMODE16 3
	LINECOLMODE16 4
	LINECOLMODE16 5
	LINECOLMODE16 6
	LINECOLMODE16 7
	LINECOLMODE16 8
	LINECOLMODE16 9

	LINECOLMODE16 10
	LINECOLMODE16 11
	LINECOLMODE16 12
	LINECOLMODE16 13
	LINECOLMODE16 14
	LINECOLMODE16 15
	LINECOLMODE16 16
	LINECOLMODE16 17
	LINECOLMODE16 18
	LINECOLMODE16 19

	LINECOLMODE16 20
	LINECOLMODE16 21
	LINECOLMODE16 22
	LINECOLMODE16 23
	LINECOLMODE16 24
	LINECOLMODE16 25
	LINECOLMODE16 26
	LINECOLMODE16 27
	LINECOLMODE16 28
	LINECOLMODE16 29

	LINECOLMODE16 30
	LINECOLMODE16 31
	LINECOLMODE16 32
	LINECOLMODE16 33
	LINECOLMODE16 34
	LINECOLMODE16 35
	LINECOLMODE16 36
	LINECOLMODE16 37
	LINECOLMODE16 38
	LINECOLMODE16 39

	LINECOLMODE16 40
	LINECOLMODE16 41
	LINECOLMODE16 42
	LINECOLMODE16 43
	LINECOLMODE16 44
	LINECOLMODE16 45
	LINECOLMODE16 46
	LINECOLMODE16 47
	LINECOLMODE16 48
	LINECOLMODE16 49

	LINECOLMODE16 50
	LINECOLMODE16 51
	LINECOLMODE16 52
	LINECOLMODE16 53
	LINECOLMODE16 54
	LINECOLMODE16 55
	LINECOLMODE16 56
	LINECOLMODE16 57
	LINECOLMODE16 58
	LINECOLMODE16 59

	LINECOLMODE16 60
	LINECOLMODE16 61
	LINECOLMODE16 62
	LINECOLMODE16 63
	LINECOLMODE16 64
	LINECOLMODE16 65
	LINECOLMODE16 66
	LINECOLMODE16 67
	LINECOLMODE16 68
	LINECOLMODE16 69

	LINECOLMODE16 70
	LINECOLMODE16 71
	LINECOLMODE16 72
	LINECOLMODE16 73
	LINECOLMODE16 74
	LINECOLMODE16 75
	LINECOLMODE16 76
	LINECOLMODE16 77
	LINECOLMODE16 78
	LINECOLMODE16 79

	LINECOLMODE16 80
	LINECOLMODE16 81
	LINECOLMODE16 82
	LINECOLMODE16 83
	LINECOLMODE16 84
	LINECOLMODE16 85
	LINECOLMODE16 86
	LINECOLMODE16 87
	LINECOLMODE16 88
	LINECOLMODE16 89

	LINECOLMODE16 90
	LINECOLMODE16 91
	LINECOLMODE16 92
	LINECOLMODE16 93
	LINECOLMODE16 94
	LINECOLMODE16 95
	LINECOLMODE16 96
	LINECOLMODE16 97
	LINECOLMODE16 98
	LINECOLMODE16 99
	
	LINECOLMODE16 100
	LINECOLMODE16 101
	LINECOLMODE16 102
	LINECOLMODE16 103
	LINECOLMODE16 104
	LINECOLMODE16 105
	LINECOLMODE16 106
	LINECOLMODE16 107
	LINECOLMODE16 108
	LINECOLMODE16 109

	LINECOLMODE16 110
	LINECOLMODE16 111
	LINECOLMODE16 112
	LINECOLMODE16 113
	LINECOLMODE16 114
	LINECOLMODE16 115
	LINECOLMODE16 116
	LINECOLMODE16 117
	LINECOLMODE16 118
	LINECOLMODE16 119

	LINECOLMODE16 120
	LINECOLMODE16 121
	LINECOLMODE16 122
	LINECOLMODE16 123
	LINECOLMODE16 124
	LINECOLMODE16 125
	LINECOLMODE16 126
	LINECOLMODE16 127
	LINECOLMODE16 128
	LINECOLMODE16 129

	LINECOLMODE16 130
	LINECOLMODE16 131
	LINECOLMODE16 132
	LINECOLMODE16 133
	LINECOLMODE16 134
	LINECOLMODE16 135
	LINECOLMODE16 136
	LINECOLMODE16 137
	LINECOLMODE16 138
	LINECOLMODE16 139

	LINECOLMODE16 140
	LINECOLMODE16 141
	LINECOLMODE16 142
	LINECOLMODE16 143
	LINECOLMODE16 144
	LINECOLMODE16 145
	LINECOLMODE16 146
	LINECOLMODE16 147
	LINECOLMODE16 148
	LINECOLMODE16 149
	
	LINECOLMODE16 150
	LINECOLMODE16 151
	LINECOLMODE16 152
	LINECOLMODE16 153
	LINECOLMODE16 154
	LINECOLMODE16 155
	LINECOLMODE16 156
	LINECOLMODE16 157
	LINECOLMODE16 158
	LINECOLMODE16 159

	LINECOLMODE16 160
	LINECOLMODE16 161
	LINECOLMODE16 162
	LINECOLMODE16 163
	LINECOLMODE16 164
	LINECOLMODE16 165
	LINECOLMODE16 166
	LINECOLMODE16 167
	LINECOLMODE16 168
	LINECOLMODE16 169

	LINECOLMODE16 170
	LINECOLMODE16 171
	LINECOLMODE16 172
	LINECOLMODE16 173
	LINECOLMODE16 174
	LINECOLMODE16 175
	LINECOLMODE16 176
	LINECOLMODE16 177
	LINECOLMODE16 178
	LINECOLMODE16 179


	; switch to c2p
	;dc.w	$f720,$fffe	; auf ende des screens warten
	;dc.w	$020f,$fffe	; und weitere 2 zeilen warten
		;dc.w	$9c,$8004	; softint
	;dc.w	$180,$000	; col0 to yellow


	; disable bitplane DMA (clear bit) for bottom black border
	;$ffdf
	
	; 1) das geht schonmal, aber mehrere zeilen frei
	;dc.w	$ffdf,$fffe
	;dc.w	$0120,$fffe	; und weiter warten jenseits von 255

	; 2) letzte Zeile ($45+179) ist $f8, $df ist rechts ziemlich am ende
	dc.w	$f8df,$fffe	; eigentlich müsste $e2 oder $e0 noch gehen, tut  aber nicht
	dc.w	$0106,$0C00		; also den copper einfach was sinnloses machen lassen (bank switch)
	dc.w	$0106,$0C00		; ""
   dc.w	$0106,$0C00
   dc.w	$0106,$0C00

	;dc.w	dmacon,%0000 0001 0000 0000
	
	; colours should be set before the screen start, but okay for debugging
   ; dc.w  $180,$ff0 ; to test that we hit bottom-right corner correctly
colm16:	ds.b	256*16
	dc.l	-2

	endc


;========= mode 17, 15 bit 220x180 from 32 bit ARGB buffer
	ifnd	NOMODE17
Copm17:
	dc.w	$1fc,$f,$106,4			;war $1fc,3
	dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        dc.w    ddfstrt,$38,ddfstop,$c0
        	; 30,c0
        
	dc.w	bplcon0,$8810	;$8a11
	dc.w	bplcon1,0
        dc.w    bplcon2,0	;$3f
        dc.w	bplcon3,0
	dc.w	bplcon4,$11	;$ff

	dc.w	bpl1mod,$10
	dc.w	bpl2mod,$10

	dc.w	color,$000
	
sprm17:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

	dc.l	-2
colm17:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 18, 15 bit 220x180 from 18 bit ARGB buffer
	ifnd	NOMODE18
Copm18:
	dc.w	$1fc,$f,$106,4			;war $1fc,3
	dc.w    diwstrt,$4581,diwstop,$f9c1	

        dc.w    ddfstrt,$38
	dc.w	ddfstop,$c0
        
	dc.w	bplcon0,$8810	;8a11 (with composite color/a1000),8810 (without)
	dc.w	bplcon1,0
        dc.w    bplcon2,0	;0, $3f (playfield priority bits)
        dc.w	bplcon3,0
	dc.w	bplcon4,0	;ff,11 (sprite colour tables)

	dc.w	bpl1mod,$10
	dc.w	bpl2mod,$10

	dc.w	color,$000
	
sprm18:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

	dc.l	-2
colm18:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 19, 15 bit 220x90 from 18 bit ARGB buffer
	ifnd	NOMODE19
Copm19:
	dc.w	$1fc,$400f,$106,4			;war $1fc,3
	dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        dc.w    ddfstrt,$38,ddfstop,$c0
        
	dc.w	bplcon0,$8810
	dc.w	bplcon1,0
        dc.w    bplcon2,0
        dc.w	bplcon3,0
	dc.w	bplcon4,$11

	dc.w	bpl1mod,-80
	dc.w	bpl2mod,$10

	dc.w	color,$000
	
sprm19:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

	dc.l	-2
colm19:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 20, 18 bit 220x180 from 24 bit ARGB buffer
	ifnd	NOMODE20
Copm20:
	dc.w	$1fc,$f,$106,4			;war $1fc,3
	dc.w    diwstrt,$4581,diwstop,$f9c1	

        dc.w    ddfstrt,$38	
        dc.w	ddfstop,$c0
        
	dc.w	bplcon0,$8810	;8a11 (with composite color/a1000),8810 (without)
	dc.w	bplcon1,0
        dc.w    bplcon2,0	;0, $3f (playfield priority bits)
        dc.w	bplcon3,0
	dc.w	bplcon4,0	;ff,11 (sprite colour tables)

	dc.w	bpl1mod,$10
	dc.w	bpl2mod,$10

	dc.w	color,$000
	
sprm20:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

	dc.l	-2
colm20:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 21, 18 bit 220x180 from 18 bit ARGB buffer
	ifnd	NOMODE21
Copm21:
	dc.w	$1fc,$f,$106,4			;war $1fc,3
	dc.w    diwstrt,$4581,diwstop,$f9c1	

        dc.w    ddfstrt,$38
	dc.w	ddfstop,$c0
        
	dc.w	bplcon0,$8810	;8a11 (with composite color/a1000),8810 (without)
	dc.w	bplcon1,0
        dc.w    bplcon2,0	;0, $3f (playfield priority bits)
        dc.w	bplcon3,0
	dc.w	bplcon4,0	;ff,11 (sprite colour tables)

	dc.w	bpl1mod,$10
	dc.w	bpl2mod,$10

	dc.w	color,$000
	
sprm21:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

	dc.l	-2
colm21:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 22, 18 bit 220x90 from 18 bit ARGB buffer
	ifnd	NOMODE22
Copm22:
	dc.w	$1fc,$400f,$106,4			;war $1fc,3
	dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        dc.w    ddfstrt,$38,ddfstop,$c0
        
	dc.w	bplcon0,$8810
	dc.w	bplcon1,0
        dc.w    bplcon2,0
        dc.w	bplcon3,0
	dc.w	bplcon4,$11

	dc.w	bpl1mod,-80
	dc.w	bpl2mod,$10

	dc.w	color,$000
	
sprm22:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

	dc.l	-2
colm22:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 23, 12 bit 220x180 from 18 bit ARGB buffer
	ifnd	NOMODE23
Copm23:
	dc.w	$1fc,$f,$106,4			;war $1fc,3
	dc.w    diwstrt,$4581,diwstop,$f9c1	

    dc.w    ddfstrt,$38
	dc.w	ddfstop,$c0
        
	dc.w	bplcon0,$8810	;8a11 (with composite color/a1000),8810 (without)
	dc.w	bplcon1,0
    dc.w    bplcon2,0	;0, $3f (playfield priority bits)
    dc.w	bplcon3,0
	dc.w	bplcon4,0	;ff,11 (sprite colour tables)

	dc.w	bpl1mod,$10
	dc.w	bpl2mod,$10

	dc.w	color,$000
	
sprm23:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

	dc.l	-2
colm23:	ds.b	256*16
	;dc.w	$9c,$8004	;call level1
        dc.l	-2
	endc

;========= mode 24, 320x180, 5 bit (OCS)	
	ifnd	NOMODE24
Copm24:
        dc.w    fmode,$0,bplcon3,$0	; $f, $60
	dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        ;dc.w    ddfstrt,$38,ddfstop,$a0
        dc.w    ddfstrt,$38,ddfstop,$d0

	dc.w	bplcon0,%0101001000000000	; 5 bitplanes laced	(bit2)
	dc.w	bplcon1,0
        dc.w    bplcon2,$0	;$3f  KILLEHB at bit 9 ($200)
	dc.w	bplcon4,$0	;$ff
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	
sprm24:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0

	dc.w	bplcon3,$00
colm24:	ds.w	32*2
        dc.l	-2
	endc

;========= mode 25, 320x180, 5 bit (OCS) + copper colours 0, 25..31
LINECOLMODE25 Macro   
		dc.b	$45+\1,$0f,$ff,$fe	; wait for line start	; 4 Bytes
		dc.w	$180,0		 ; col 0                        	; 4 Bytes	-> write at 6 (col 0)
		dc.w	$1b2,0		 ; col 25                     	; 4 Bytes   -> 10,14,18,22,26,30,34 (cols 25..31)
		dc.w	$1b4,0		 ; col 26                        ; 4 Bytes
      dc.w	$1b6,0		 ; col 27                     	; 4 Bytes
      dc.w	$1b8,0		 ; col 28                     	; 4 Bytes
      dc.w	$1ba,0		 ; col 29                     	; 4 Bytes
      dc.w	$1bc,0		 ; col 30                        ; 4 Bytes
      dc.w	$1be,0		 ; col 31                        ; 4 Bytes  // block end: 36
        EndM
	

   ifnd	NOMODE25
Copm25:
        dc.w    fmode,$0,bplcon3,$0	; $f, $60
	dc.w    diwstrt,$4581,diwstop,$f9c1	;	16:9-Größe	180er Höhe LastTrain
        ;dc.w    ddfstrt,$38,ddfstop,$a0
        dc.w    ddfstrt,$38,ddfstop,$d0

	dc.w	bplcon0,%0101001000000000	; 5 bitplanes laced	(bit2)
	dc.w	bplcon1,0
        dc.w    bplcon2,$0	;$3f  KILLEHB at bit 9 ($200)
	dc.w	bplcon4,$0	;$ff
	dc.w	bpl1mod,0
	dc.w	bpl2mod,0
	
sprm25:	dc.w $120,0,$122,0
	dc.w $124,0,$126,0
	dc.w $128,0,$12a,0
	dc.w $12c,0,$12e,0
	dc.w $130,0,$132,0
	dc.w $134,0,$136,0
	dc.w $138,0,$13a,0
	dc.w $13c,0,$13e,0
	
   dc.w	bplcon3,$00
   dc.w	$106,$0C00	 ; bank 0, MSB, for AGA compatibility
   
   
coplinesm25:	
t_colsm25_start:	
	LINECOLMODE25 0
t_colsm25_end:

LINECOLMODE25_LENGTH= (t_colsm25_end-t_colsm25_start)	
	; use coplinesm25+LINECOLMODE25_LENGTH*Line to write to registers
	LINECOLMODE25 1
	LINECOLMODE25 2
	LINECOLMODE25 3
	LINECOLMODE25 4
	LINECOLMODE25 5
	LINECOLMODE25 6
	LINECOLMODE25 7
	LINECOLMODE25 8
	LINECOLMODE25 9

	LINECOLMODE25 10
	LINECOLMODE25 11
	LINECOLMODE25 12
	LINECOLMODE25 13
	LINECOLMODE25 14
	LINECOLMODE25 15
	LINECOLMODE25 16
	LINECOLMODE25 17
	LINECOLMODE25 18
	LINECOLMODE25 19

	LINECOLMODE25 20
	LINECOLMODE25 21
	LINECOLMODE25 22
	LINECOLMODE25 23
	LINECOLMODE25 24
	LINECOLMODE25 25
	LINECOLMODE25 26
	LINECOLMODE25 27
	LINECOLMODE25 28
	LINECOLMODE25 29

	LINECOLMODE25 30
	LINECOLMODE25 31
	LINECOLMODE25 32
	LINECOLMODE25 33
	LINECOLMODE25 34
	LINECOLMODE25 35
	LINECOLMODE25 36
	LINECOLMODE25 37
	LINECOLMODE25 38
	LINECOLMODE25 39

	LINECOLMODE25 40
	LINECOLMODE25 41
	LINECOLMODE25 42
	LINECOLMODE25 43
	LINECOLMODE25 44
	LINECOLMODE25 45
	LINECOLMODE25 46
	LINECOLMODE25 47
	LINECOLMODE25 48
	LINECOLMODE25 49

	LINECOLMODE25 50
	LINECOLMODE25 51
	LINECOLMODE25 52
	LINECOLMODE25 53
	LINECOLMODE25 54
	LINECOLMODE25 55
	LINECOLMODE25 56
	LINECOLMODE25 57
	LINECOLMODE25 58
	LINECOLMODE25 59

	LINECOLMODE25 60
	LINECOLMODE25 61
	LINECOLMODE25 62
	LINECOLMODE25 63
	LINECOLMODE25 64
	LINECOLMODE25 65
	LINECOLMODE25 66
	LINECOLMODE25 67
	LINECOLMODE25 68
	LINECOLMODE25 69

	LINECOLMODE25 70
	LINECOLMODE25 71
	LINECOLMODE25 72
	LINECOLMODE25 73
	LINECOLMODE25 74
	LINECOLMODE25 75
	LINECOLMODE25 76
	LINECOLMODE25 77
	LINECOLMODE25 78
	LINECOLMODE25 79

	LINECOLMODE25 80
	LINECOLMODE25 81
	LINECOLMODE25 82
	LINECOLMODE25 83
	LINECOLMODE25 84
	LINECOLMODE25 85
	LINECOLMODE25 86
	LINECOLMODE25 87
	LINECOLMODE25 88
	LINECOLMODE25 89

	LINECOLMODE25 90
	LINECOLMODE25 91
	LINECOLMODE25 92
	LINECOLMODE25 93
	LINECOLMODE25 94
	LINECOLMODE25 95
	LINECOLMODE25 96
	LINECOLMODE25 97
	LINECOLMODE25 98
	LINECOLMODE25 99
	
	LINECOLMODE25 100
	LINECOLMODE25 101
	LINECOLMODE25 102
	LINECOLMODE25 103
	LINECOLMODE25 104
	LINECOLMODE25 105
	LINECOLMODE25 106
	LINECOLMODE25 107
	LINECOLMODE25 108
	LINECOLMODE25 109

	LINECOLMODE25 110
	LINECOLMODE25 111
	LINECOLMODE25 112
	LINECOLMODE25 113
	LINECOLMODE25 114
	LINECOLMODE25 115
	LINECOLMODE25 116
	LINECOLMODE25 117
	LINECOLMODE25 118
	LINECOLMODE25 119

	LINECOLMODE25 120
	LINECOLMODE25 121
	LINECOLMODE25 122
	LINECOLMODE25 123
	LINECOLMODE25 124
	LINECOLMODE25 125
	LINECOLMODE25 126
	LINECOLMODE25 127
	LINECOLMODE25 128
	LINECOLMODE25 129

	LINECOLMODE25 130
	LINECOLMODE25 131
	LINECOLMODE25 132
	LINECOLMODE25 133
	LINECOLMODE25 134
	LINECOLMODE25 135
	LINECOLMODE25 136
	LINECOLMODE25 137
	LINECOLMODE25 138
	LINECOLMODE25 139

	LINECOLMODE25 140
	LINECOLMODE25 141
	LINECOLMODE25 142
	LINECOLMODE25 143
	LINECOLMODE25 144
	LINECOLMODE25 145
	LINECOLMODE25 146
	LINECOLMODE25 147
	LINECOLMODE25 148
	LINECOLMODE25 149
	
	LINECOLMODE25 150
	LINECOLMODE25 151
	LINECOLMODE25 152
	LINECOLMODE25 153
	LINECOLMODE25 154
	LINECOLMODE25 155
	LINECOLMODE25 156
	LINECOLMODE25 157
	LINECOLMODE25 158
	LINECOLMODE25 159

	LINECOLMODE25 160
	LINECOLMODE25 161
	LINECOLMODE25 162
	LINECOLMODE25 163
	LINECOLMODE25 164
	LINECOLMODE25 165
	LINECOLMODE25 166
	LINECOLMODE25 167
	LINECOLMODE25 168
	LINECOLMODE25 169

	LINECOLMODE25 170
	LINECOLMODE25 171
	LINECOLMODE25 172
	LINECOLMODE25 173
	LINECOLMODE25 174
	LINECOLMODE25 175
	LINECOLMODE25 176
	LINECOLMODE25 177
	LINECOLMODE25 178
	LINECOLMODE25 179
   
	; 2) letzte Zeile ($45+179) ist $f8, $df ist rechts ziemlich am ende
	dc.w	$f8df,$fffe	; eigentlich müsste $e2 oder $e0 noch gehen, tut  aber nicht
	dc.w	$0106,$0C00		; also den copper einfach was sinnloses machen lassen (bank switch)
	dc.w	$0106,$0C00		; ""
   dc.w	$0106,$0C00
   dc.w	$0106,$0C00


colm25:	ds.w	32*2
        dc.l	-2
	endc
