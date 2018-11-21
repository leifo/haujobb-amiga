;start:
;        lea     tp_module(pc),a0
;        lea     tp_data(pc),a1
;        move.l  a0,(a1)
;        bsr.s   tp_init
;        bne.s   error
;wait:   btst    #6,$bfe001
;        bne.s   wait
;        bsr     tp_end
;error:  rts
	
;************************************************************************
;**                                                                    **
;**                TrackerPacker V3.101ß Replayroutine                 **
;**                                                                    **
;**         coded by CRAZY CRACK the BlitterBlaster of Complex         **
;**                                                                    **
;**                       last coding : 26.06.94                       **
;**                                                                    **
;************************************************************************

no=0
yes=1

VLB=1		;This Version needs the System to be killed. And you have to
		;jump to "tp_play" every Vertical Blank !
CIA=0		;This Version also needs the System to be killed. But will
		;replay the module on its own, as long as the level 6 Interrupt
		;is active.
SystemCIA=-1	;Yeah, and this one replays the Module with all the wonderful
		;advantages of real CIA-timing. And it uses real System-
		;interrupts for it. So it will run perfect with Multitasking !

replaymode=CIA    ;what kind of replaying do you want to use ?

pt1.1=no	;protracker v1.1 compatible (default=pt2.0)
syncs=yes	;do you use vibrato or tremolo with sync ?
funk=yes	;do you use the ef-comand ?
vbruse=yes	;use vectortableoffset ?
volume=yes	;use volumesliding ?
split=no	;use a splitted Song- and Samplefiles
choosestart=yes	;do you want to start the song from any other point than the
		;beginning ?
switch=no	;do you want to switch ON/OFF any voices ?
suck=yes	;das ya dick wanna b suckd ?
		;(sorry, haven't been implementated yet)

s:	;Jump-Table
	bra	tp_start	;0 - Init (a0=^Module, a1=VBR or 0)
	ifeq	replaymode-1
	bra	tp_play		;4 - Main, only for VBL
	else
	rts
	rts
	endc
	bra	tp_end		;8 - End
tp_volume:
	dc.w	255		;12 - 0=off,255=max. volume
tp_vbr:
	dc.l	0		;Init this just once (done by WOS now)

tp_start:
        lea     tp_data(pc),a2
        move.l  a0,(a2)
	lea	tp_vbr(pc),a2
	tst	a1
	beq.s	.skipvbr
	move.l	a1,(a2)
.skipvbr
	bsr.s   tp_init
	rts

tp_init:
        lea     tp_wait(pc),a0
        move    #1,(a0)
        clr     tp_pattcount-tp_wait(a0)
        move    #6,tp_speed-tp_wait(a0)
        move    #-1,tp_shitpon-tp_wait(a0)
        move.l  tp_data(pc),a1
        lea     28(a1),a1
        move    (a1)+,d7
        lea     (a1,d7.w),a2
        lsr     #3,d7
        move    (a2)+,d0
        move.l  a2,tp_pattadr-tp_wait(a0)
        move.l  a2,tp_pattadr3-tp_wait(a0)
        moveq   #0,d1
        moveq   #0,d2
tp_initpattern:
        move    (a2)+,d1
        cmp     d1,d2
        bgt.s   tp_initpattok
        move    d1,d2
tp_initpattok:
        subq    #1,d0
        bne.s   tp_initpattern
        move.l  a2,tp_pattadr2-tp_wait(a0)
        move.l  a2,tp_pattlistadr-tp_wait(a0)
        lea     8(a2,d2.w),a2
        move    (a2)+,d0
        move.l  a2,tp_pattdataadr-tp_wait(a0)
        moveq   #30,d6
        sub     d7,d6
        subq    #1,d7
        lea     (a2,d0.w),a3
        ifne    split
        move.l  tp_samples(pc),a3
        endc
        move.l  a3,d5
        lea     tp_instlist(pc),a2
tp_initinst:
        moveq   #0,d0
        move.b  (a1)+,d0
        mulu    #72,d0
        add     #tp_notelist-tp_wait,d0
        move    d0,(a2)+
        moveq   #0,d0
        move.b  (a1)+,d0
        move    d0,(a2)+
        move.l  a3,(a2)+
        lea     (a3),a4
        moveq   #0,d0
        move    (a1)+,d0
        add     d0,a3
        add     d0,a3
        moveq   #0,d1
        move    (a1)+,d1
        add     d1,a4
        add     d1,a4
        move.l  a4,(a2)+
        move    d0,(a2)+
        move    (a1)+,(a2)+
        dbra    d7,tp_initinst
        tst     d6
        bmi.s   tp_initsamplesok
        moveq   #0,d0
        moveq   #1,d1
tp_sampleinitloop2:
        move.l  d0,(a2)+
        move.l  d5,(a2)+
        move.l  d5,(a2)+
        move.l  d1,(a2)+
        dbra    d6,tp_sampleinitloop2
tp_initsamplesok:

        ifne    choosestart
        move    tp_patternnumber(pc),d1
        bsr     tp_otherpattern
        endc

        moveq   #0,d0
        moveq   #63,d1
        lea     tp_voice0dat(pc),a1
        move.b  d0,51(a1)
        move    d1,52(a1)
        move.b  d0,51+58(a1)
        move    d1,52+58(a1)
        move.b  d0,51+116(a1)
        move    d1,52+116(a1)
        move.b  d0,51+174(a1)
        move    d1,52+174(a1)

        lea     $dff002,a5
        iflt    replaymode
        move.l  4.w,a6
        jsr     -132(a6)
        else
        move    #$2000,$98(a5)
        move    d0,$a6(a5)
        move    d0,$b6(a5)
        move    d0,$c6(a5)
        move    d0,$d6(a5)
        move    #$f,$94(a5)
        endc


        iflt    replaymode

        move.l  240(a6),a0      ;CIA B Interrupt serverstruktur
        move.l  (a0),a0         ;CIA B Interruptstruktur
        lea     -42(a0),a6      ;CIA-Resourcestruktur
        lea     tp_ciab_resource(pc),a1
        move.l  a6,(a1)
        moveq   #3,d0
        and.b   40(a6),d0
        beq.s   tp_ciaintfree
        move.l  4.w,a6
        jsr     -138(a6)
        moveq   #-1,d0
        rts
tp_ciaintfree:
        move    d0,$a6(a5)
        move    d0,$b6(a5)
        move    d0,$c6(a5)
        move    d0,$d6(a5)
        move    #$f,$94(a5)

        lea     $bfd000,a1
        ori.b   #2,$1001(a1)
        clr.b   $e00(a1)
        clr.b   $f00(a1)
        move.b  #$6b,$400(a1)
        move.b  #$37,$500(a1)
        move.b  #$6b,$600(a1)
        move.b  #1,$700(a1)
        move.b  #$7f,$d00(a1)
        move.b  #$83,$d00(a1)
        move.b  #$11,$e00(a1)

        lea     tp_ciab_timerastruktur+10(pc),a0
        lea     tp_timeraname(pc),a1
        move.l  a1,(a0)
        lea     tp_mainint(pc),a1
        move.l  a1,8(a0)
        lea     tp_timerbname(pc),a1
        move.l  a1,22(a0)
        lea     tp_dmaonint(pc),a1
        move.l  a1,30(a0)

        moveq   #0,d0
        lea     tp_ciab_timerastruktur(pc),a1
        jsr     -6(a6)
        moveq   #1,d0
        lea     tp_ciab_timerbstruktur(pc),a1
        jsr     -6(a6)
        else
        ifgt    replaymode
        lea     tp_dmaonint(pc),a2
        else
        lea     tp_mainint(pc),a2
        endc
        move.l  a2,tp_int1pon-tp_wait(a0)
        ifne    vbruse
        move.l  tp_vbr(pc),a1
        move.l  $78(a1),tp_oldint-tp_wait(a0)
        move.l  a2,$78(a1)
        else
        move.l  $78.w,tp_oldint-tp_wait(a0)
        move.l  a2,$78.w
        endc
        lea     tp_voiceloopint(pc),a2
        move.l  a2,tp_int3pon-tp_wait(a0)
        lea     $bfd000,a1
        ori.b   #2,$1001(a1)
        ifgt    replaymode
        clr.b   $e00(a1)
        endc
        clr.b   $f00(a1)
        ifgt    replaymode
        move.b  #$6b,$400(a1)
        move.b  #$37,$500(a1)
        endc
        move.b  #$6b,$600(a1)
        move.b  #1,$700(a1)
        move.b  #$7f,$d00(a1)
        ifgt    replaymode
        move.b  #$82,$d00(a1)
        else
        move.b  #$83,$d00(a1)
        move.b  #$11,$e00(a1)
        move    #$e000,$98(a5)
        endc
        endc

        iflt    replaymode
        move.l  4.w,a6
        jsr     -138(a6)
        moveq   #0,d0
        endc
        rts

tp_end:
        iflt    replaymode
        move.l  4.w,a6
        jsr     -132(a6)
        move.l  tp_ciab_resource(pc),a6
        moveq   #0,d0
        jsr     -12(a6)
        moveq   #1,d0
        jsr     -12(a6)
        lea     $dff002,a5
        else
        lea     $dff002,a5
        move    #$2000,$98(a5)
        ifne    vbruse
        move.l  tp_vbr(pc),a1
        move.l  tp_oldint(pc),$78(a1)
        else
        move.l  tp_oldint(pc),$78.w
        endc
        endc
        moveq   #0,d0
        move    d0,$a6(a5)
        move    d0,$b6(a5)
        move    d0,$c6(a5)
        move    d0,$d6(a5)
        move    #$f,$94(a5)
        iflt    replaymode
        move.l  4.w,a6
        jsr     -138(a6)
        endc
        rts

tp_mainint:
tp_play:
        movem.l d0-a5,-(a7)
        lea     $dff002,a5
        ifeq    replaymode
        move    #$2000,$9a(a5)
        btst    #0,$bfdd00
        beq     tp_nomainint
        endc
        moveq   #0,d4
        lea     tp_wait(pc),a0
        clr.b   tp_dmaon-tp_wait+1(a0)
        subq    #1,(a0)
        beq     tp_newline
tp_playeffects:
        lea     tp_voice0dat+6(pc),a1
        move    (a1)+,d0
        beq.s   tp_novoice1
        lea     $9e(a5),a3
        jsr     tp_fxplaylist-4(pc,d0.w)
tp_novoice1:
        lea     tp_voice1dat+6(pc),a1
        move    (a1)+,d0
        beq.s   tp_novoice2
        lea     $ae(a5),a3
        jsr     tp_fxplaylist-4(pc,d0.w)
tp_novoice2:
        lea     tp_voice2dat+6(pc),a1
        move    (a1)+,d0
        beq.s   tp_novoice3
        lea     $be(a5),a3
        jsr     tp_fxplaylist-4(pc,d0.w)
tp_novoice3:
        lea     tp_voice3dat+6(pc),a1
        move    (a1)+,d0
        beq.s   tp_novoice4
        lea     $ce(a5),a3
        jsr     tp_fxplaylist-4(pc,d0.w)
tp_novoice4:
        move.b  tp_dmaon+1(pc),d4
        ifne    funk
        beq     tp_funkit
        bra     tp_initnewsamples
        else
        bne     tp_initnewsamples
        movem.l (a7)+,d0-a5
        ifeq    replaymode
        nop
        rte
        else
        rts
        endc
        endc
tp_fxplaylist:
        bra     tp_voicefx1
        bra     tp_voicefx2
        bra     tp_voicefx3
        bra     tp_voicefx4
        bra     tp_voicefx5
        bra     tp_voicefx6
        bra     tp_voicefx7
        bra     tp_voicefx0
        bra     tp_voicefxe9do
        bra     tp_voicefxa
        bra     tp_voicefxecdo
        bra     tp_voicefxeddo

tp_newline:
        move    tp_speed(pc),(a0)
        tst     tp_pattdelay-tp_wait(a0)
        beq.s   tp_nopatterndelay
        subq    #1,tp_pattdelay-tp_wait(a0)
        bra     tp_playeffects
tp_nopatterndelay:
        tst     tp_pattrepeat-tp_wait(a0)
        bne.s   tp_repeatit
        subq    #1,tp_pattcount-tp_wait(a0)
        bpl     tp_playline
        move    #63,tp_pattcount-tp_wait(a0)
        move.l  tp_pattadr(pc),a1
        move    (a1)+,tp_pattadrpon-tp_wait(a0)
        cmp.l   tp_pattadr2(pc),a1
        blt.s   tp_pattadrok
        move.l  tp_pattadr3(pc),a1
tp_pattadrok:
        move.l  a1,tp_pattadr-tp_wait(a0)
tp_repeatit:
        clr     tp_pattrepeat-tp_wait(a0)
        move    tp_pattadrpon(pc),d0
        move.l  tp_pattlistadr(pc),a1
        movem   (a1,d0.w),d0-d3
        moveq   #-2,d4
        move.l  tp_pattdataadr(pc),a1
        move.b  d4,tp_voice0dat-tp_wait+1(a0)
        add.l   a1,d0
        move.l  d0,tp_voice0dat-tp_wait+2(a0)
        move.b  d4,tp_voice1dat-tp_wait+1(a0)
        add.l   a1,d1
        move.l  d1,tp_voice1dat-tp_wait+2(a0)
        move.b  d4,tp_voice2dat-tp_wait+1(a0)
        add.l   a1,d2
        move.l  d2,tp_voice2dat-tp_wait+2(a0)
        move.b  d4,tp_voice3dat-tp_wait+1(a0)
        add.l   a1,d3
        move.l  d3,tp_voice3dat-tp_wait+2(a0)

        move    tp_shitpon(pc),d0
        bne.s   tp_noshit
        moveq   #1,d0
        bra.s   tp_shit
tp_noshit:
        moveq   #0,d0
tp_shit:

        add     tp_newpattpos(pc),d0
        beq.s   tp_playline
        cmp.w   #64,d0
        bne.s   tp_pattinrange
        clr     tp_newpattpos-tp_wait(a0)
        clr     tp_pattcount-tp_wait(a0)
        moveq   #-1,d7
        move    d7,tp_shitpon-tp_wait(a0)
        bra     tp_nopatterndelay
tp_pattinrange:

        sub     d0,tp_pattcount-tp_wait(a0)
        clr     tp_newpattpos-tp_wait(a0)
        lea     tp_voice0dat+2(pc),a1
        subq    #1,d0
        moveq   #3,d7
tp_pattinitloop:
        move    d0,d6
        moveq   #0,d2
        move.l  (a1),a2
tp_pattsearchloop:
        move.b  (a2)+,d1
        bmi.s   tp_pattslab1
        moveq   #$f,d1
        and.b   (a2)+,d1
        beq.s   tp_pattslab3
        bra.s   tp_pattslab2
tp_pattslab1:
        add.b   d1,d1
        bpl.s   tp_pattslab2
        asr.b   #1,d1
        addq.b  #1,d1
        add.b   d1,d6
        bpl.s   tp_pattslab3
        add.b   d6,d6
        subq.b  #2,d6
        move    d6,d2
        moveq   #0,d6
        bra.s   tp_pattslab3
tp_pattslab2:
        addq.l  #1,a2
tp_pattslab3:
        dbra    d6,tp_pattsearchloop
        move.b  d2,-1(a1)
        move.l  a2,(a1)
        lea     58(a1),a1
        dbra    d7,tp_pattinitloop

tp_playline:
        move    #$1f0,d3
        move    #-1,tp_shitpon-tp_wait(a0)
        lea     tp_voice0dat+1(pc),a1
        addq.b  #2,(a1)+
        bmi.s   tp_playvoice0end
        moveq   #1,d4
        lea     $9e(a5),a3
        bsr     tp_playvoice
tp_playvoice0end:
        move    26(a1),$a4(a5)
        lea     tp_voice1dat+1(pc),a1
        addq.b  #2,(a1)+
        bmi.s   tp_playvoice1end
        moveq   #2,d4
        lea     $ae(a5),a3
        bsr     tp_playvoice
tp_playvoice1end:
        move    26(a1),$b4(a5)
        lea     tp_voice2dat+1(pc),a1
        addq.b  #2,(a1)+
        bmi.s   tp_playvoice2end
        moveq   #4,d4
        lea     $be(a5),a3
        bsr     tp_playvoice
tp_playvoice2end:
        move    26(a1),$c4(a5)
        lea     tp_voice3dat+1(pc),a1
        addq.b  #2,(a1)+
        bmi.s   tp_playvoice3end
        moveq   #8,d4
        lea     $ce(a5),a3
        bsr.s   tp_playvoice
tp_playvoice3end:
        move    26(a1),$d4(a5)
        move.b  tp_dmaon+1(pc),d4
tp_initnewsamples:
        ifne    switch
        move.b  tp_voiceoff(pc),d3
        not.b   d3
        and.b   d3,d4
        move.b  d4,tp_dmaon+1-tp_wait(a0)
        endc
        move    d4,$94(a5)
        ifeq    replaymode
        lea     tp_dmaonint(pc),a1
        ifne    vbruse
        move.l  tp_vbr(pc),a2
        move.l  a1,$78(a2)
        else
        move.l  a1,$78.w
        endc
        endc
        ifgt    replaymode
        move    #$e000,$98(a5)
        endc
        move.b  #$19,$bfdf00
        ifne    funk
tp_funkit:
        lea     tp_voice0dat+48(pc),a1
        moveq   #3,d7
tp_funkloop:
        move.b  (a1)+,d4
        beq.s   tp_funkend
        move.b  tp_funklist-tp_wait(a0,d4.w),d4
        add.b   d4,(a1)
        bpl.s   tp_funkend
        clr.b   (a1)
        move.l  -31(a1),a2
        movem   -25(a1),d0-d1
        addq    #1,d1
        add     d0,d0
        cmp     d0,d1
        blo.s   tp_funkok
        moveq   #0,d1
tp_funkok:
        not.b   (a2,d1.w)
        move    d1,-23(a1)
tp_funkend:
        lea     57(a1),a1
        dbra    d7,tp_funkloop
        endc
tp_nomainint:
        movem.l (a7)+,d0-a5
        ifeq    replaymode
        nop
        rte
        else
        rts
        endc
tp_playvoice:
        move.l  (a1)+,a2
        moveq   #0,d0
        move.b  (a2)+,d0
        bmi     tp_playnonewnote
        moveq   #0,d1
        move.b  (a2)+,d1
        moveq   #$f,d2
        and.b   d1,d2
        beq.s   tp_noeffect
        move.b  (a2)+,3(a1)
        add     d2,d2
        add     d2,d2
tp_noeffect:
        move    d2,(a1)
        add.b   d0,d0
        bpl.s   tp_noupperinst
        eor.b   #$fe,d0
        bset    #8,d1
tp_noupperinst:
        and     d3,d1
        beq.s   tp_nonewinst
        movem.l tp_instlist-tp_wait-16(a0,d1.w),d5-d7/a4
        movem.l d5-d7/a4,4(a1)

        ifne    switch
        move.b  tp_voiceoff(pc),d6
        and.b   d4,d6
        bne.s   tp_no1
        ifne    volume
        mulu    tp_volume(pc),d5
        lsr     #8,d5
        endc
        move    d5,8(a3)
tp_no1
	else
        ifne    volume
        mulu    tp_volume(pc),d5
        lsr     #8,d5
        endc
        move    d5,8(a3)
        endc

        ifne    funk
        clr     20(a1)
        endc
tp_nonewinst:
        move.l  a2,-(a1)
        tst     d0
        beq.s   tp_newnoteend
        jsr     tp_fxinitlist(pc,d2.w)
        add     8(a1),d0
        move    -2(a0,d0.w),26(a1)
        or.b    d4,tp_dmaon-tp_wait+1(a0)
        ifne    syncs
        tst.b   32(a1)
        beq.s   tp_novibnoc
        clr.b   35(a1)
tp_novibnoc:
        tst.b   38(a1)
        beq.s   tp_notremnoc
        clr.b   41(a1)
tp_notremnoc:
        endc
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   d4,d5
        bne.s   tp_no2
        move.l  12(a1),(a3)+
        move    20(a1),(a3)
tp_no2
	else
        move.l  12(a1),(a3)+
        move    20(a1),(a3)
        endc
        rts
tp_playnonewnote:
        add.b   d0,d0
        bmi.s   tp_donothing
        move    d0,(a1)
        move.b  (a2)+,3(a1)
        move.l  a2,-(a1)
        move    d0,d2
        moveq   #0,d0
tp_newnoteend:
        jmp     tp_fxinitlist(pc,d2.w)
tp_donothing:
        clr     (a1)
        move.l  a2,-(a1)
        ifne    pt1.1
        move.b  d0,-(a1)
        addq.l  #6,(a7)
        else
        move.b  d0,-1(a1)
        endc
tp_fxinitlist:
        rts
        nop
        rts
        nop
        rts
        nop
        bra     tp_voicefx3init
        bra     tp_voicefx4init
        bra     tp_voicefx5init
        rts
        nop
        bra     tp_voicefx7init
        bra     tp_voicefx0init
        bra     tp_voicefx9
        rts
        nop
        bra     tp_voicefxb
        bra     tp_voicefxc
        bra     tp_voicefxd
        bra     tp_voicefxeinit
tp_voicefxf:
        clr     4(a1)
        move    6(a1),d1
        cmp     #32,d1
        bge.s   tp_voicefxcia
        move    d1,tp_speed-tp_wait(a0)
        move    d1,(a0)
        rts
tp_voicefxcia:
        ifle    replaymode
        move.l  #1773447,d2
        divu    d1,d2
        move.b  d2,$bfd400
        lsr     #8,d2
        move.b  d2,$bfd500
        endc
        rts
        
tp_voicefx0init:
        tst     d0
        beq.s   tp_voicefx0initlab1
        cmp     #70,d0
        beq.s   tp_voicefx0end
        add     8(a1),d0
        lea     -2(a0,d0.w),a4
        move.l  a4,52(a1)
        addq.l  #4,(a7)
        rts
tp_voicefx0initlab1:
        move    8(a1),d2
        lea     70(a0,d2.w),a4
        move.l  a4,d2
        lea     -34(a4),a4
        move    26(a1),d1
        cmp     (a4),d1
        bhs.s   tp_high18
        lea     18(a4),a4
        cmp     (a4),d1
        bhs.s   tp_high10
tp_low8:
        addq    #8,a4
        cmp     (a4),d1
        bhs.s   tp_high6
tp_low4:
        addq    #4,a4
        cmp     (a4),d1
        bhs.s   tp_high2
tp_low2:
        addq    #4,a4
        cmp     (a4),d1
        bhs.s   tp_high2
tp_low0:
        addq    #2,a4
        cmp     (a4),d1
        bhs.s   tp_found
        subq    #2,a4
        bra.s   tp_found
tp_high18:
        lea     -18(a4),a4
        cmp     (a4),d1
        blt.s   tp_low8
tp_high10:
        lea     -10(a4),a4
        cmp     (a4),d1
        blt.s   tp_low4
tp_high6:
        subq    #6,a4
        cmp     (a4),d1
        blt.s   tp_low2
tp_high2:
        cmp     -(a4),d1
        blt.s   tp_low0
tp_found:
        cmp.l   a4,d2
        beq.s   tp_voicefx0end
        move.l  a4,52(a1)
        rts
tp_voicefx0end:
        clr     4(a1)
        rts

        dc.b    1,0,-1,1,0,-1,1,0,-1,1,0,-1,1,0,-1,1
        dc.b    0,-1,1,0,-1,1,0,-1,1,0,-1,1,0,-1,1,0
tp_voicefx0:
        move    (a1)+,d1
        move    18(a1),d0
        move    (a0),d2
        sub     tp_speed(pc),d2
        move.b  tp_voicefx0-1(pc,d2.w),d2
        beq.s   tp_arp0
        bmi.s   tp_arp2
        lsr     #4,d1
        bra.s   tp_arp1
tp_arp2:
        and     #$f,d1
tp_arp1:
        move.l  44(a1),a4
        add     d1,d1

        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   -10(a1),d5
        bne.s   tp_no3
        move    (a4,d1.w),6(a3)
tp_no3:
        else
        move    (a4,d1.w),6(a3)
        endc
        rts
tp_arp0:
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   -10(a1),d5
        bne.s   tp_no4
        move    d0,6(a3)
tp_no4:
	else
        move    d0,6(a3)
        endc
        rts

tp_voicefx1:
        move    20(a1),d1
        sub     (a1),d1
        and     #$fff,d1
        moveq   #113,d2
        cmp     d2,d1
        bpl.s   tp_voicefx1lab1
        move    d2,d1                   ;and #$f000,d0;or d1,d0 ???
tp_voicefx1lab1:
        move    d1,20(a1)
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   -8(a1),d5
        bne.s   tp_no5
        move    d1,6(a3)
tp_no5:
	else
        move    d1,6(a3)
        endc
        rts

tp_voicefx2:
        move    20(a1),d1
        add     (a1),d1
        cmp     #856,d1
        bmi.s   tp_voicefx2lab1
        move    #856,d1
        clr     -2(a1)
tp_voicefx2lab1:
        move    d1,20(a1)
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   -8(a1),d5
        bne.s   tp_no6
        move    d1,6(a3)
tp_no6:
	else
        move    d1,6(a3)
        endc
        rts

tp_voicefx3init:
        move    6(a1),d1
        beq.s   tp_voicefx5init
        tst     30(a1)
        bpl.s   tp_fx3initnochange
        neg     d1
tp_fx3initnochange:
        move    d1,30(a1)
tp_voicefx5init:
        tst     d0
        beq.s   tp_voicefx3initlab6
        addq.l  #4,a7
        addq.l  #6,(a7)
        move    8(a1),d2
;       cmp     #72*8+(tp_notelist-tp_wait),d2
;       blt.s   tp_voicefx3initlab3
;       subq    #2,d0
;       bgt.s   tp_voicefx3initlab3
;       moveq   #2,d0
tp_voicefx3initlab3:
        add     d0,d2
        move    -2(a0,d2.w),d0
        move    d0,28(a1)
        sub     26(a1),d0
        bpl.s   tp_voicefx3initlab5
        tst     30(a1)
        bmi.s   tp_voicefx3initlab4
        neg     30(a1)
tp_voicefx3initlab4:
        rts
tp_voicefx3initlab5:
        tst     30(a1)
        bpl.s   tp_voicefx3initlab6
        neg     30(a1)
tp_voicefx3initlab6:
        rts

tp_voicefx3:
        move    22(a1),d2
        beq.s   tp_voicefx3end
        move    24(a1),d1
        bmi.s   tp_voicefx3sub
        add     20(a1),d1
        cmp     d2,d1
        blt.s   tp_voicefx3ok
        bra.s   tp_voicefx3setok
tp_voicefx3sub:
        add     20(a1),d1
        cmp     d2,d1
        bgt.s   tp_voicefx3ok
tp_voicefx3setok:
        move    d2,d1
        clr     22(a1)
        clr     -2(a1)
tp_voicefx3ok:
        move    d1,20(a1)
        tst.b   42(a1)
        beq.s   tp_voicefx3skip
        move    2(a1),d2
        lea     (a0,d2.w),a4
        moveq   #35,d2
tp_voicefx3search:
        cmp     (a4)+,d1
        bhs.s   tp_voicefx3notefound
        dbra    d2,tp_voicefx3search
tp_voicefx3notefound:
        move    -2(a4),d1
tp_voicefx3skip:
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   -8(a1),d5
        bne.s   tp_no15
        move    d1,6(a3)
tp_no15:
        else
        move    d1,6(a3)
        endc
tp_voicefx3end:
        rts

tp_voicefx5:
        bsr.s   tp_voicefx3
        bra.s   tp_voicefxa

tp_voicefx4init:
        move    6(a1),d1
        beq.s   tp_voicefx4initend
        moveq   #$f,d2
        and     d1,d2
        beq.s   tp_voicefx4initlab1
        move    d2,36(a1)
tp_voicefx4initlab1:
        and     #$f0,d1
        beq.s   tp_voicefx4initend
        lsr     #2,d1
        move.b  d1,34(a1)
tp_voicefx4initend:
        rts

tp_voicefx4:
        moveq   #$7f,d0
        and.b   29(a1),d0
        move.b  27(a1),d2
        beq.s   tp_voicefx4sine
        add     d0,d0
        subq.b  #1,d2
        beq.s   tp_voicefx4rampdown
        st      d0
        bra.s   tp_voicefx4set
tp_voicefx4rampdown:
        tst.b   29(a1)
        bpl.s   tp_voicefx4set
        not.b   d0      
        bra.s   tp_voicefx4set
tp_voicefx4sine:
        lsr     #2,d0
        move.b  tp_vibratolist-tp_wait(a0,d0.w),d0
tp_voicefx4set:
        mulu    30(a1),d0
        lsr     #7,d0
        tst.b   29(a1)
        bpl.s   tp_voicefx4nosub
        neg     d0
tp_voicefx4nosub:
        add     20(a1),d0
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   -8(a1),d5
        bne.s   tp_no7
        move    d0,6(a3)
tp_no7:
	else
        move    d0,6(a3)
        endc
        move.b  28(a1),d0
        add.b   d0,29(a1)
        rts

tp_voicefx6:
        bsr.s   tp_voicefx4
tp_voicefxa:
        move    (a1),d1
        add.b   5(a1),d1
        bmi.s   tp_voicefxalab1
        moveq   #$40,d2
        cmp.b   d2,d1
        bcs.s   tp_voicefxaend
        move    d2,d1
        clr     -2(a1)
        bra.s   tp_voicefxaend
tp_voicefxalab1:
        moveq   #0,d1
        clr     -2(a1)
tp_voicefxaend:
        move    d1,4(a1)
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   -8(a1),d5
        bne.s   tp_no8
        ifne    volume
        mulu    tp_volume(pc),d1
        lsr     #8,d1
        endc
        move    d1,8(a3)
tp_no8:
	else
        ifne    volume
        mulu    tp_volume(pc),d1
        lsr     #8,d1
        endc
        move    d1,8(a3)
        endc
        rts

tp_voicefx7init:
        move    6(a1),d1
        beq.s   tp_voicefx7initend
        moveq   #$f,d2
        and     d1,d2
        beq.s   tp_voicefx7initlab1
        move    d2,42(a1)
tp_voicefx7initlab1:
        and     #$f0,d1
        beq.s   tp_voicefx7initend
        lsr     #2,d1
        move.b  d1,40(a1)
tp_voicefx7initend:
        rts

tp_voicefx7:
        moveq   #$7f,d0
        and.b   35(a1),d0
        move.b  33(a1),d2
        beq.s   tp_voicefx7sine
        add     d0,d0
        subq.b  #1,d2
        beq.s   tp_voicefx7rampdown
        st      d0
        bra.s   tp_voicefx7set
tp_voicefx7rampdown:
        tst.b   35(a1)
        bpl.s   tp_voicefx7set
        not.b   d0      
        bra.s   tp_voicefx7set
tp_voicefx7sine:
        lsr     #2,d0
        move.b  tp_vibratolist-tp_wait(a0,d0.w),d0
tp_voicefx7set:
        mulu    36(a1),d0
        lsr     #7,d0
        tst.b   35(a1)
        bpl.s   tp_voicefx7nosub
        neg     d0
tp_voicefx7nosub:
        add     4(a1),d0
        bpl.s   tp_voicefx7noneg
        clr     d0
        bra.s   tp_voicefx7ok
tp_voicefx7noneg:
        moveq   #40,d1
        cmp     d1,d0
        bls.s   tp_voicefx7ok
        move    d1,d0
tp_voicefx7ok:
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   -8(a1),d5
        bne.s   tp_no9
        ifne    volume
        mulu    tp_volume(pc),d1
        lsr     #8,d1
        endc
        move    d1,8(a3)
tp_no9:
	else
        ifne    volume
        mulu    tp_volume(pc),d1
        lsr     #8,d1
        endc
        move    d1,8(a3)
        endc
        move.b  34(a1),d0
        add.b   d0,35(a1)
        rts

tp_voicefx9:
        tst     d0
        beq.s   tp_voicefx9normal

        ifne    funk
        moveq   #0,d1
        move.b  46(a1),d1
        beq.s   tp_voicefx9funkend
        move.b  tp_funklist-tp_wait(a0,d1.w),d1
        add.b   d1,47(a1)
        bpl.s   tp_voicefx9funkend
        clr.b   47(a1)
        move.l  16(a1),a2
        movem   22(a1),d1-d2
        addq    #1,d2
        add     d1,d1
        cmp     d1,d2
        blo.s   tp_voicefx9funkok
        moveq   #0,d2
tp_voicefx9funkok:
        not.b   (a2,d2.w)
        move    d2,24(a1)
tp_voicefx9funkend:
        endc

        move.l  (a7),-(a7)
        lea     tp_voicefx9after(pc),a4
        move.l  a4,4(a7)
tp_voicefx9normal:
        clr     4(a1)
        moveq   #0,d1
        move    6(a1),d1
        beq.s   tp_voicefx9after
        lsl     #7,d1
        move    d1,44(a1)
tp_voicefx9after:
        move    44(a1),d1
        sub     d1,20(a1)
        ble.s   tp_voicefx9skip
        add     d1,d1
        add.l   d1,12(a1)
        rts
tp_voicefx9skip:
        move    #1,20(a1)
        rts

tp_voicefxb:
        clr     4(a1)
        move    6(a1),d1
        clr     tp_pattcount-tp_wait(a0)
tp_otherpattern:
        move.l  tp_pattadr3(pc),a1
        add.w   d1,d1
        add.w   d1,a1
        move.l  a1,tp_pattadr-tp_wait(a0)
        rts

tp_voicefxc:
        move    6(a1),d1
        move    d1,10(a1)
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   d4,d5
        bne.s   tp_no10
        ifne    volume
        mulu    tp_volume(pc),d1
        lsr     #8,d1
        endc
        move    d1,8(a3)
tp_no10:
        else
        ifne    volume
        mulu    tp_volume(pc),d1
        lsr     #8,d1
        endc
        move    d1,8(a3)
        endc
        clr     4(a1)
        rts

tp_voicefxd:
        clr     4(a1)
        clr     tp_pattcount-tp_wait(a0)
        move    6(a1),tp_newpattpos-tp_wait(a0)
        clr.b   tp_shitpon-tp_wait(a0)
        rts

tp_voicefxeinit:
        moveq   #-$10,d1
        and     6(a1),d1
        lsr     #2,d1
        jmp     tp_voicefxeinitlist(pc,d1.w)
tp_voicefxeinitlist:
        bra     tp_voicefxe0
        bra     tp_voicefxe1
        bra     tp_voicefxe2
        bra     tp_voicefxe3
        bra     tp_voicefxe4
        bra     tp_voicefxe5
        bra     tp_voicefxe6
        bra     tp_voicefxe7
        rts
        nop
        bra     tp_voicefxe9
        bra     tp_voicefxea
        bra     tp_voicefxeb
        bra     tp_voicefxec
        bra     tp_voicefxed
        bra     tp_voicefxee
tp_voicefxef:
        clr     4(a1)
        ifne    funk
        moveq   #$f,d2
        and     6(a1),d2
        move.b  d2,46(a1)
        endc
        rts

tp_voicefxe0:
        clr     4(a1)
        moveq   #1,d2
        and     6(a1),d2
        bne.s   tp_voicefxe0clr
        bclr    #1,$bfe001
        rts
tp_voicefxe0clr:
        bset    d2,$bfe001
        rts

tp_voicefxe1:
        tst     d0
        beq.s   tp_voicefxe1ok
        move    8(a1),d1
        add     d0,d1
        move    -2(a0,d1.w),26(a1)
        moveq   #10,d0
        add.l   d0,(a7)
tp_voicefxe1ok:
        addq.l  #4,a1
        clr     (a1)+
        and     #$f,(a1)
        bsr     tp_voicefx1
        subq.l  #6,a1
        rts

tp_voicefxe2:
        tst     d0
        beq.s   tp_voicefxe2ok
        move    8(a1),d1
        add     d0,d1
        move    -2(a0,d1.w),26(a1)
        moveq   #10,d0
        add.l   d0,(a7)
tp_voicefxe2ok:
        addq.l  #4,a1
        clr     (a1)+
        and     #$f,(a1)
        bsr     tp_voicefx2
        subq.l  #6,a1
        rts

tp_voicefxe3:
        clr     4(a1)
        moveq   #$f,d2
        and     6(a1),d2
        move.b  d2,48(a1)
        rts

tp_voicefxe4:
        clr     4(a1)
        moveq   #$3,d2
        and     6(a1),d2
        move.b  d2,33(a1)
        btst    #2,6(a1)
        beq.s   tp_voicefxe4ok
        st      32(a1)
        rts
tp_voicefxe4ok:
        clr.b   32(a1)
        rts

tp_voicefxe5:
        clr     4(a1)
        moveq   #$f,d2
        and     6(a1),d2
        mulu    #72,d2
        add     #tp_notelist-tp_wait,d2
        move    d2,8(a1)
        rts

tp_voicefxe6:
        clr     4(a1)
        moveq   #$f,d2
        and     6(a1),d2
        beq.s   tp_voicefxe6start
        subq.b  #1,49(a1)
        beq.s   tp_voicefxe6end
        bpl.s   tp_voicefxe6doloop
        move.b  d2,49(a1)
tp_voicefxe6doloop:
        moveq   #63,d2
        move    d2,tp_pattcount-tp_wait(a0)
        sub     50(a1),d2
        move    d2,tp_newpattpos-tp_wait(a0)
        st      tp_pattrepeat-tp_wait(a0)
tp_voicefxe6end:
        rts
tp_voicefxe6start:
        move    tp_pattcount(pc),50(a1)
        rts

tp_voicefxe7:
        clr     4(a1)
        moveq   #$f,d2
        and     6(a1),d2
        move.b  d2,39(a1)
        btst    #2,6(a1)
        beq.s   tp_voicefxe7ok
        st      38(a1)
        rts
tp_voicefxe7ok:
        clr.b   38(a1)
        rts

tp_voicefxe9:
        move    #$9*4,4(a1)
        and     #$f,6(a1)
        beq.s   tp_voicefxe9clear
        tst     d0
        bne.s   tp_voicefxe9end
tp_voicefxe9clear:
        clr     4(a1)
tp_voicefxe9end:
        rts
tp_voicefxe9do:
        moveq   #0,d1
        move    tp_speed(pc),d1
        sub     (a0),d1
        divu    (a1),d1
        swap    d1
        tst     d1
        bne.s   tp_voicefxe9end
tp_voicefxe9play:
        move.b  -8(a1),d1
        or.b    d1,tp_dmaon-tp_wait+1(a0)
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   -8(a1),d5
        bne.s   tp_no11
        move.l  6(a1),(a3)+
        move    14(a1),(a3)
tp_no11:
        else
        move.l  6(a1),(a3)+
        move    14(a1),(a3)
        endc
        rts

tp_voicefxea:
        addq.l  #4,a1
        clr     (a1)+
        and     #$f,(a1)
        bsr     tp_voicefxa
        subq.l  #6,a1
        rts

tp_voicefxeb:
        addq.l  #4,a1
        clr     (a1)+
        and     #$f,(a1)
        neg.b   1(a1)
        bsr     tp_voicefxa
        subq.l  #6,a1
        rts

tp_voicefxec:
        move    #$b*4,4(a1)
        and     #$f,6(a1)
        bne.s   tp_voicefxecend
        clr     4(a1)
        clr     10(a1)
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   d4,d5
        bne.s   tp_no12
        clr     8(a3)
tp_no12:
        else
        clr     8(a3)
        endc
tp_voicefxecend:
        rts
tp_voicefxecdo:
        subq    #1,(a1)
        bne.s   tp_voicefxecend
        clr     -(a1)
        clr     6(a1)
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   -6(a1),d5
        bne.s   tp_no13
        clr     8(a3)
tp_no13:
        else
        clr     8(a3)
        endc
        rts

tp_voicefxed:
        move    #$c*4,4(a1)
        tst     d0
        beq.s   tp_voicefxednoinit
        and     #$f,6(a1)
        beq.s   tp_voicefxednoinit
        add     8(a1),d0
        move    -2(a0,d0.w),26(a1)
        addq    #4,a7
        addq.l  #6,(a7)
        rts
tp_voicefxednoinit:
        clr     4(a1)
tp_voicefxedend:
        rts
tp_voicefxeddo:
        subq    #1,(a1)
        bne.s   tp_voicefxedend
        clr     -2(a1)
        ifne    switch
        move.b  tp_voiceoff(pc),d5
        and.b   -8(a1),d5
        bne.s   tp_no14
        move    20(a1),6(a3)
tp_no14:
        else
        move    20(a1),6(a3)
        endc
        bra     tp_voicefxe9play

tp_voicefxee:
        clr     4(a1)
        moveq   #$f,d1
        and     6(a1),d1
        move    d1,tp_pattdelay-tp_wait(a0)
        clr.b   tp_shitpon-tp_wait+1(a0)
        rts

tp_dmaonint:
        iflt    replaymode
        move.l  a0,-(a7)
        move.l  a1,-(a7)
        move.b  #$19,$bfdf00
        move    tp_dmaon(pc),$dff096
        move.l  tp_ciab_resource(pc),a0
        lea     tp_voiceloopint(pc),a1
        move.l  a1,80(a0)
        move.l  (a7)+,a1
        move.l  (a7)+,a0
        rts
        else
        btst    #1,$bfdd00
        beq.s   tp_nodmaonint
        move.b  #$19,$bfdf00
        move    tp_dmaon(pc),$dff096
        ifne    vbruse
        move.l  a0,-(a7)
        move.l  tp_vbr(pc),a0
        move.l  tp_int3pon(pc),$78(a0)
        move.l  (a7)+,a0
        else
        move.l  tp_int3pon(pc),$78.w
        endc
tp_nodmaonint:
        move    #$2000,$dff09c
        move    #$2000,$dff09c	;!!!
        nop
        rte
        endc

tp_voiceloopint:
        iflt    replaymode
        move.l  a0,-(a7)
        else
        btst    #1,$bfdd00
        beq.s   tp_novoiceloopint
        endc
        ifne    switch
        btst    #0,tp_voiceoff
        bne.s   tp_intnovoice0
        move.l  tp_voice0dat+18(pc),$dff0a0
        move    tp_voice0dat+24(pc),$dff0a4
tp_intnovoice0
        btst    #1,tp_voiceoff
        bne.s   tp_intnovoice1
        move.l  tp_voice1dat+18(pc),$dff0b0
        move    tp_voice1dat+24(pc),$dff0b4
tp_intnovoice1
        btst    #2,tp_voiceoff
        bne.s   tp_intnovoice2
        move.l  tp_voice2dat+18(pc),$dff0c0
        move    tp_voice2dat+24(pc),$dff0c4
tp_intnovoice2
        btst    #3,tp_voiceoff
        bne.s   tp_intnovoice3
        move.l  tp_voice3dat+18(pc),$dff0d0
        move    tp_voice3dat+24(pc),$dff0d4
tp_intnovoice3
        else
        move.l  tp_voice0dat+18(pc),$dff0a0
        move    tp_voice0dat+24(pc),$dff0a4
        move.l  tp_voice1dat+18(pc),$dff0b0
        move    tp_voice1dat+24(pc),$dff0b4
        move.l  tp_voice2dat+18(pc),$dff0c0
        move    tp_voice2dat+24(pc),$dff0c4
        move.l  tp_voice3dat+18(pc),$dff0d0
        move    tp_voice3dat+24(pc),$dff0d4
        endc
        iflt    replaymode
        move.l  a1,-(a7)
        move.l  tp_ciab_resource(pc),a0
        lea     tp_dmaonint(pc),a1
        move.l  a1,80(a0)
        move.l  (a7)+,a1
        move.l  (a7)+,a0
        rts
        else
        ifne    vbruse
        move.l  a0,-(a7)
        move.l  tp_vbr(pc),a0
        move.l  tp_int1pon(pc),$78(a0)
        move.l  (a7)+,a0
        else
        move.l  tp_int1pon(pc),$78.w
        endc
tp_novoiceloopint:
        move    #$2000,$dff09c
        move    #$2000,$dff09c	;!!!
        nop
        rte
        endc

tp_shitpon:dc           -1
tp_pattcount:dc         1
tp_wait:dc              1
tp_pattadr:dc.l         0
tp_pattadr2:dc.l        0
tp_pattadr3:dc.l        0
tp_pattlistadr:dc.l     0
tp_pattdataadr:dc.l     0
tp_oldint:dc.l          0
tp_int1pon:dc.l         0
tp_int3pon:dc.l         0
tp_newpattpos:dc        0
tp_pattdelay:dc         0
tp_pattrepeat:dc        0
tp_pattadrpon:dc        0
        ifne    choosestart
tp_patternnumber:dc     0
        endc
tp_data:dc.l            0
        ifne    split
tp_samples:dc.l         0
        endc
        ifne    switch
tp_voiceoff:dc.b        %0000           ;Bitx=Voicex (0=ON,1=OFF)
        even
        endc
tp_dmaon:dc             $8000
tp_funklist:
        dc.b    0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
tp_vibratolist:
        dc.b    0,24,49,74,97,120,141,161
        dc.b    180,197,212,224,235,244,250,253
        dc.b    255,253,250,244,235,224,212,197
        dc.b    180,161,141,120,97,74,49,24
tp_instlist:ds.b        31*16
tp_speed:dc             6
;        ifne    vbruse
;tp_vbr:dc.l             0
;        endc
;        ifne    volume
;tp_volume:dc            255             ;0=off,255=max. volume
;        endc
        iflt    replaymode
tp_ciab_resource        dc.l    0
tp_ciab_timerastruktur
        dc.l    0,0
        dc.b    2,0
        dc.l    0,0,0
tp_ciab_timerbstruktur
        dc.l    0,0
        dc.b    2,0
        dc.l    0,0,0
tp_timeraname
        dc.b    "TP_TimerA",0
tp_timerbname
        dc.b    "TP_TimerB",0
        even
        endc

tp_notelist:
        dc      856,808,762,720,678,640,604,570,538,508,480,453
        dc      428,404,381,360,339,320,302,285,269,254,240,226
        dc      214,202,190,180,170,160,151,143,135,127,120,113

        dc      850,802,757,715,674,637,601,567,535,505,477,450
        dc      425,401,379,357,337,318,300,284,268,253,239,225
        dc      213,201,189,179,169,159,150,142,134,126,119,113

        dc      844,796,752,709,670,632,597,563,532,502,474,447
        dc      422,398,376,355,335,316,298,282,266,251,237,224
        dc      211,199,188,177,167,158,149,141,133,125,118,112

        dc      838,791,746,704,665,628,592,559,528,498,470,444
        dc      419,395,373,352,332,314,296,280,264,249,235,222
        dc      209,198,187,176,166,157,148,140,132,125,118,111

        dc      832,785,741,699,660,623,588,555,524,495,467,441
        dc      416,392,370,350,330,312,294,278,262,247,233,220
        dc      208,196,185,175,165,156,147,139,131,124,117,110

        dc      826,779,736,694,655,619,584,551,520,491,463,437
        dc      413,390,368,347,328,309,292,276,260,245,232,219
        dc      206,195,184,174,164,155,146,138,130,123,116,109

        dc      820,774,730,689,651,614,580,547,516,487,460,434
        dc      410,387,365,345,325,307,290,274,258,244,230,217
        dc      205,193,183,172,163,154,145,137,129,122,115,109

        dc      814,768,725,684,646,610,575,543,513,484,457,431
        dc      407,384,363,342,323,305,288,272,256,242,228,216
        dc      204,192,181,171,161,152,144,136,128,121,114,108

        dc      907,856,808,762,720,678,640,604,570,538,508,480
        dc      453,428,404,381,360,339,320,302,285,269,254,240
        dc      226,214,202,190,180,170,160,151,143,135,127,120

        dc      900,850,802,757,715,675,636,601,567,535,505,477
        dc      450,425,401,379,357,337,318,300,284,268,253,238
        dc      225,212,200,189,179,169,159,150,142,134,126,119

        dc      894,844,796,752,709,670,632,597,563,532,502,474
        dc      447,422,398,376,355,335,316,298,282,266,251,237
        dc      223,211,199,188,177,167,158,149,141,133,125,118

        dc      887,838,791,746,704,665,628,592,559,528,498,470
        dc      444,419,395,373,352,332,314,296,280,264,249,235
        dc      222,209,198,187,176,166,157,148,140,132,125,118

        dc      881,832,785,741,699,660,623,588,555,524,494,467
        dc      441,416,392,370,350,330,312,294,278,262,247,233
        dc      220,208,196,185,175,165,156,147,139,131,123,117

        dc      875,826,779,736,694,655,619,584,551,520,491,463
        dc      437,413,390,368,347,328,309,292,276,260,245,232
        dc      219,206,195,184,174,164,155,146,138,130,123,116

        dc      868,820,774,730,689,651,614,580,547,516,487,460
        dc      434,410,387,365,345,325,307,290,274,258,244,230
        dc      217,205,193,183,172,163,154,145,137,129,122,115

        dc      862,814,768,725,684,646,610,575,543,513,484,457
        dc      431,407,384,363,342,323,305,288,272,256,242,228
        dc      216,203,192,181,171,161,152,144,136,128,121,114

tp_voice0dat:
        dc.b    1
        ds.b    57
tp_voice1dat:
        dc.b    2
        ds.b    57
tp_voice2dat:
        dc.b    4
        ds.b    57
tp_voice3dat:
        dc.b    8
        ds.b    57
e:
;tp_module:
;        incbin  "dh0:trashcan/testmod.TP3"
;tp_finish:
;        end
