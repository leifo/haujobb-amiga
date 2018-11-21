UnpackLZH:
;In:  a0 - Source
;     a1 - Destination
;Out: a0 - 0=Error

lzh_Savety		= 16			; Sicherheitabstand

	movem.l	d0-a6,-(sp)
;	lea	CrData+4+2,a2			; Hole den Header
	lea	6(a0),a2
	move.l	(a2)+,d1			; Hole ungepackte Länge
	move.l	(a2)+,d2			; Hole gepackte Länge
						; a2 steht nun auf 'Source'
;	lea	Wohin,a1			; a1 steht auf 'Destination'
	lea	.lzhBuffer+2(pc),a6			; a6 auf den Buffer

	bsr.b	.LZHDecrunch			; und decrunchen
	movem.l	(sp)+,d0-a6
	rts					; und tschüß

	; »»» Diese Routine entpackt Daten, die mit der
	; »»» 'lzh' CrunchMania-Methode gepackt wurden!
	; »»»
	; »»» d1 = Länge des Originals
	; »»» d2 = Länge des Gecrunchten
	; »»» a1 = Destination (wohin mit dem ENTpackten)
	; »»» a2 = Source (wo ist das Gepackte, hinter dem Header)
	; »»» a6 = Zeiger auf einen 1248 Byte großen Buffer

.lzhEnde
	rts					; und tschüß

.LZHDecrunch
	add.l	d1,a1				; Addiere DLänge zur Dest
	add.l	d2,a2				; Addiere SLänge zum Source

	move	-(a2),d0			; Hole den 1. Wert
	move.l	-(a2),d6			; Hole den 2. Wert

	moveq	#16,d7				; d7 = 16 (maximale Bitanzahl)
	sub	d0,d7				; Bitanzahl abziehen

	lsr.l	d7,d6				; Rotiere um x Bits
	move	d0,d7				; d7 = d0 (Bitanzahl)

	moveq	#16,d3				; d3 = 16 (maximale Bitanzahl)
	bra.w	.lzhLab_20			; und los geht's

.lzhLab_01
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.w	.lzhLab_18			; Ja -> Springen

.lzhLab_02
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.w	.lzhLab_18			; Ja -> Springen

.lzhLab_03
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.w	.lzhLab_18			; Ja -> Springen

.lzhLab_04
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.w	.lzhLab_18			; Ja -> Springen

.lzhLab_05
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.b	.lzhLab_18			; Ja -> Springen

.lzhLab_06
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.b	.lzhLab_18			; Ja -> Springen

.lzhLab_07
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.b	.lzhLab_18			; Ja -> Springen

.lzhLab_08
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.b	.lzhLab_18			; Ja -> Springen

.lzhLab_09
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.b	.lzhLab_18			; Ja -> Springen

.lzhLab_10
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.b	.lzhLab_18			; Ja -> Springen

.lzhLab_11
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.b	.lzhLab_18			; Ja -> Springen

.lzhLab_12
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.b	.lzhLab_18			; Ja -> Springen

.lzhLab_13
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.b	.lzhLab_18			; Ja -> Springen

.lzhLab_14
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.b	.lzhLab_18			; Ja -> Springen

.lzhLab_15
	subq	#1,d7				; Einen abziehen
	lsr.l	#1,d6				; um einen rotieren
	addx	d1,d1				; d1 = d1 << 1 + Bit
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bmi.b	.lzhLab_18			; Ja -> Springen

.lzhLab_16
	moveq	#16,d7				; d7 = 16

.lzhLab_17
	move	d6,d0				; d0 = d6
	lsr.l	#1,d6				; um einen shiften
	addx	d1,d1				; d1 = d1 << 1 + Bit

	swap	d6				; Es wird ein neuer
	move	-(a2),d6			; Wert in's obere
	swap	d6				; Wort gelesen...
		
	cmp	(a4)+,d1			; Kleiner als Wert ???
	bpl.w	.lzhLab_01			; Nein -> Springen

.lzhLab_18
	add	64-2(a4),d1			; Hole den Wert nach d2
	add	d1,d1				; und gleich mit 2 malnehmen
	move	(a0,d1.w),d0			; Hole einen anderen Wert
	rts					; und tschüß

.lzhTab_01
	dc.b	(.lzhLab_16-.lzhLab_17)		; neg. Offset zu Label #16
	dc.b	(.lzhLab_15-.lzhLab_17)		; neg. Offset zu Label #15
	dc.b	(.lzhLab_14-.lzhLab_17)		; neg. Offset zu Label #14
	dc.b	(.lzhLab_13-.lzhLab_17)		; neg. Offset zu Label #13
	dc.b	(.lzhLab_12-.lzhLab_17)		; neg. Offset zu Label #12
	dc.b	(.lzhLab_11-.lzhLab_17)		; neg. Offset zu Label #11
	dc.b	(.lzhLab_10-.lzhLab_17)		; neg. Offset zu Label #10
	dc.b	(.lzhLab_09-.lzhLab_17)		; neg. Offset zu Label #09
	dc.b	(.lzhLab_08-.lzhLab_17)		; neg. Offset zu Label #08
	dc.b	(.lzhLab_07-.lzhLab_17)		; neg. Offset zu Label #07
	dc.b	(.lzhLab_06-.lzhLab_17)		; neg. Offset zu Label #06
	dc.b	(.lzhLab_05-.lzhLab_17)		; neg. Offset zu Label #05
	dc.b	(.lzhLab_04-.lzhLab_17)		; neg. Offset zu Label #04
	dc.b	(.lzhLab_03-.lzhLab_17)		; neg. Offset zu Label #03
	dc.b	(.lzhLab_02-.lzhLab_17)		; neg. Offset zu Label #02
	dc.b	(.lzhLab_01-.lzhLab_17)		; neg. Offset zu Label #01

.lzhLab_19
	moveq	#-1,d0				; d0 = -1 (negativ machen)
	move.b	.lzhTab_01-1(pc,d7.w),d0	; Hole das Offset
	moveq	#0,d1				; d1 = 0
	jmp	.lzhLab_17(pc,d0.w)		; und springen

.lzhLab_20
				; »»» Lösche den Buffer

	lea	1182(a6),a0			; a0 = 64 Byte vor'm Ende
	moveq	#64/4-1,d2			; d2 = 15

.lzhClear_01
	clr.l	(a0)+				; Lösche ein LangWort
	dbf	d2,.lzhClear_01			; Fertig ???

				; »»» Installiere den Buffer

	lea	1214(a6),a0			; a0 = 32 Byte vor'm Ende
	lea	158(a6),a4			; a4 = Irgendwohin setzen
	moveq	#9,d2				; d2 = 9
	bsr.w	.lzhCreate_01			; Installieren

	lea	1182(a6),a0			; a0 = 64 Byte vor'm Ende
	lea	128(a6),a4			; a4 = Irgendwohin setzen
	moveq	#4,d2				; d2 = 4
	bsr.w	.lzhCreate_01			; Installieren

	lea	1214(a6),a3			; a3 = 32 Byte vor'm Ende
	lea	0-2(a6),a4			; a4 = Irgendwohin setzen
	bsr.w	.lzhCreate_02			; Installieren

	lea	1182(a6),a3			; a3 = 64 Byte vor'm Ende
	lea	32-2(a6),a4			; a4 = Irgendwohin setzen
	bsr.w	.lzhCreate_02			; Installieren

				; »»» Und los geht's

	moveq	#16,d1				; d1 = 16
	bsr.b	.lzhGetSomeBits			; uns los geht's

	move	d0,d5				; d5 = d0
	lea	158(a6),a0			; Hole einen Punkt
	lea	128(a6),a5			; a5 = Irgendwas

.lzhLab_22
	move.l	a6,a4				; Speicher -> a4
	bsr.b	.lzhLab_19			; und los geht's

	btst	#8,d0				; Ist Bit#8 gesetzt ???
	bne.b	.lzhLab_25			; Nein -> Springen

	move	d0,d4				; d4 = d0
	exg	a0,a5				; a0 <-> a5

	lea	32(a6),a4			; Hole neue Addresse
	bsr.b	.lzhLab_19			; und los geht's

	exg	a0,a5				; a0 <-> a5

	move	d0,d1				; d1 = d0 (Bitanzahl)
	move	d0,d2				; d2 = d0
	bne.b	.lzhLab_23			; d0 <> 0 -> Springen

	moveq	#1,d1				; d1 = 1 (Bitanzahl)
	moveq	#16,d2				; d2 = 16

.lzhLab_23
	bsr.b	.lzhGetSomeBits			; Hole die Bits nach d0
	bset	d2,d0				; Setze das Bit in d0

	lea	1(a1,d0.w),a3			; Errechne die Addresse

.lzhLab_24

	move.b	-(a3),-(a1)			; Kopiere das Byte
	dbf	d4,.lzhLab_24			; Alle Bytes geschafft ???
			move	$dff006,$dff180	;!!!
			;move	$dff106,$dff180	;!!!
			;move	#$f0,$dff180

	move.b	-(a3),-(a1)			; Noch ein Byte
	move.b	-(a3),d0			; Und das letzte Byte nach d0

.lzhLab_25
	move.b	d0,-(a1)			; Schreibe das Byte
	dbf	d5,.lzhLab_22			; Alles Bytes geschrieben ???

	moveq	#1,d1				; d1 = 1
	bsr.b	.lzhGetSomeBits			; Verarbeiten
	bne.w	.lzhLab_20			; Nochmal -> Springen

	bra.w	.lzhEnde			; und tschüß

		; »»» Diese Routine holt mehrere Bits
		; »»» (durch d1 angegeben) nach d0
		; »»» und holt notfalls neue Bits nach...

.lzhGetSomeBits
	move	d6,d0				; d0 = Control-Wort
	lsr.l	d1,d6				; Um x Bits verschieben
	sub	d1,d7				; d1 von Bitanzahl abziehen
	bgt.b	.lzhNoNewWord			; neues Wort unnötig -> Springen

	add	d3,d7				; d3 addieren
	ror.l	d7,d6				; rotieren
	move	-(a2),d6			; Neues Control-Wort holen
	rol.l	d7,d6				; zurückrotieren

.lzhNoNewWord
	add	d1,d1				; d1 *= 2
	and	.lzhTab_02-2(pc,d1.w),d0	; Maskieren
	rts					; und tschüß

.lzhTab_02					; Ausmaskierungs-Tabelle
	dc.w	$0001,$0003,$0007,$000f
	dc.w	$001f,$003f,$007f,$00ff
	dc.w	$01ff,$03ff,$07ff,$0fff
	dc.w	$1fff,$3fff,$7fff,$ffff

		; »»» Die beiden folgenden  Routinen
		; »»» sind dazu da, um den Buffer zu
		; »»» erstellen/errechnen...

.lzhCreate_01
	movem.l	d1-d5/a3,-(a7)			; Merke alle Register

	moveq	#4,d1				; d1 = 4 (Bitanzahl)
	bsr.b	.lzhGetSomeBits			; Hole die Bits nach d0

	move	d0,d5				; d5 = d0 (Anzahl)
	subq	#1,d5				; einen abziehen
	moveq	#0,d4				; d4 = 0
	sub.l	a3,a3				; a3 = 0

.lzcLoop_01
	addq	#1,d4				; d4 erhöhen
	move	d4,d1				; und nach d1 damit

	cmp	d2,d1				; Größer als Maximum ???
	ble.b	.lzcLab_01			; Nein -> Überspringen

	move	d2,d1				; Ja   -> Maximum setzen

.lzcLab_01
	bsr.b	.lzhGetSomeBits			; Hole die Bits nach d0

	move	d0,(a0)+			; Trage d0 ein
	add	d0,a3				; Addiere zu a3
	dbf	d5,.lzcLoop_01			; Alle Blöcke geschafft ???

	move	a3,d5				; Anzahl -> d5
	subq	#1,d5				; einen abziehen

.lzcLoop_02
	move	d2,d1				; d1 = d2 (Bitanzahl)
	bsr.b	.lzhGetSomeBits			; Hole die Bits nach d0
	move	d0,(a4)+			; Trage den Wert ein
	dbf	d5,.lzcLoop_02			; Alle WORDs geschafft ???

	movem.l	(a7)+,d1-d5/a3			; Hole die Register zurück
	rts					; und tschüß

		; »»» 2. Routine

.lzhCreate_02
	movem.l	d0-d7,-(a7)			; Merke die Register

	clr	(a4)+				; Lösche das Wort
	moveq	#14,d7				; d7 = 14
	moveq	#-1,d4				; d4 = -1
	moveq	#0,d2				; d2 = 0
	moveq	#0,d3				; d3 = 0
	moveq	#1,d1				; d1 = 1

.lzcLoop_03
	move	(a3)+,d6			; Hole das Wort

	move	d3,64(a4)			; Trage den Wert ein
	move	-2(a4),d0			; Hole den alten Wert
	add	d0,d0				; d0 *= 2
	sub	d0,64(a4)			; abziehen

	add	d6,d3				; d6 zu d3 addieren
	mulu	d1,d6				; mit d1 malnehmen

	add	d6,d2				; d6 zu d2 addieren
	move	d2,(a4)+			; und d2 eintragen
	lsl	#1,d2				; d2 shiften
	dbf	d7,.lzcLoop_03			; Alle geschafft ???

	movem.l	(a7)+,d0-d7			; Hole die Register zurück
	rts					; und tschüß

.lzhBuffer					; und Platz für Daten
	ds.b	1248


