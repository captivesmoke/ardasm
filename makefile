AVRA = ~/proj/avra/avra
INCDIR = /usr/share/avra

test.hex: test.asm
	$(AVRA) -l test.lst test.asm

prgm:
	avrdude -p m328p -P /dev/ttyUSB0 -c arduino -b 57600 -D -U flash:w:test.hex:i