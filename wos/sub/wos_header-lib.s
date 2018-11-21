; [WOS1 - WOS_Server and WOS_Client (obsolete)]
; WOS2 - wosbase / _Main only
; WOS3 - wosbase / _Main,^_Init,^_Exit
; WOS4 - header hasn't changed, but v4 clients have different memory-routines

; LIB3 - calling _Main gives back a pointer to the LIB-Base in a0
;        to be more sure, d0<>0 means error

	bra.s	SkipWOSTag	;0	-> returns LIBBase in a0, d0=0 is OK
	dc.b	"LIB",4		;2
_Iptr	dc.l	0		;6	^_Init
_Eptr	dc.l	0		;10	^_Exit

SkipWOSTag:			
	cmp.l	#"wSER",(a0)
	bne.s	.nowos	

	lea	_Main,a0
	moveq	#0,d0
	rts

.nowos	moveq	#-1,d0		;can't cooperate with others than wSER
	sub.l	a0,a0		
	rts
