	.nolist
	.include "/usr/share/avra/m328Pdef.inc"
	.list

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

;; Interrupt vector table
	rjmp	Reset		; RESET
	reti			; INT0
	reti			; INT1
	reti			; PCINT0
	reti			; PCINT1
	reti			; PCINT2
	reti			; WDT
	reti			; TIMER2 COMPA
	reti			; TIMER2 COMPB
	reti			; TIMER2 OVF
	reti			; TIMER1 CAPT
	reti			; TIMER1 COMPA
	reti			; TIMER1 COMPB
	reti			; TIMER1 OVF
	rjmp	IntrTimer0CompA	; TIMER0 COMPA
	reti			; TIMER0 COMPB
	reti			; TIMER0 OVF
	reti			; SPI STC
	reti			; USART RX
	reti			; USART UDRE
	reti			; USART TX
	reti			; ADC
	reti			; EE READY
	reti			; ANALOG COMP
	reti			; TWI
	reti			; SPM READY

;;----------------------------------------------------------

IntrTimer0CompA:
	reti

;;----------------------------------------------------------

Reset:
	ldi	r16, high(RAMEND)
	out	SPH, r16
	ldi	r16, low(RAMEND)
	out	SPL, r16
	rcall	InitTimer0
	ldi	r16, 0b00100000
	out	DDRB, r16
Loop:
	out     PortB, r16
	ldi	r16, 0b00000000
	out	PortB, r16
	ldi	r16, 0b00100000
	rjmp	Loop

;;----------------------------------------------------------

InitTimer0:
	ldi	r16, 1<<DDD5	; Set OC0B pin to output
	out	DDRD, r16
 	ldi	r16, (1<<COM0A1)|(1<<COM0B1)|(1<<WGM01)|(1<<WGM00)
	out	TCCR0A, r16
	ldi	r16, (1<<WGM02)|(1<<CS00)
	out	TCCR0B, r16
	ldi	r16, 19
	out	OCR0A, r16
	ldi	r16, 0
	out	OCR0B, r16
	ret