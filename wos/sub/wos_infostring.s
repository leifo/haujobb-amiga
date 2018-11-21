;
; Wos_InfoString.s (04.06.98)
;
; This generates the text which will be shown if there are
; commandline arguments

	

f	macro
	dc.b	" ∑ "
	endm
INFO:

	dc.b    $1b,"[0m",$1b,"[31m",$1b,"[1m"	; Fett und Schwarz
	dc.b    "WickedOS "
	VERSION
	dc.b    $1b,"[0m"			; Normal
 	dc.b    " ("
 	DATUM
	dc.b    ") "	
	dc.b    $1b,"[32m"			; Weiﬂ
 	dc.b    "© Leif 'NoName' Oppermann"
	dc.b    $1b,"[0m",10	; Normal und Ende
	dc.b	10

	dc.b	"WickedOS is a client-server system that makes demo-coding easier.",10

	dc.b	"This is the "
	dc.b    $1b,"[0m",$1b,"[31m",$1b,"[1m"	; Fett und Schwarz
	dc.b    "hardware-hitting"
	dc.b    $1b,"[0m"			; Normal
	dc.b	" version featuring:",10,10


	ifd	DK3D
	f
	dc.b	"The full DK3D engine v1.32",10
	endc

;	ifnd	NO020C2P
;	f
;	dc.b	"68020/68030 optimized chunky to planar converters",10
;	endc
	ifnd	NO040C2P
	f
	dc.b	"68040/68060 optimized chunky to planar converters",10
	endc

	ifne	WOS_P61
	f
	dc.b	"The Player 6.104, CIA-timing",10
	endc
	ifne	WOS_TP3
	f
	dc.b	"Tracker Packer 3.101ﬂ, CIA-timing",10
	endc
	ifne	WOS_THX
	f
	dc.b	"THX 1.27, VBL-timing",10
	endc
	ifne	WOS_AHX
	f
	dc.b	"AHX 2.3d, VBL-timing",10
	endc
	
;	ifnd	NORELOC
;	f
;	dc.b	"Binary relocation-routine",10
;	endc

;	ifnd	CLIONLY
;	f
;	dc.b	"Workbench startup handler",10
;	endc


	ifnd	NOSPEEDYCHIP
	f
	dc.b	"Speedychip 1.0.6",10
	endc

	f
	dc.b	"vbcc/vasm link-layer",10

	ifd	FRAMESYNC
	f
	dc.b	"Framesync C2P",10
	endc

	ifd	OVERLAY
	f
	dc.b	"Overlay support",10
	endc

	dc.b	10
;	dc.b	"Check out http://come.to/lop if you are interested",10
;	dc.b	"Check out the roots at http://www.back2roots.org",10	
	dc.b	"http://haujobb.scene.org/",10	



	dc.b	0
	even
