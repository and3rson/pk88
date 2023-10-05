TARGET = bin/main.bin
SRC = $(shell find . -name '*.asm')
OBJ = $(patsubst %.asm,%.o,$(SRC))
ELF = $(patsubst %.bin,%.elf,$(TARGET))
LDCONFIG = main.ld
DEPS = $(shell find . -name '*.inc') $(MAKEFILE_LIST) $(LDCONFIG)

all: $(TARGET)

$(TARGET): $(ELF)
	@# ld -m elf_i386 -Ttext=0xF000 --section-start=.rodata=0xF000 --section-start=.reset=0xFFF0 --oformat binary -o $@ $^
	objcopy -O binary $^ $@

$(ELF): $(OBJ)
	ld -m elf_i386 -T $(LDCONFIG) -o $@ $^

src/%.o: src/%.asm $(DEPS)
	nasm -i src $< -f elf -g -F dwarf -w+gnu-elf-extensions -o $@

.PHONY: disasm
# disasm: $(TARGET)
disasm:
	# ndisasm bin/main.bin -b 16 -o 0xF0000 | less
	unbuffer objdump -SDr $(ELF) -M i8086,intel | less -R

.PHONY: clean
clean:
	rm -f $(TARGET) $(ELF) $(OBJ)

.PHONY: program
program: $(TARGET)
	minipro -p W27C512@DIP28 -w $(TARGET) -S
