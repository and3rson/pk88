TARGET = main.bin
DEPS = $(shell find . -name '*.asm' -o -name '*.inc')

all: $(TARGET)

%.bin: src/%.asm $(DEPS)
	nasm -i src $< -o $@

.PHONY: disasm
disasm: $(TARGET)
	ndisasm $^ -b 16 -o 0xF0000 | less

.PHONY: clean
clean:
	rm -f *.bin

.PHONY: program
program: $(TARGET)
	minipro -p W27C512@DIP28 -w main.bin -S
