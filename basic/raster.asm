*=832

START=46
END=254

	sei                                 
	lda #<myraster
	sta $0314 
	lda #>myraster
	sta $0315
	 
	lda #START
	sta $d012
	 
	lda $d011
	and #127
	sta $d011
	 
	lda $d01a
	ora #1
	sta $d01a
	cli
	rts

myraster: 
	lda $d019
	bmi raster
 	lda $dc0d
 	cli
 	jmp $ea31 
 	
raster:	                       
	sta $d019
	lda $d012
	cmp #END
 	bcs setstart
 	lda color
 	sta $d020
 	lda #END
 	sta $d012
 	jmp exit
 
setstart:
 	lda topcolor
 	sta $d020
 	lda #START
 	sta $d012

exit:
	pla                              
	tay
	pla                                
	tax
	pla                            
	rti
 
 topcolor:
 .byte 11
 
 color:
 .byte 0
 
 rasteroff:
 	sei 
	lda $d01a
	and #14
	sta $d01a
	lda color
	sta $d020
	cli
	rts
rasteron:
	sei 
	lda $d01a
	ora #1
	sta $d01a
	cli
	rts
	
    