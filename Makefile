SOURCES=$(shell find . -type f -iname  "*.asm")
BINARY=netman.cod
VERSION=$(shell cat version.def)

ay:
		sjasmplus main.asm -DAY -DESXCOMPAT -DV=$(VERSION)

zxuno:
		sjasmplus main.asm -DUNO -DESXCOMPAT -DV=$(VERSION)

karabas-pro:
		sjasmplus main.asm -DUNO -DHOB -DV=$(VERSION)

clean:
		rm -f $(BINARY) *.sld netman.?c
