;load for WickedOS by Leif Oppermann

;03.02.99
;v0.1 - first version without overlay support

;v0.11 - forget it! messed around with the memory system. didn't work.

;28.2.99
;v0.2 - new approach (mainly in the mms)

;23.3.99
;v0.3 - notices if it is started from an overlay-file
;       if a wHDF is attached the files will be searched first in there


;28.3.99
;v0.4 - added LOADFROM to WickedOS, defines where to search for wHDF-data
;       LOADFROM #-1   (own loadfile)
;       LOADFROM #0    (nowhere)
;       LOADFROM #file (try to open given file)

_LoadFrom:
	ifd	OVERLAY
	ifd	wtest
		lea	seeking(pc),a0
		move.l	a0,d2
		bsr	printit
	endc

	ifd	asciianim
		lea	aanim(pc),a0
		move.l	a0,d2
		bsr	printit
	endc


	;--- get name of own loadfile
	move.l	STREAM,d1		;filehandle (supplied by overlay-manager)
	beq	.error			;if we are not loaded by DOS
					;-> we can't have data attached!
	move.l	#lownfilename,d2	;buffer
	move.l	#256,d3			;length of buffer
	move.l	dosbase(pc),a6
	jsr	-408(a6)		;NameFromFH
					;-> buffer is filled with our name

	;--- get own filehandle (will be closed again at program exit)
	move.l	#lownfilename,d1
	move.l	#1005,d2		;read only
	call	Open	
	move.l	d0,lownfilehandle
	beq	.error

	;--- seek for start of data (after dc.l $3f5,$0,$3f6)	
	;                                                ^^^
	move.l	d0,d3
	move.l	#4,d4	;our counter, will point to start of data
	sub.l	#0,a2
	sub.l	#0,a3
	sub.l	#0,a4
.lp
	bsr	get4	;->result in d2
	tst	d0
	bne	.error

	exg.l	a2,a3	
	exg.l	a3,a4
	move.l	d2,a4

	cmp.l	#$3f6,d2
	beq	.matched1
	add.l	#4,d4
	bra	.lp
.matched1
	cmp.l	#$0,a3
	beq	.matched2
	add.l	#4,d4
	bra	.lp
.matched2
	cmp.l	#$3f5,a2
	beq	.found
	add.l	#4,d4
	bra	.lp
.found
	move.l	d4,lownstartofdata

	;--- is it a wHDF data-file?
	bsr	get4
	cmp.l	#"wHDF",d2
	bne	.error

	ifd	wtest
	lea	reading(pc),a0
	move.l	a0,d2
	bsr	printit
	endc

	;--- read out wHDFs header informations
	bsr	get4
	move.l	d2,wHDFlength
	bsr	get4
	move.l	d2,wHDFentries
	;muls.l	#16,d2
	lsl.l	#4,d2
	move.l	d2,wHDFTON	;just an offset at the moment (add wHDFTOC)
	bsr	get4		;this is only needed for .lp3
	move.l	d2,d6		;store for .lp3
	move.l	#0,wHDFTOC	;add memory position

	bsr	get4
	move.l	d2,wHDFname
	bsr	get4
	move.l	d2,wHDFname+4
	bsr	get4
	move.l	d2,wHDFname+8
	bsr	get4
	move.l	d2,wHDFname+12

	;--- (nastily) calculate memory requirements for TOC + TON
	;nasty because i assume that the start of the first file in the TOC
	;is just the required value. this is only true as long as noone else
	;writes a wHDF file creator. (OK, so this is valid forever :))
	bsr	get4
	move.l	d2,d0		;start.l #1 in d2
	bsr	_SYSAllocAny	;alloc d0 bytes
	tst	d0
	beq	.error

	;--- correct pointers
	move.l	d0,a3
	add.l	d0,wHDFTOC
	move.l	wHDFTOC,d0
	add.l	d0,wHDFTON		

	;--- now just copy the whole shit
	move.l	a3,a4		;store memory postition
	move.l	d2,d4		;restore start.l #1
	sub.l	#5,d4		;our counter (length of TOC+TON)
	move.l	d2,(a3)+	;this was start.l of the first entry!
	move.l	dosbase(pc),a6	;this got lost while calling _SYSAllocAny
.lp2	bsr	get1
	bne	.error
	move.b	d2,(a3)+
	sub.l	#1,d4	
	bne.s	.lp2

	;--- correct each ^name.l in TOC
	move.l	a4,d0		;restore memory-position
	sub.l	d6,d0		;we skipped the whole file-header and 
				;started directly at the TOC
	move.l	wHDFTOC(pc),a2
	move.l	wHDFentries(pc),d1
.lp3	add.l	d0,8(a2)
	lea	16(a2),a2	;skip to next entry

	subq.l	#1,d1
	bne.s	.lp3

	;--- make TON lowercase
	move.l	wHDFTOC(pc),a2
	move.l	wHDFentries(pc),d2
	moveq	#0,d0
.lp4	move.l	8(a2),a0
	move.b	12(a2),d0
	bsr	makelowercase
	add.l	#16,a2

	subq.l	#1,d2
	bne.s	.lp4

	;--- write ownfh, ownname, owndata to wosbase
	lea	_wosbase(pc),a6
	move.l	lownfilehandle(pc),ownfh(a6)
	lea	lownfilename(pc),a0
	move.l	a0,ownname(a6)
	move.l	lownstartofdata(pc),owndata(a6)

;	ifd	wtest
;	;--- print out directory structure
;	lea	dir(pc),a0
;	move.l	a0,d2
;	bsr	printit
;	
;	move.l	wHDFTOC(pc),a2
;	move.l	wHDFentries(pc),d3
;.lp5	lea	dot(pc),a0
;	move.l	a0,d2
;	bsr	printit
;
;	move.l	8(a2),a0
;	move.l	a0,d2
;	bsr	printit
;	add.l	#16,a2
;
;	lea	ret(pc),a0
;	move.l	a0,d2
;	bsr	printit
;
;	subq.l	#1,d3
;	bne.s	.lp5
;	endc

	;--- we are done
	move.l	#-1,lownvalid	;we have valid data attached!
	moveq	#0,d0
	rts
.error
	endc	; of OVERLAY
	rts



loadInit:
;trys to LOADFROM #-1
;returns d0=0 ok, d0=-1 error

	ifd	OVERLAY
		push	a6
		lea	_wosbase(pc),a6
		move.l	#-1,_a0(a6)
		bsr	_LoadFrom
		pull	a6
	
		moveq	#0,d0
		rts
	endc
	moveq	#-1,d0
	rts	

	ifd	OVERLAY	
makelowercase:	;in: a0 - ^string, d0 - length of string
.lp	move.b	(a0)+,d1
	or.l	#$20,d1		;make lowcase
	move.b	d1,-1(a0)

	sub.b	#1,d0
	bne.s	.lp
	rts

get1	;gets next byte from file (d3), doesn't touch d3!
	; out: d0=0 ok, d0=-1 error
	;      d2 is your byte
	move.l	d3,d1
	jsr	-306(a6)	;FGetC (dos)
	cmp.l	#-1,d0
	beq	.error
	move.b	d0,d2
	moveq	#0,d0
	rts

.error	moveq	#0,d2
	moveq	#-1,d0
	rts


get4:	;gets next 4 bytes from file (d3), doesn't touch d3!
	; out: d0=0 ok, d0=-1 error
	;      d2 are the next 4 bytes
	move.l	d3,d1
	jsr	-306(a6)	;FGetC (dos)
	cmp.l	#-1,d0
	beq	.error
	move.b	d0,d2
	rol.l	#8,d2
	move.l	d3,d1
	jsr	-306(a6)	;FGetC (dos)
	cmp.l	#-1,d0
	beq	.error
	move.b	d0,d2
	rol.l	#8,d2
	move.l	d3,d1
	jsr	-306(a6)	;FGetC (dos)
	cmp.l	#-1,d0
	beq	.error
	move.b	d0,d2
	rol.l	#8,d2
	move.l	d3,d1
	jsr	-306(a6)	;FGetC (dos)
	cmp.l	#-1,d0
	beq	.error
	move.b	d0,d2

	moveq	#0,d0
	rts

.error	moveq	#0,d2
	moveq	#-1,d0
	rts
	endc
	
loadExit:
	ifd	OVERLAY
	;--- close own filehandle
	move.l	lownfilehandle(pc),d1
	beq.s	.skip
	call	Close,dos
.skip
	endc
	rts

	ifd	asciianim
aanim	incbin	ms99:haujobb.asciianim
	dc.b	10,0
	endc

	ifd	wtest
seeking	dc.b	"WickedOS Overlay selftest",10
	dc.b	"-------------------------",10
	dc.b	"· seeking harddiskfile",10,0
reading	dc.b	"· buffering directory-tree",10,0
dir	dc.b	10,"found the following files:",10,0
dot	dc.b	"· ",0
ret	dc.b	10,0
	even
	endc
**********************************************************************
* speicher für den file info block:     260 bytes und durch 4 teilbar.
                cnop    0,4
lfileinfoblock:  ds.b	260
lfileaddress:    dc.l    0
lfilehandle:     dc.l    0
lfilelock:       dc.l    0
lfilename:       dc.l    0
lfilememtype:    dc.l    0       ;(2 = chip  / 1 = pub)
lfilebanknum:	dc.l	0
	ifd	OVERLAY
lownfilename	ds.b	256
lownfilehandle	dc.l	0	;better suited than STREAM !
lownstartofdata	dc.l	0
lownvalid	dc.l	0	;-1 if we have own data attached
wHDFlength	dc.l	0	;byte-length of wHDF-file
				;lownstartofdata+wHDFlength-4 should be
				;EOF of the loadfile
wHDFentries	dc.l	0	;number of files
wHDFTOC		dc.l	0	;points to the table of contents
wHDFTON		dc.l	0	;points to the table of names
wHDFname	ds.b	17	;name of wHDF (null terminated)
	even
	endc
**********************************************************************
lenableloading
	ifnd	DONTTAKE
		move	#$8008,$dff09a	;enable io
	endc
	rts
	

ldisableloading
	ifnd	DONTTAKE
		move	#$0008,$dff09a	;disable io
	endc
	rts

lloadfehler:
        move.l  lfilehandle,d1
        beq.s   .ok
        jsr     -36(a6)
.ok
	bsr	ldisableloading
	pull	d2-a6
	SERROR	Error_while_loading!

	moveq   #0,d1
	moveq	#0,d0
        rts

_Load:
	push	d2-a6
	move.l	_a0(a6),lfilename
	move.l	_d0(a6),lfilememtype
	bsr	lenableloading

	ifd	OVERLAY
		tst.l	lownvalid
		beq.s	.DOSload
		bsr	wHDFload	;try to load from overlay-file
		tst	d0		;returns d0=-1 in case of error
		beq	.success	;        d0=0 for success
	endc	

.DOSload
        
        ; lock holen    
        move.l  lfilename,d1             
        move.l  #-2,d2          ; lesemodus
        move.l  dosbase,a6
        jsr     -84(a6)         ; lock holen 
        move.l  d0,lfilelock
        beq	lloadfehler
        
        ; datei untersuchen
        move.l  lfilelock,d1     
        move.l  #lfileinfoblock,d2       
        jsr     -102(a6)                ; examine (füllt den fib)
        tst     d0
        beq     lloadfehler

        ; lock entfernen
        move.l  lfilelock,d1     
        jsr     -90(a6)         ; unlock        (lock muß noch in d1 sein!)
        
        ; speicher für die datei besorgen
        cmp.l   #2,lfilememtype              ; 2 = chip
        beq.s   .chip            ; chip oder pub ?


        ALLOCANY	lfileinfoblock+124
        bra     .jump
.chip
	ALLOCANYCHIP	lfileinfoblock+124               
.jump	 move.l  d0,lfileaddress  ; adresse merken
        beq     lloadfehler
	move.l	d1,lfilebanknum
                
        ; datei öffnen
        move.l  lfilename,d1             
        move.l  #1005,d2                ; zugriffsmodus
        move.l  dosbase,a6      
        jsr     -30(a6)         ; open
        move.l  d0,lfilehandle

        ; datei lesen
        move.l  lfilehandle,d1           ; handle
        move.l  lfileaddress,d2          ; addresse
        move.l  lfileinfoblock+124,d3    ; länge 
        jsr     -42(a6)         ; read
        tst     d0
        beq     lloadfehler      ; bmi stand hier vorher?!?
        
        ; datei schließen
        move.l  lfilehandle,d1
        jsr     -36(a6)

        move.l  #0,lfilehandle
        move.l  #0,lfilelock
.success
        move.l  #0,lfilename
	bsr	ldisableloading
	move.l	lfilebanknum(pc),d1
	move.l	lfileaddress(pc),d0
	pull	d2-a6
        rts

	ifd	OVERLAY
wHDFload:
;in:	move.l	_a0(a6),lfilename
;	move.l	_d0(a6),lfilememtype

;out:	move.l	lfilebanknum(pc),d1
;	move.l	lfileaddress(pc),d0

	;--- get length of and pointer to lfilename without path:
	move.l	lfilename(pc),a0
	moveq	#0,d1
.l1	move.b	(a0)+,d0
	beq.s	.donel1

	addq.l	#1,d1
	cmp.b	#":",d0
	bne.s	.nope
	moveq	#0,d1
	move.l	a0,dummyfilename
.nope	bra.s	.l1
			;-> length in d1, ^name_without_path in dummyfilename
.donel1
	move.l	d1,dummyfilenamelength

	;--- make lfilename lowercase (this pokes directly into client-data!)
	move.l	dummyfilename(pc),a0
	move.l	dummyfilenamelength(pc),d0
	bsr	makelowercase


	;--- try to find the file in wHDF
	move.l	wHDFTOC(pc),a2
	move.l	wHDFentries(pc),d2
	move.l	dummyfilenamelength(pc),d3
.l2	move.b	12(a2),d0
	cmp.b	d3,d0		;quick check for length
	bne.s	.different

	move.l	8(a2),a0		;current TOC name
	move.l	dummyfilename(pc),a1
	subq.l	#1,d0
.stringcompareloop		;both strings are already lowercase!
	move.b	(a0)+,d1
	sub.b	(a1)+,d1
	bne.s	.different
	dbf	d0,.stringcompareloop
	bra.s	.found		;*** if we reach this, we found the file
	
.different
	add.l	#16,a2		;skip to next entry
	subq.l	#1,d2
	bne.s	.l2

	bra	.error		;*** not found in here

.found	
	move.l	(a2),.seekpos
	move.l	4(a2),.length
	move.l	lownstartofdata(pc),d0
	add.l	d0,.seekpos

        ;--- get mem
        cmp.l   #2,lfilememtype	; 2 = chip
        beq.s   .chip		; chip or pub ?
        ALLOCANY	.length
        bra     .jump
.chip	ALLOCANYCHIP	.length               
.jump	move.l  d0,lfileaddress
	beq     .error
	move.l	d1,lfilebanknum

	;--- seek the file
	move.l	dosbase(pc),a6
	move.l	lownfilehandle(pc),d1
	move.l	.seekpos(pc),d2
	moveq	#-1,d3		;offset_beginning
	jsr	_LVOSeek(a6)

	;--- read the file
	move.l	lownfilehandle(pc),d1
	move.l	lfileaddress(pc),d2
	move.l	.length(pc),d3	
	jsr	_LVORead(a6)

	ifd	wtest
	;--- fill the fib (for debugging)
	move.l	lownfilehandle(pc),d1
	move.l	#lfileinfoblock,d2
	jsr	-390(a6)		;ExamineFH
	endc

	moveq	#0,d0
	rts


.error	moveq	#-1,d0
	rts

.seekpos	dc.l	0
.length		dc.l	0
dummyfilename	dc.l	0
dummyfilenamelength	dc.l	0
	endc	;of OVERLAY

