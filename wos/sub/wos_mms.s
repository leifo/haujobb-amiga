;WickedOS MemoryManagmentSystem by NoName


;*************** 
; in: d0 - size to allocate
;     d1 - parameters for AllocMem
;     d2 - banknumber
;out: d0 - adr of memory or 0
__allocbank:      
	push	d2-a6
	move.l	d0,d3	;store size
	move.l	d1,d4	;store params

	; evtl. vorhandene bank freigeben
	move.l	d2,d0		
	bsr.s   __erase			; features __calcadd for __memadd

	; speicher beanspruchen
	move.l	__memadd(pc),a0
	move.l  d3,4(a0)		; größe eintragen
	move.l	d3,d0			; bytesize
	move.l	d4,d1			; attributes (MEMF_...)
	move.l  $4.w,a6
	jsr     _LVOAllocMem(a6)
	move.l  __memadd(pc),a0
	move.l  d0,(a0)			; adresse eintragen	
	bne.s	.noerr
	bsr	__memfehler		; fehler ?
.noerr	pull	d2-a6
	rts


;*************** 
; in: d0 - banknumber to free
;out: -
__erase:  
	push	d2-a6

        bsr.s   __calcadd	;-> a0 will point to adr.l and size.l of this bank
	tst	d0
	beq.s	.isfree		;if calcadd bugs out, the "bank" is free for sure
        
        ; testen ob bank belegt
        tst.l   (a0)		; $0 = nicht belegt
        beq.s   .isfree		; nicht belegt -> ok                    
        
        ; bank löschen
        move.l  (a0),a1         ; adresse der bank

        move.l  4(a0),d0	; size
        move.l  $4.w,a6
        jsr     _LVOFreeMem(a6)

        bsr	__removeentry	; alten eintrag löschen         
;	lea	_wosbase,a6	

.isfree:
	pull	d2-a6
	rts     


;*************** 
; in: -
;out: - 
__eraseall:
	push	d2-a6
	move.l	_mmstabptr(a6),a2	;point to size,address
	cmp.l	#0,a2
	beq.s	.quit

	move.l	(a2),d2			;size (means number of banks)
.eraseloop
	move.l  d2,d0
	bsr.s   __erase
	subq.l	#1,d2
	bne.s	.eraseloop
.quit	pull	d2-a6
	rts                               


;*************** 
; in: d0 - banknumber
;out: d0 - ^start of bank or 0
__start:
	push	d2-a6
        bsr	__calcadd
	tst	d0
	bne	.noerror
	moveq	#0,d0
	bra	.quit

.noerror
        move.l  (a0),d0

.quit	pull	d2-a6
        rts
        
;*************** 
; in: d0 - banknumber
;out: d0 - length of bank or 0
__length: 
	push	d2-a6
        bsr.s   __calcadd
	tst	d0
	bne	.noerror
	moveq	#0,d0
	bra	.quit

.noerror
	move.l  4(a0),d0
.quit	pull	d2-a6
        rts
        
;*************** 
; in: d0 - banknumber
;out: a0 - ^bankinfos in the table (adr.l, size.l)
;     d0 - 0 = error // or -1 = okay
__calcadd:
	lea	__memadd(pc),a0		;takes the result
	lea	_wosbase(pc),a6
	move.l	_mmstabptr(a6),a1
	cmp.l	#0,a1
	bne.s	.notzerook
	moveq	#0,d0			;error
	rts

.notzerook
	move.l	(a1)+,d1		;number of banks in the table

	cmp.l	#0,d0
	ble.s	.error
	
	cmp.l	d1,d0			;banknumber out of table?
	bgt.s	.error
	
	move.l	a1,(a0)
	subq.l	#1,d0
	mulu	#8,d0
	add.l	d0,(a0)			;offset in table
	move.l	(a0),a0
	moveq	#-1,d0			;okay
	rts

.error	moveq	#0,d0
	rts
	
;	SERROR	Calcadd_error


;***************
; in: d0 - size
;out: d0 - adr of memory or 0
;     d1 - banknumber
__allocany:
	push	d2-a6
	move.l	d0,d4
	bsr	__getany
	move.l	d0,d3		;store
	beq.s	.error		;nothing free
	
	move.l	d0,d2
	move.l	#$30001,d1
	move.l	d4,d0
	bsr	__allocbank	;-> adr in d0
	move.l	d3,d1		;-> banknumber in d1

.error
	pull	d2-a6
	rts	

;***************
; in: d0 - size
;out: d0 - adr of memory or 0
;     d1 - banknumber
__allocanychip:
	push	d2-a6
	move.l	d0,d4
	bsr	__getany
	move.l	d0,d3		;store
	beq.s	.error		;nothing free
	
	move.l	d0,d2
	move.l	#$30002,d1
	move.l	d4,d0
	bsr	__allocbank	;-> adr in d0
	move.l	d3,d1		;-> banknumber in d1

.error
	pull	d2-a6
	rts	


;***************
; in: -
;out: d0 - free banknumber or 0
__getany:
	push	d2-a6

	lea	_wosbase(pc),a6
	move.l	_mmstabptr(a6),a1
	move.l	(a1),d2		;memtablesize
	move.l	d2,d4		;""
	subq.l	#1,d2

.getanyloop
	move.l	d4,d0		;memtablesize
	
	sub.l	d2,d0		;bnknum..0 -> 0..bnknum
	move.l	d0,d3		;store
	bsr	__start
	tst	d0		;0 means free
	beq.s	.getanyok
	dbf	d2,.getanyloop	
	moveq	#0,d0		;nothing is free
	pull	d2-a6
	rts	
	
.getanyok
	move.l	d3,d0		;this is free
	pull	d2-a6
	rts	
		

;**********************************************************************
__memfehler:	moveq   #0,d0		; fehler

; in: memadd must be valid (done by __calcadd)
__removeentry:	move.l  __memadd(pc),a0	; auch zum löschen geeignet !
	move.l  #0,(a0)+
	move.l  #0,(a0)+
	rts

.error1	SERROR	MMS-table_sized_0
.error2	SERROR	MMS-table_bad_address

__memadd:	dc.l	0		; points into the memtable (see below)
					; (address,size)

