TARGET = $(shell pwd | xargs basename).zip
SOURCES := Top.gbr Bot.gbr TopMask.gbr BotMask.gbr TopSilk.gbr BotSilk.gbr Board.gbr DrillPlated.drl # MillPlated.drl
KICAD_SRC := $(patsubst %,main-%,$(SOURCES))

all: $(TARGET)

$(TARGET): $(SOURCES)
	rm -f $(TARGET)
	zip -r $(TARGET) $(SOURCES)

%.gbr: main-%.gbr
	cp $^ $@

DrillPlated.drl: main-PTH.drl
	cp $^ $@

.PHONY: clean
clean:
	rm *.gbr *.drl $(TARGET)

.PHONY: view
view:
	gerbview $(SOURCES)
