SOURCES=$(shell find . -type f -iname  "*.asm")
BINARY=netman.cod
VERSION=$(shell cat version.def)

ay:
		sjasmplus main.asm -DAY -DV=$(VERSION)

zxuno:
		sjasmplus main.asm -DUNO -DV=$(VERSION)

clean:
		rm $(BINARY) *.sld