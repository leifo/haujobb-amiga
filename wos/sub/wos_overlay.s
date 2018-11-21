;WickedOS-Overlay Header (16.12.98) by NoName
;
;this is a modified version of OVS.ASM (heavily stripped)
;it doesn't have the functionality of ovs.asm but i didn't
;need that.
;
;using this code, you can write programms that have data
;attached to their load-file which won't be loaded at
;program-start. this enables you to have huge exes of 
;virtually any size. only the code will be loaded thou.
;i did this because i want to have my multiload demos as
;one file. once started i handle the whole attached
;data-area by myself.
;
;make you own overlay-exes like this:
; · write your normal program-code to NextModule
; · assemble and save the binary
; · go to shell
; · join it with OVL.BIN and your data (join program ovl.bin data to bigfat.exe)
;
;i will supply a batch and maybe a program later on which do this job
;
;Note: STREAM contains a filehandle to your own loadfile !!!


        section NTRYHUNK,CODE

* Now for the first word of the program.

FIRST   BRA.W NextModule

* This next word serves to identify the overlay
* supervisor to 'unloader'.

        DC.L       $ABCD                Special value


* The loader plants values in the next locations.

STREAM  DC.L       0                    Overlay input stream
OVTAB   DC.L       0                    Overlay table (Machine address)
HTAB    DC.L       0                    Hunk table    (BCPL address)
GLBVEC  DC.L       0                    Global vector (Machine address)


* WickedOS tag and fields and stuff

	dc.b	"WickedOS Overlay (16.12.98) by Leif 'NoName' Oppermann",0,0,0,0
        CNOP       0,4

	dc.b	"wOVL"			
	dc.l	0			;version
;	dc.l	wOVLEND-*		;needed for seeking the data...
	dc.l	0			;...filled in by the linker

	;...might be extended some day. wouldn't know why at the moment.
*
* The main code of the program.
*

NextModule
;	MOVEQ	#0,D0
;	RTS
;wOVLEND
	;...here follows the code of the WickedOS server

