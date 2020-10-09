*=832

START=46
END=254
ROM1=$A000
ROM2=$E000

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
copyrom:
	lda mapping
	bne skipstore
	lda $1
	sta mapping
skipstore:
	ldy	#$00
	lda #<ROM1
	sta $61
	lda #>ROM1
	sta $62
	lda #<ROM2
	sta $63
	lda #>ROM2
	sta $64
copy:	
	lda ($61),y
	sta ($61),y
	lda ($63),y
	sta ($63),y
	iny
	bne copy
	inc $62
	inc $64
	bne copy
	lda #0
	sta 59639
	lda mapping
	and #$fd
	sta $1
	rts
resetrom:
	lda mapping
	sta 1
	rts
mapping:
.byte 0
    