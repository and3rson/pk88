BIN = $(patsubst %.asm,%.bin,$(shell ls *.asm))

all: $(BIN)

%.bin: %.asm
	nasm $< -o $@

.PHONY: disasm
disasm: $(BIN)
	ndisasm $^ -b 16 -o 0xF0000

.PHONY: clean
clean:
	rm -f *.bin

.PHONY: program
program: $(BIN)
	# minipro -p SMJ27C512@DIP28 -w main.bin -S
	minipro -p W27C512@DIP28 -w main.bin -S
