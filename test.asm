	.nolist
	.include "/usr/share/avra/m328Pdef.inc"
	.list

	.equ	NPixels = 256
	.equ	Fosc = 16000000
	.equ	BaudRate = 57142 ; Approximately 57600
	.equ	BaudDivisor = Fosc/(8*BaudRate) - 1
	
;; Ard                               328                                Ard
;; Reset        (PCINT14/RESET) PC6 |1  28| PC5 (ADC5/SCL/PCINT13)       A5
;; D0(RX)         (PCINT16/RXD) PD0 |2  27| PC4 (ADC4/SDA/PCINT12)       A4
;; D1(TX)         (PCINT17/TXD) PD1 |3  26| PC3 (ADC3/PCINT11)           A3
;; D2            (PCINT18/INT0) PD2 |4  25| PC2 (ADC2/PCINT10)           A2
;; D3(PWM)  (PCINT19/OC2B/INT1) PD3 |5  24| PC1 (ADC1/PCINT9)            A1
;; D4          (PCINT20/XCK/T0) PD4 |6  23| PC0 (ADC0/PCINT8)            A0
;; VCC                          VCC |7  22| GND                         GND
;; GND                          GND |8  21| AREF                       AREF
;; xtal    (PCINT6/XTAL1/TOSC1) PB6 |9  20| AVCC                        VCC
;; xtal    (PCINT7/XTAL2/TOSC2) PB7 |10 19| PB5 (SCK/PCINT5)            D13
;; D5(PWM)    (PCINT21/OC0B/T1) PD5 |11 18| PB4 (MISO/PCINT4)           D12
;; D6(PWM)  (PCINT22/OC0A/AIN0) PD6 |12 17| PB3 (MOSI/OC2A/PCINT4) (PWM)D11
;; D7            (PCINT23/AIN1) PD7 |13 16| PB2 (SS/OC1B/PCINT2)   (PWM)D10
;; D8        (PCINT0/CLKO/ICP1) PB0 |14 15| PB1 (OC1A/PCINT1)       (PWM)D9

;;----------------------------------------------------------
;; nopn n - n nop's
.macro nopn
	.if @0 > 0
	nop
	nopn	@0-1
	.endif
.endmacro

;; Interrupt vector table
	rjmp	Reset		; RESET
	nop
	reti			; INT0
	nop
	reti			; INT1
	nop
	reti			; PCINT0
	nop
	reti			; PCINT1
	nop
	reti			; PCINT2
	nop
	reti			; WDT
	nop
	reti			; TIMER2 COMPA
	nop
	reti			; TIMER2 COMPB
	nop
	reti			; TIMER2 OVF
	nop
	reti			; TIMER1 CAPT
	nop
	reti			; TIMER1 COMPA
	nop
	reti			; TIMER1 COMPB
	nop
	reti			; TIMER1 OVF
	nop
	reti			; TIMER0 COMPA
	nop
	reti			; TIMER0 COMPB
	nop
	reti			; TIMER0 OVF
	nop
	reti			; SPI STC
	nop
	reti			; USART RX
	nop
	reti			; USART UDRE
	nop
	reti			; USART TX
	nop
	reti			; ADC
	nop
	reti			; EE READY
	nop
	reti			; ANALOG COMP
	nop
	reti			; TWI
	nop
	reti			; SPM READY
	nop

;;----------------------------------------------------------

Reset:
	ldi	r16, high(RAMEND)
	out	SPH, r16
	ldi	r16, low(RAMEND)
	out	SPL, r16
	ldi	r16, (1<<DDB5)|(1<<DDB4)|(1<<DDB3)
	out	DDRB, r16
	rcall	InitUSART
Loop0:	
	sbi	PortB, PB5	; Blink the led
	cbi	PortB, PB5
	;; rcall	WritePix
USART_Transmit:
	lds	r16, UCSR0A
	sbrs	r16, UDRE0
	rjmp	USART_Transmit
	ldi	r16, 'A'
	sts	UDR0, r16
	rjmp	Loop0

;;----------------------------------------------------------

WritePix:
	ldi	r25, high(3*NPixels) ; Load pixel counter
	ldi	r24, low(3*NPixels)
	ldi	XH, high(Neo_Data) ; Load pixel data address
	ldi	XL, low(Neo_Data)
	ldi	r16, 0b00110011
	st	X, r16
Loop1:
	ld	r23, X+		; Load byte from pixel data
	ldi	r22, 8		; Load bit counter
Loop2:
	sbi	PortB, PB3
	nopn	2		; High time 0 bit
	lsl	r23		; Shift the data byte
	brcs	BitOne
	cbi	PortB, PB3
BitOne:
	nopn	4		; Difference between 0 & 1 high time
	cbi	PortB, PB3
	nopn	4		; Low time 1 bit
	dec	r22		; Count the bit
	brne	Loop2
	sbiw	r24, 1
	brne	Loop1
	ret

;;----------------------------------------------------------

InitUSART:
	ldi	r16, high(BaudDivisor) ; Set baud rate
	sts	UBRR0H, r16
	ldi	r16, low(BaudDivisor)
	sts	UBRR0L, r16
	ldi	r16, (1<<RXEN0)|(1<<TXEN0) ; Enable transmitter & receiver
	sts	UCSR0B, r16
	ldi	r16, (3<<UCSZ00) ; Set 8N1 data format
	sts	UCSR0C, r16
	ret

;;==========================================================

	.dseg
Neo_Data:
	.byte	3*NPixels

;;==========================================================
