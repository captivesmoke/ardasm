AVRA = ~/proj/avra/avra
INCDIR = /usr/share/avra

test.hex: test.asm
	$(AVRA) -l test.lst test.asm
