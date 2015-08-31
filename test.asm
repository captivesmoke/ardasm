	.nolist
	.include "/usr/share/avra/m328Pdef.inc"
	.list

	ldi	r16, 0b00100000
	out	DDRB, r16
Loop:
	out     PortB, r16
	ldi	r16, 0b00000000
	out	PortB, r16
	ldi	r16, 0b00100000
	rjmp	Loop

Start:
	rjmp	Start