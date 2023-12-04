DESTDIR = bin
TARGET = $(DESTDIR)/metalbios.bin
LDCONFIG = metalbios.ld
DEPFILE = make.dep

SRCDIR = src
INCDIR = include

ELF = $(patsubst %.bin,%.elf,$(TARGET))
SRC = $(shell find $(SRCDIR) -name '*.asm')
OBJ = $(patsubst %.asm,%.o,$(SRC))
DEPS = $(shell find $(INCDIR) -name '*.inc')

# nasm flags
ASFLAGS = -i $(INCDIR) -f elf -g -F dwarf -w+gnu-elf-extensions -w+orphan-labels
# yasm flags
# ASFLAGS = -i $(INCDIR) -f elf -g dwarf2 -w+gnu-elf-extensions -w+orphan-labels
LDFLAGS = -m elf_i386 -T $(LDCONFIG)

AS = nasm
# yasm does not generate proper paths in the dep file
# AS = yasm
LD = ld
OBJCOPY = objcopy

all: $(TARGET)

$(DEPFILE): $(SRC) $(DEPS)
	rm -f $(DEPFILE)
	for i in $(SRC); do \
		$(AS) $(ASFLAGS) $$i -M >> $(DEPFILE); \
	done

$(TARGET): $(ELF)
	$(OBJCOPY) -O binary $< $@

$(ELF): $(OBJ) | $(LDCONFIG)
	@mkdir -p $(DESTDIR)
	$(LD) $(LDFLAGS) -o $@ $^

$(SRCDIR)/%.o: $(SRCDIR)/%.asm | $(DEPFILE)
	$(AS) $(ASFLAGS) $< -o $@

.PHONY: disasm
disasm: $(TARGET)
	unbuffer objdump -Sdr $(ELF) -M i8086,intel | less -R

.PHONY: clean
clean:
	rm -f $(TARGET) $(ELF) $(OBJ) $(DEPFILE)

.PHONY: program
program: $(TARGET)
	minipro -p W27C512@DIP28 -w $(TARGET) -S

include $(DEPFILE)
