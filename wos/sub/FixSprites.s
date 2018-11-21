
;	include "intuition/screens.i"
;	reworked the source for faster assembling


; This bit fixes problems with sprites in V39 kickstart
; it is only called if intuition.library opens, which in this
; case is only if V39 or higher kickstart is installed. If you
; require intuition.library you will need to change the
; openlibrary code to open V33+ Intuition and add a V39 test before
; calling this code (which is only required for V39+ Kickstart)
;

FixSpritesSetup:
        move.l   intbase,a6                 ; open intuition.library first!
        lea      wbname,a0
        jsr      -510(a6)	;_LVOLockPubScreen(a6)

        tst.l    d0                         ; Could I lock Workbench?
        beq.s    .error                     ; if not, error
        move.l   d0,wbscreen
        move.l   d0,a0

;	move.l   sc_ViewPort+vp_ColorMap(a0),a0
	move.l	48(a0),a0
	
        lea      taglist,a1
        move.l   gfxbase,a6                ; open graphics.library first!
        jsr      -708(a6)	;_LVOVideoControl(a6)       

        move.l   resolution,oldres          ; store old resolution

;	move.l   #SPRITERESN_140NS,resolution
        move.l   #1,resolution

        move.l   #$80000031,taglist	;VTAG_SPRITERESN_SET

        move.l   wbscreen,a0

;	move.l   sc_ViewPort+vp_ColorMap(a0),a0
	move.l	48(a0),a0
	
        lea      taglist,a1
        jsr      -708(a6)	;_LVOVideoControl(a6)       
        			; set sprites to lores

        move.l   wbscreen,a0
        move.l   intbase,a6
        jsr      _LVOMakeScreen(a6)
        jsr      _LVORethinkDisplay(a6)     ; and rebuild system copperlists

; Sprites are now set back to 140ns in a system friendly manner!

.error
        rts

ReturnSpritesToNormal:
; If you mess with sprite resolution you must return resolution
; back to workbench standard on return! This code will do that...

        move.l   wbscreen,d0
        beq.s    .error
        move.l   d0,a0

        move.l   oldres,resolution          ; change taglist
        lea      taglist,a1
;	move.l   sc_ViewPort+vp_ColorMap(a0),a0
	move.l	48(a0),a0
	
        move.l   gfxbase,a6
        jsr      -708(a6)	;_LVOVideoControl(a6)       
				; return sprites to normal.

        move.l   intbase,a6
        move.l   wbscreen,a0
        jsr      _LVOMakeScreen(a6)         ; and rebuild screen

        move.l   wbscreen,a1
        sub.l    a0,a0
        jsr      -516(a6)	;_LVOUnlockPubScreen(a6)

.error
        rts


oldres          dc.l  0
wbscreen        dc.l  0

taglist         dc.l  $80000032		;VTAG_SPRITERESN_GET
resolution      dc.l  0			;SPRITERESN_ECS
                dc.l  0,0		;TAG_DONE
wbname          dc.b  "Workbench",0

