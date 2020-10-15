*=53180

sid=54272

	lda #80
	sta sid
	lda #17
	sta sid+1
	lda #33
	sta sid+5
	lda #241
	sta sid+6
	lda #15
	sta sid+24
	lda #17
	sta sid+4
	
	lda 162
	clc
	adc #4
	adc #0
	sta 2
loop:
	lda 162
	cmp 2
	bcc loop
	lda #16
	sta sid+4
	rts
	
	
	