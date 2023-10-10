DESTDIR = bin
TARGET = $(DESTDIR)/main.bin
LDCONFIG = main.ld

SRCDIR = src
INCDIR = include

ELF = $(patsubst %.bin,%.elf,$(TARGET))
SRC = $(shell find $(SRCDIR) -name '*.asm')
OBJ = $(patsubst %.asm,%.o,$(SRC))
DEPS = $(shell find $(INCDIR) -name '*.inc') $(MAKEFILE_LIST) $(LDCONFIG)

ASFLAGS = -i $(INCDIR) -f elf -g -F dwarf -w+gnu-elf-extensions
LDFLAGS = -m elf_i386 -T $(LDCONFIG)

AS = nasm
LD = ld
OBJCOPY = objcopy

all: $(TARGET)

$(TARGET): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(ELF): $(OBJ)
	@mkdir -p $(DESTDIR)
	$(LD) $(LDFLAGS) -o $@ $^

$(SRCDIR)/%.o: $(SRCDIR)/%.asm $(DEPS)
	$(AS) $(ASFLAGS) $< -o $@

.PHONY: disasm
disasm: $(TARGET)
	unbuffer objdump -SDr $(ELF) -M i8086,intel | less -R

.PHONY: clean
clean:
	rm -f $(TARGET) $(ELF) $(OBJ)

.PHONY: program
program: $(TARGET)
	minipro -p W27C512@DIP28 -w $(TARGET) -S
