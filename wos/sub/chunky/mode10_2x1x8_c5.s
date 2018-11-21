; mode 10 160x90 8 bit

        include wos_defines.i
s:
        bra     c2p2x1_8_cpu5_init      ;Init (Offset 0)
        bra     c2p2x1_8_cpu5           ;Main (Offset 4)
        rts                             ;Exit (Offset 8)
        rts
        rts				;QBlit(Offset 12)
        rts

; c2p2x1_8_cpu5
;
; Copy speed on 040-25
;
; Public version, share & enjoy

BPLX    set     160
BPLY    set     90
BPLSIZE set     BPLX*BPLY/8*2
CHUNKYXMAX set  BPLX
CHUNKYYMAX set  BPLY

; d0.w  chunkyx [chunky-pixels]
; d1.w  chunkyy [chunky-pixels]
; d2.w  (scroffsx) [screen-pixels]
; d3.w  scroffsy [screen-pixels]
; d4.w  (rowlen) [bytes] -- offset between one row and the next in a bpl
; d5.l  (bplsize) [bytes] -- offset between one row in one bpl and the next bpl

c2p2x1_8_cpu5_init
        movem.l d2-d3,-(sp)
        lea     c2p_datanew(pc),a0
        andi.l  #$ffff,d0
        mulu.w  d0,d3
        lsr.l   #3,d3
        move.l  d3,c2p_scroffs-c2p_data(a0)
        mulu.w  d0,d1
        move.l  d1,c2p_pixels-c2p_data(a0)
        movem.l (sp)+,d2-d3
        rts

; a0    c2pscreen
; a1    bitplanes

c2p2x1_8_cpu5
        movem.l d2-d7/a2-a6,-(sp)

        move.w  #.x2-.x,d0
        bsr     c2p_copyinitblock

        lea     c2p_data(pc),a2

        add.w   #BPLSIZE,a1
        add.l   c2p_scroffs-c2p_data(a2),a1

        move.l  #$55555555,d5

        move.l  #$00ff00ff,a6

        move.l  c2p_pixels-c2p_data(a2),a5
        add.l   a0,a5
        move.l  a1,a2
        add.l   #BPLSIZE*4,a2
        cmpa.l  a0,a3
        beq     .none

        move.l  (a0)+,d0
        move.l  (a0)+,d1
        move.l  (a0)+,d2
        move.l  (a0)+,d3

        swap    d2                      ; Swap 16x2
        move.w  d0,d7
        move.w  d2,d0
        move.w  d7,d2
        swap    d2

        swap    d3
        move.w  d1,d7
        move.w  d3,d1
        move.w  d7,d3
        swap    d3

        move.l  #$0f0f0f0f,d6
        move.l  d2,d7                   ; Swap 4x2
        lsr.l   #4,d7
        eor.l   d0,d7
        and.l   d6,d7
        eor.l   d7,d0
        lsl.l   #4,d7
        eor.l   d7,d2

        move.l  d3,d7
        lsr.l   #4,d7
        eor.l   d1,d7
        and.l   d6,d7
        eor.l   d7,d1
        lsl.l   #4,d7
        eor.l   d7,d3

        move.l  a6,d6
        move.l  d1,d7                   ; Swap 8x1, part 1
        lsr.l   #8,d7
        eor.l   d0,d7
        and.l   d6,d7
        eor.l   d7,d0
        lsl.l   #8,d7
        eor.l   d7,d1

        bra     .start
.x
        move.l  (a0)+,d0
        move.l  (a0)+,d1
        move.l  (a0)+,d2
        move.l  (a0)+,d3
        move.l  d7,(a2)+
        eor.l   d4,d7
        add.l   d4,d4
        eor.l   d7,d4

        swap    d2                      ; Swap 16x2
        move.w  d0,d7
        move.w  d2,d0
        move.w  d7,d2
        swap    d2
        move.l  d4,-BPLSIZE-4(a2)

        swap    d3
        move.w  d1,d7
        move.w  d3,d1
        move.w  d7,d3
        swap    d3

        move.l  a3,d4
        move.l  d4,d7
        lsr.l   #1,d7	;!
        eor.l   d4,d7
        and.l   d5,d7
        eor.l   d7,d4
        move.l  d4,BPLSIZE*2(a1)
        eor.l   d7,d4
        add.l   d7,d7
        eor.l   d7,d4

        move.l  #$0f0f0f0f,d6
        move.l  d2,d7                   ; Swap 4x2
        lsr.l   #4,d7
        eor.l   d0,d7
        and.l   d6,d7
        eor.l   d7,d0
        lsl.l   #4,d7
        eor.l   d7,d2
        move.l  d4,BPLSIZE(a1)

        move.l  d3,d7
        lsr.l   #4,d7
        eor.l   d1,d7
        and.l   d6,d7
        eor.l   d7,d1
        lsl.l   #4,d7
        eor.l   d7,d3

        move.l  a4,d4
        move.l  d4,d7
        lsr.l   #1,d7	;!
        eor.l   d4,d7
        and.l   d5,d7
        eor.l   d7,d4
        move.l  d4,(a1)+
        eor.l   d7,d4
        add.l   d7,d7
        eor.l   d7,d4

        move.l  a6,d6
        move.l  d1,d7                   ; Swap 8x1, part 1
        lsr.l   #8,d7
        eor.l   d0,d7
        and.l   d6,d7
        eor.l   d7,d0
        lsl.l   #8,d7
        eor.l   d7,d1
        move.l  d4,-BPLSIZE-4(a1)
.start

        move.l  #$33333333,d6
        move.l  d1,d7                   ; Swap 2x1, part 1
        lsr.l   #2,d7
        eor.l   d0,d7
        and.l   d6,d7
        eor.l   d7,d0
        lsl.l   #2,d7
        eor.l   d1,d7

        move.l  d0,d4
        lsr.l   #1,d4	;!
        eor.l   d0,d4
        and.l   d5,d4
        eor.l   d4,d0
        move.l  d0,BPLSIZE*2(a2)
        eor.l   d4,d0
        add.l   d4,d4
        eor.l   d4,d0

        move.l  a6,d6
        move.l  d3,d1                   ; Swap 8x1, part 2
        lsr.l   #8,d1
        eor.l   d2,d1
        and.l   d6,d1
        eor.l   d1,d2
        lsl.l   #8,d1
        eor.l   d1,d3

        move.l  d0,BPLSIZE(a2)

        move.l  #$33333333,d6
        move.l  d3,d1                   ; Swap 2x1, part 2
        lsr.l   #2,d1
        eor.l   d2,d1
        and.l   d6,d1
        eor.l   d1,d2
        lsl.l   #2,d1
        eor.l   d1,d3
        move.l  d2,a3
        move.l  d3,a4

        move.l  d7,d4
        lsr.l   #1,d4	;!
        eor.l   d7,d4
        and.l   d5,d4
        eor.l   d4,d7

        cmp.l   a0,a5
        bne     .x
.x2
        move.l  d7,(a2)+
        eor.l   d4,d7
        add.l   d4,d4
        eor.l   d7,d4
        move.l  d4,-BPLSIZE-4(a2)

        move.l  a3,d4
        move.l  d4,d7
        lsr.l   #1,d7	;!
        eor.l   d4,d7
        and.l   d5,d7
        eor.l   d7,d4
        move.l  d4,BPLSIZE*2(a1)
        eor.l   d7,d4
        add.l   d7,d7
        eor.l   d7,d4
        move.l  d4,BPLSIZE(a1)

        move.l  a4,d4
        move.l  d4,d7
        lsr.l   #1,d7	;!
        eor.l   d4,d7
        and.l   d5,d7
        eor.l   d7,d4
        move.l  d4,(a1)+
        eor.l   d7,d4
        add.l   d7,d7
        eor.l   d7,d4
        move.l  d4,-BPLSIZE-4(a1)

.none
        movem.l (sp)+,d2-d7/a2-a6
        rts

c2p_copyinitblock
        movem.l a0-a1,-(sp)
        lea     c2p_datanew(pc),a0
        lea     c2p_data(pc),a1
        moveq   #16-1,d0
.copy   move.l  (a0)+,(a1)+
        dbf     d0,.copy
        movem.l (sp)+,a0-a1
        rts

        cnop    0,4

c2p_data
c2p_scroffs dc.l 0
c2p_pixels dc.l 0
        ds.l    16

        cnop 0,4
c2p_datanew
        ds.l    16
e:
