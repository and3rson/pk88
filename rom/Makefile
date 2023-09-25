BIN = $(patsubst %.asm,%.bin,$(shell ls *.asm))

all: $(BIN)

%.bin: %.asm
	nasm $< -o $@
	ndisasm $@ -b 16 -o 0xF0000

.PHONY: clean
clean:
	rm -f *.bin

.PHONY: program
program:
	minipro -p W27C512@DIP28 -w main.bin -S
