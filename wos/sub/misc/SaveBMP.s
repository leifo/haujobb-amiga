*sauve une image au format BMP 256 couleurs
*Darken, 31 août 1997
;==============================================================================
*d0,d1:dimensions
*a0:source,a1:destination
*a2:palette
SaveBMP:  
	move.w #"BM",(a1)+
	move.w #0,(a1)+ ;taille du fichier
	move.l #0,(a1)+
	move.l #$00003604,(a1)+ ;offsets de bits
	
	move.l #$00002800,(a1)+ ;sizeof
		
	move.w #0,(a1)+
	move.l d0,d2
	ror.w #8,d2
	move.w d2,(a1)+ ;largeur
		
	move.w #0,(a1)+
	move.l d1,d2
	ror.w #8,d2
	move.w d2,(a1)+ ;hauteur
		
	move.l #$100,(a1)+ ;planes
	move.b #$08,(a1)+ ;bits par pixel
	move.b #0,(a1)+
	move.w #0,(a1)+
		
	move.l #0,(a1)+
	move.l #0,(a1)+
	move.l #0,(a1)+
	move.l #0,(a1)+
		
	move.l #0,(a1)+
	move.w #0,(a1)+
		
*la palette:
	move.l #256-1,d7
.nextcol:		
	move.l (a2)+,d2
	move.b d2,(a1)+
	lsr.l #8,d2
	move.b d2,(a1)+
	
	
	lsr.l #8,d2
	move.b d2,(a1)+
	move.b #0,(a1)+
		
	dbf d7,.nextcol
*les données:
	move.l	d0,d2
	add.l	d0,d2	;x*2
	move.l	d0,d3	;x.bak
	
	sub.l #1,d0	
	sub.l #1,d1	;y

	muls.l	d1,d3	
	add.l	d3,a1

	move.l d1,d7
.nextline:
	move.l d0,d6
.nextpixel:		
	move.b (a0)+,(a1)+
	dbf d6,.nextpixel
	sub.l	d2,a1		;BMP`s are saved bottom up
	dbf d7,.nextline
	rts

AllocBMP MACRO
	ds.b 54+1024+\1
	ENDM

*\1:bufferBMP,\2:palette
SaveBMPscreen MACRO 
	move.l #LARGEUR,d0
	move.l #HAUTEUR,d1
	move.l adrchkdata,a0
	move.l \1,a1
	move.l \2,a2
	bsr.l SaveBMP
	ENDM
