; von a0 nach a1
	include	wos_defines.i
s:
	rts				;Init (Offset 0)
	rts
	bra	_chunky2planar		;Main (Offset 4)
	rts				;Exit (Offset 8)
	rts
	rts				;QBlit (Offset 12) 
	rts

plsiz=640*400/8
_chunky2planar:
	move.l	#256000,d0
.lp	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.lp
	rts

	        movem.l d2-d7/a2-a6,-(sp)

                move.w  sp,d0
                and.w   #2,d0
                add.w   #32,d0          ; make room on stack for
                suba.w  d0,sp           ; 32-byte longword aligned buffer
                movea.l sp,a3           ; pointed to by a3
                move.w  d0,-(sp)        ; and save the allocated size
                move.w  #plsiz/4,-(sp)  ; outer loop counter on stack

        iflt 4*plsiz-4-32768
                adda.w  #3*plsiz,a1     ; a1 -> start of plane 3
        else
        iflt 2*plsiz-4-32768
                adda.w  #1*plsiz,a1     ; a1 -> start of plane 1
        endc
        endc

; set up register constants

                move.l  #$0f0f0f0f,d5   ; d5 = constant $0f0f0f0f
                move.l  #$55555555,d6   ; d6 = constant $55555555
                move.l  #$3333cccc,d7   ; d7 = constant $3333cccc
                lea     (4,a3),a2       ; used for inner loop end test

; load up address registers with buffer ptrs

                lea     (2*4,a3),a4     ; a4 -> plane2buf
                lea     (2*4,a4),a5     ; a5 -> plane4buf
                lea     (2*4,a5),a6     ; a6 -> plane6buf

; main loop (starts here) processes 8 chunky pixels at a time

mainloop:

; d0 = a7a6a5a4a3a2a1a0 b7b6b5b4b3b2b1b0 c7c6c5c4c3c2c1c0 d7d6d5d4d3d2d1d0

                move.l  (a0)+,d0        ; 12 get next 4 chunky pixels in d0

; d1 = e7e6e5e4e3e2e1e0 f7f6f5f4f3f2f1f0 g7g6g5g4g3g2g1g0 h7h6h5h4h3h2h1h0

                move.l  (a0)+,d1        ; 12 get next 4 chunky pixels in d1

; d2 = d0 & 0f0f0f0f
; d2 = ........a3a2a1a0 ........b3b2b1b0 ........c3c2c1c0 ........d3d2d1d0

                move.l  d0,d2           ;  4
                and.l   d5,d2           ;  8 d5=$0f0f0f0f

; d0 ^= d2
; d0 = a7a6a5a4........ b7b6b5b4........ c7c6c5c4........ d7d6d5d4........

                eor.l   d2,d0           ;  8

; d3 = d1 & 0f0f0f0f
; d3 = ........e3e2e1e0 ........f3f2f1f0 ........g3g2g1g0 ........h3h2h1h0

                move.l  d1,d3           ;  4
                and.l   d5,d3           ;  8 d5=$0f0f0f0f

; d1 ^= d3
; d1 = e7e6e5e4........ f7f6f5f4........ g7g6g5g4........ h7h6h5h4........

                eor.l   d3,d1           ;  8

; d2 = (d2 << 4) | d3
; d2 = a3a2a1a0e3e2e1e0 b3b2b1b0f3f2f1f0 c3c2c1c0g3g2g1g0 d3d2d1d0h3h2h1h0

                lsl.l   #4,d2           ; 16
                or.l    d3,d2           ;  8

; d0 = d0 | (d1 >> 4)
; d0 = a7a6a5a4e7e6e5e4 b7b6b5b4f7f6f5f4 c7c6c5c4g7g6g5g4 d7d6d5d4h7h6h5h4

                lsr.l   #4,d1           ; 16
                or.l    d1,d0           ;  8

; d3 = ((d2 & 33330000) << 2) | (swap(d2) & 3333cccc) | ((d2 & 0000cccc) >> 2)
; d3 = a1a0c1c0e1e0g1g0 b1b0d1d0f1f0h1h0 a3a2c3c2e3e2g3g2 b3b2d3d2f3f2h3h2

                move.l  d2,d3           ;  4
                and.l   d7,d3           ;  8 d7=$3333cccc
                move.w  d3,d1           ;  4
                clr.w   d3              ;  4
                lsl.l   #2,d3           ; 12
                lsr.w   #2,d1           ; 10
                or.w    d1,d3           ;  4
                swap    d2              ;  4
                and.l   d7,d2           ;  8 d7=$3333cccc
                or.l    d2,d3           ;  8

; d1 = ((d0 & 33330000) << 2) | (swap(d0) & 3333cccc) | ((d0 & 0000cccc) >> 2)
; d1 = a5a4c5c4e5e4g5g4 b5b4d5d4f5f4h5h4 a7a6c7c6e7e6g7g6 b7b6d7d6f7f6h7h6

                move.l  d0,d1           ;  4
                and.l   d7,d1           ;  8 d7=$3333cccc
                move.w  d1,d2           ;  4
                clr.w   d1              ;  4
                lsl.l   #2,d1           ; 12
                lsr.w   #2,d2           ; 10
                or.w    d2,d1           ;  4
                swap    d0              ;  4
                and.l   d7,d0           ;  8 d7=$3333cccc
                or.l    d0,d1           ;  8

; d2 = d1 >> 7
; d2 = ..............a5 a4c5c4e5e4g5g4b5 b4d5d4f5f4h5h4a7 a6c7c6e7e6g7g6..

                move.l  d1,d2           ;  4
                lsr.l   #7,d2           ; 22

; d0 = d1 & 55555555
; d0 = ..a4..c4..e4..g4 ..b4..d4..f4..h4 ..a6..c6..e6..g6 ..b6..d6..f6..h6

                move.l  d1,d0           ;  4
                and.l   d6,d0           ;  8 d6=$55555555

; d1 ^= d0
; d1 = a5..c5..e5..g5.. b5..d5..f5..h5.. a7..c7..e7..g7.. b7..d7..f7..h7..

                eor.l   d0,d1           ;  8

; d4 = d2 & 55555555
; d4 = ..............a5 ..c5..e5..g5..b5 ..d5..f5..h5..a7 ..c7..e7..g7....

                move.l  d2,d4           ;  4
                and.l   d6,d4           ;  8 d6=$55555555

; d2 ^= d4
; d2 = ................ a4..c4..e4..g4.. b4..d4..f4..h4.. a6..c6..e6..g6..

                eor.l   d4,d2           ;  8

; d1 = (d1 | d4) >> 1
; d1 = ................ a5b5c5d5e5f5g5h5 ................ a7b7c7d7e7f7g7h7

                or.l    d4,d1           ;  8
                lsr.l   #1,d1           ; 10

                move.b  d1,(4,a6)       ; 12 plane 7
                swap    d1              ;  4
                move.b  d1,(4,a5)       ; 12 plane 5

; d2 |= d0
; d2 = ................ a4b4c4d4e4f4g4h4 ................ a6b6c6d6e6f6g6h6

                or.l    d0,d2           ;  8

                move.b  d2,(a6)+        ;  8 plane 6
                swap    d2              ;  4
                move.b  d2,(a5)+        ;  8 plane 4

; d2 = d3 >> 7
; d2 = ..............a1 a0c1c0e1e0g1g0b1 b0d1d0f1f0h1h0a3 a2c3c2e3e2g3g2..

                move.l  d3,d2           ;  4
                lsr.l   #7,d2           ; 22

; d0 = d3 & 55555555
; d0 = ..a0..c0..e0..g0 ..b0..d0..f0..h0 ..a2..c2..e2..g2 ..b2..d2..f2..h2

                move.l  d3,d0           ;  4
                and.l   d6,d0           ;  8 d6=$55555555

; d3 ^= d0
; d3 = a1..c1..e1..g1.. b1..d1..f1..h1.. a3..c3..e3..g3.. b3..d3..f3..h3..

                eor.l   d0,d3           ;  8

; d4 = d2 & 55555555
; d4 = ..............a1 ..c1..e1..g1..b1 ..d1..f1..h1..a3 ..c3..e3..g3....

                move.l  d2,d4           ;  4
                and.l   d6,d4           ;  8 d6=$55555555

; d2 ^= d4
; d2 = ................ a0..c0..e0..g0.. b0..d0..f0..h0.. a2..c2..e2..g2..

                eor.l   d4,d2           ;  8

; d3 = (d3 | d4) >> 1
; d3 = ................ a1b1c1d1e1f1g1h1 ................ a3b3c3d3e3f3g3h3

                or.l    d4,d3           ;  8
                lsr.l   #1,d3           ; 10

                move.b  d3,(4,a4)       ; 12 plane 3
                swap    d3              ;  4
                move.b  d3,(4,a3)       ; 12 plane 1

; d2 = d2 | d0
; d2 = ................ a0b0c0d0e0f0g0h0 ................ a2b2c2d2e2f2g2h2

                or.l    d0,d2           ;  8

                move.b  d2,(a4)+        ;  8 plane 2
                swap    d2              ;  4
                move.b  d2,(a3)+        ;  8 plane 0

; test if stack buffers are full, loop back if not

                cmpa.l  a3,a2           ;  6
                bne.w   mainloop        ; 10    total=540 (67.5 cycles/pixel)

; move stack buffers to bitplanes (longword writes) and restore ptrs

        iflt 4*plsiz-4-32768                    ; a1 points into plane 3
                move.l  (a4),(a1)+              ; plane 3
                move.l  (a6),(4*plsiz-4,a1)     ; plane 7
                move.l  -(a6),(3*plsiz-4,a1)    ; plane 6
                move.l  (a5),(2*plsiz-4,a1)     ; plane 5
                move.l  -(a5),(1*plsiz-4,a1)    ; plane 4
                move.l  -(a4),(-1*plsiz-4,a1)   ; plane 2
                move.l  (a3),(-2*plsiz-4,a1)    ; plane 1
                move.l  -(a3),(-3*plsiz-4,a1)   ; plane 0
        else
        iflt 2*plsiz-4-32768                    ; a1 points into plane 1
                move.l  (a3),(a1)+              ; plane 1
                adda.l  #4*plsiz,a1
                move.l  (a6),(2*plsiz-4,a1)     ; plane 7
                move.l  -(a6),(1*plsiz-4,a1)    ; plane 6
                move.l  (a5),(0*plsiz-4,a1)     ; plane 5
                move.l  -(a5),(-1*plsiz-4,a1)   ; plane 4
                suba.l  #4*plsiz,a1
                move.l  (a4),(2*plsiz-4,a1)     ; plane 3
                move.l  -(a4),(1*plsiz-4,a1)    ; plane 2
                move.l  -(a3),(-1*plsiz-4,a1)   ; plane 0
        else
        iflt plsiz-32768                        ; a1 points into plane 0
                adda.l  #6*plsiz,a1
                move.l  (a6),(plsiz,a1)         ; plane 7
                move.l  -(a6),(a1)              ; plane 6
                move.l  (a5),(-plsiz,a1)        ; plane 5
                suba.l  #3*plsiz,a1
                move.l  -(a5),(plsiz,a1)        ; plane 4
                move.l  (a4),(a1)               ; plane 3
                move.l  -(a4),(-plsiz,a1)       ; plane 2
                suba.l  #3*plsiz,a1
                move.l  (a3),(plsiz,a1)         ; plane 1
                move.l  -(a3),(a1)+             ; plane 0
        else
                move.l  #plsiz,d0               ; a1 points into plane 0
                adda.l  #7*plsiz,a1
                move.l  (a6),(a1)               ; plane 7
                suba.l  d0,a1
                move.l  -(a6),(a1)              ; plane 6
                suba.l  d0,a1
                move.l  (a5),(a1)               ; plane 5
                suba.l  d0,a1
                move.l  -(a5),(a1)              ; plane 4
                suba.l  d0,a1
                move.l  (a4),(a1)               ; plane 3
                suba.l  d0,a1
                move.l  -(a4),(a1)              ; plane 2
                suba.l  d0,a1
                move.l  (a3),(a1)               ; plane 1
                suba.l  d0,a1
                move.l  -(a3),(a1)+             ; plane 0
        endc
        endc
        endc

; check if finished, go back for more

                sub.w   #1,(sp)
                bne.w   mainloop

; all done!  restore stack and return

                addq.w  #2,sp                   ; remove outer loop counter
                adda.w  (sp)+,sp                ; remove aligned 32-byte buffer
                movem.l (sp)+,d2-d7/a2-a6

                rts
e
