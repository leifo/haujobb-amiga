; [WOS1 - WOS_Server and WOS_Client (obsolete)]
; WOS2 - wosbase / _Main only
; WOS3 - wosbase / _Main,^_Init,^_Exit
; WOS4 - header hasn't changed, but v4 clients have different memory-routines

	bra.s	SkipWOSTag	;0	-> _Main
	dc.b	"WOS",4		;2

	ifnd	INITHOOKPRESENT
_Iptr	dc.l	0		;6	^_Init
	else
_Iptr	dc.l	_Inithook	;6	^_Init
	endc

;	ifnd	EXITHOOKPRESENT	
_Eptr	dc.l	0		;10	^_Exit
;	else
;_Eptr	dc.l	_Exithook	;10	^_Exit
;	endc

SkipWOSTag:			
	cmp.l	#"wSER",(a0)
	bne.s	.nowos	

	jsr	_Main
	rts			;Return-Code is set by the effect

.nowos	moveq	#-1,d0
	rts
