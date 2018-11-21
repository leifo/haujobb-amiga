;*****************************************************************************
;* WOS_Defines.i by Leif Oppermann                                           *
;* This defines the wosbase-structure and the screen-dimensions              *
;*****************************************************************************

;Note: _W#? must not be modified. They are the branches to the functions.

	ifnd	WOS_DEFINES_I
WOS_DEFINES_I set 1

FILEVERSION=4

;-------------- Define the structure
        rsreset         ;Server and Client Structure are now in one

Struct_tag	rs.l    1
_WSetModeAndColors	rs.l	1	;d0 - screenmode d1 - brightness
					;a0 - ^buffer    a1 - ^palette
_WSetColors	rs.l	1	;a0 - ^palette / d0 - brightness
_WDisplay	rs.l    1	;view the current screenmode (no inputs)
_WCheckExit	rs.l	1
_WMouseX	rs.l	1
_WMouseY	rs.l	1
_WSetExit	rs.l	1
_WClearExit	rs.l	1
_WNoMode	rs.l	1
mode1init	rs.l    1
mode1c2p	rs.l    1
mode1exit	rs.l	1
mode2init	rs.l    1
mode2c2p	rs.l    1
mode2exit	rs.l	1
mode3init	rs.l    1
mode3c2p	rs.l    1
mode3exit	rs.l	1
mode4init	rs.l    1
mode4c2p	rs.l    1
mode4exit	rs.l	1
mode5init	rs.l    1
mode5c2p	rs.l    1
mode5exit	rs.l	1
_WInit		rs.l	1
mode1ptr        rs.l    1
mode2ptr        rs.l    1
mode3ptr        rs.l    1
mode4ptr        rs.l    1
mode5ptr        rs.l    1
L3_VBI		rs.l    1       
L3_Blitter	rs.l    1
_WVBIHook	rs.l	1
_WExit		rs.l	1
ATTNFLAGS	rs.w	1	;v0.36
CHIPREVBITS	rs.w	1
CPU		rs.w	1
AGA		rs.w	1
dk3dptr		rs.l	1	;v0.45
_WDecrunch	rs.l	1	;v0.48
_WInitwPAC	rs.l	1
_d0		rs.l	1	;v0.49
_d1		rs.l	1
_d2		rs.l	1
_d3		rs.l	1
_d4		rs.l	1
_d5		rs.l	1
_d6		rs.l	1
_d7		rs.l	1
_a0		rs.l	1
_a1		rs.l	1
_a2		rs.l	1
_a3		rs.l	1
_a4		rs.l	1
_a5		rs.l	1
_a6		rs.l	1
_WAllocChip	rs.l	1
_WAlloc		rs.l	1
_WErase		rs.l	1
_WEraseAll	rs.l	1
_WStart		rs.l	1
_WLength	rs.l	1
_WSYSAllocChip	rs.l	1
_WSYSAlloc	rs.l	1
_WSYSErase	rs.l	1
_WSYSEraseAll	rs.l	1
_WSYSStart	rs.l	1
_WSYSLength	rs.l	1
_WAllocAny	rs.l	1
_WAllocAnyChip	rs.l	1
_WSYSAllocAny	rs.l	1
_WSYSAllocAnyChip	rs.l	1
_WWaitVBL	rs.l	1	;v0.495
_WCallEfx	rs.l	1	;v0.497
_WSetScreen	rs.l	1	;v0.497b
_WError		rs.l	1	;v0.497f
_WPlayMod	rs.l	1	;v0.499
_WStopMod	rs.l	1
_WVolume	rs.l	1
_WGetPos	rs.l	1
_WNextVBI	rs.l	1
_WLoad		rs.l	1	;v0.5
_mmstabptr	rs.l	1	
mode6init	rs.l    1	;v0.54
mode6c2p	rs.l    1
mode6exit	rs.l	1
mode6ptr	rs.l	1
_WInitEfx	rs.l	1	;v0.55
_WExitEfx	rs.l	1	
_WCallEfxOnce	rs.l	1	
ownfh		rs.l	1
ownname		rs.l	1
owndata		rs.l	1
TOC		rs.l	1	;v0.56
TON		rs.l	1
_WLoadFrom	rs.l	1
_WPrint		rs.l	1
_WClearPlanes	rs.l	1
mode7init	rs.l    1	;v0.61
mode7c2p	rs.l    1
mode7exit	rs.l	1
mode7ptr	rs.l	1
coplist		rs.l	1
sprlist		rs.l	1	;v0.63
_WSetSprites	rs.l	1
_WEffectTracker	rs.l	1	;v0.7, a.k.a. v1.0/v1.01 as of 2000
mode8init	rs.l    1	;v1.02, ten years later, 320x180 8 bit
mode8c2p	rs.l    1
mode8exit	rs.l	1
mode8ptr	rs.l	1
mode9init	rs.l    1	;v1.03, new modes 9 - 13, 9 is: 320x90 8bit
mode9c2p	rs.l    1
mode9exit	rs.l	1
mode9ptr	rs.l	1
mode10init	rs.l    1	;160x90 8bit
mode10c2p	rs.l    1
mode10exit	rs.l	1
mode10ptr	rs.l	1
mode11init	rs.l    1	;160x90 18bit
mode11c2p	rs.l    1
mode11exit	rs.l	1
mode11ptr	rs.l	1
mode12init	rs.l    1	;640x180 8bit
mode12c2p	rs.l    1
mode12exit	rs.l	1
mode12ptr	rs.l	1
mode13init	rs.l    1	;640x360 8bit
mode13c2p	rs.l    1
mode13exit	rs.l	1
mode13ptr	rs.l	1
mode14init	rs.l    1	;320x180 6bit (with saturation as of 02.12.17)
mode14c2p	rs.l    1
mode14exit	rs.l	1
mode14ptr	rs.l	1
mode15init	rs.l    1	;320x180 upper 5bit (27.09.15)
mode15c2p	rs.l    1
mode15exit	rs.l	1
mode15ptr	rs.l	1
_WSetLine	rs.l	1
mode16init	rs.l    1	;320x180 8bit with 8 copper-colours (0, 249..255) freely configurable per line (07.10.15)
mode16c2p	rs.l    1
mode16exit	rs.l	1
mode16ptr	rs.l	1
_WSetCopper	rs.l	1
mode17init	rs.l    1	;220x180 15bit from 24bit argb buffer
mode17c2p	rs.l    1
mode17exit	rs.l	1
mode17ptr	rs.l	1
mode18init	rs.l    1	;220x180 15bit from 18bit argb buffer
mode18c2p	rs.l    1
mode18exit	rs.l	1
mode18ptr	rs.l	1
mode19init	rs.l    1	;220x90 15bit from 18bit argb buffer
mode19c2p	rs.l    1
mode19exit	rs.l	1
mode19ptr	rs.l	1
mode20init	rs.l    1	;220x180 18bit from 24bit argb buffer
mode20c2p	rs.l    1
mode20exit	rs.l	1
mode20ptr	rs.l	1
mode21init	rs.l    1	;220x180 18bit from 18bit argb buffer
mode21c2p	rs.l    1
mode21exit	rs.l	1
mode21ptr	rs.l	1
mode22init	rs.l    1	;220x90 18bit from 18bit argb buffer
mode22c2p	rs.l    1
mode22exit	rs.l	1
mode22ptr	rs.l	1
mode23init	rs.l    1	;220x180 12bit from 18bit argb buffer
mode23c2p	rs.l    1
mode23exit	rs.l	1
mode23ptr	rs.l	1
modeptrptr	rs.l	1	;points to mode#?ptr to allow setbuf
buf1ptr		rs.l	1	;two buffers required for framesync (parallel)
buf1stateptr	rs.l	1	;" (state changes will be written back)
buf2ptr		rs.l	1	;"
buf2stateptr	rs.l	1	;" (states 0: free, 1: c2p pending, 2: c2p)
_WSetBuffer	rs.l	1	;a0 - ^buffer
mode24init	rs.l    1	;320x180 5bit (OCS)
mode24c2p	rs.l    1
mode24exit	rs.l	1
mode24ptr	rs.l	1
mode25init	rs.l    1	;320x180 5bit (OCS) + copper cols 0, 25..31
mode25c2p	rs.l    1
mode25exit	rs.l	1
mode25ptr	rs.l	1
Struct_len	rs.l    1



;-------------- Set up the screen-dimensions
MakeMode	Macro	; Mode,XSize,YSize,XOff,YOff,RowLen,Multiplikator(for 2x2!)
			; \1   \2    \3    \4   \5   \6     \7 
mode\1xsize	set	\2
mode\1ysize	set	\3
mode\1xoff	set	\4
mode\1yoff	set	\5
mode\1rowlen	set	\6	; pixels per row in bytes (e.g. 40 for 320)
mode\1size	set	(\2/8)*\3*\7
		EndM

	MakeMode	1,320,200,0,0,40,1	;320x200
	MakeMode	2,320,100,0,0,40,1	;320x100 1x2
	MakeMode	3,160,100,0,0,40,2	;160x100 2x2
	MakeMode	4,640,200,0,0,80,1	;640x200 
	MakeMode	5,640,400,0,0,40,1	;640x400
	MakeMode	6,640,100,0,0,80,1	;160x100 2x2 18bit
	MakeMode	7,320,200,0,0,40,1	;320x200 64 cols
	
	MakeMode	8,320,180,0,0,40,1	;320x180
	MakeMode	9,320,90,0,0,40,1	;320x90 1x2
	MakeMode	10,160,90,0,0,40,2	;160x90  2x2

	MakeMode	11,640,90,0,0,80,1	;160x90 2x2 18bit
	MakeMode	12,640,180,0,0,80,1	;640x180 
	MakeMode	13,640,360,0,0,40,1	;640x360
	MakeMode	14,320,180,0,0,40,1	;320x180 - 6 bits with saturation
	MakeMode	15,320,180,0,0,40,1	;320x180 - upper 5 Bits
	MakeMode	16,320,180,0,0,40,1	;320x180 - with copper colours 0, 249..255

;	MakeMode	17,216*3,180,0,0,84,1	;216x100 - 15 bits mode
						; 84*8=672 pixels wide
						; 216*3=648

mode17xsize	set	220
mode17linexsize	set	256
mode17ysize	set	180
mode17xoff	set	0
mode17yoff	set	0
mode17rowlen	set	mode17linexsize*3/8	
mode17size	set	mode17rowlen*mode17ysize	;*4?

mode18xsize	set	220
mode18linexsize	set	256
mode18ysize	set	180
mode18xoff	set	0
mode18yoff	set	0
mode18rowlen	set	mode18linexsize*3/8	
mode18size	set	mode18rowlen*mode18ysize

mode19xsize	set	220
mode19linexsize	set	256
mode19ysize	set	90
mode19xoff	set	0
mode19yoff	set	0
mode19rowlen	set	mode18linexsize*3/8	
mode19size	set	mode18rowlen*mode18ysize

mode20xsize	set	220
mode20linexsize	set	256
mode20ysize	set	180
mode20xoff	set	0
mode20yoff	set	0
mode20rowlen	set	mode20linexsize*3/8	
mode20size	set	mode20rowlen*mode20ysize

mode21xsize	set	220
mode21linexsize	set	256
mode21ysize	set	180
mode21xoff	set	0
mode21yoff	set	0
mode21rowlen	set	mode21linexsize*3/8	
mode21size	set	mode21rowlen*mode21ysize

mode22xsize	set	220
mode22linexsize	set	256
mode22ysize	set	90
mode22xoff	set	0
mode22yoff	set	0
mode22rowlen	set	mode22linexsize*3/8
mode22size	set	mode22rowlen*mode22ysize

mode23xsize	set	220
mode23linexsize	set	256
mode23ysize	set	180
mode23xoff	set	0
mode23yoff	set	0
mode23rowlen	set	mode23linexsize*3/8	
mode23size	set	mode23rowlen*mode23ysize

	MakeMode	24,320,180,0,0,40,1	;320x180 - 5 bits
   MakeMode	25,320,180,0,0,40,1	;320x180 - 5 bits + copper


;-------------- For the replayers
;--- don't change, but use it for "replay" and "music" if you want
P61 = 1
TP3 = 2
THX = 4
AHX = 8

;--- use it like this:
;replay = TP33!P61!THX!THX2
;music = P61
;
;or alternatively: music=1 which is the same as   replay = P61 
;                                                  music = P61

	endc
