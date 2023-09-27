TARGET = $(shell pwd | xargs basename).zip
SOURCES := Top.gbr Bot.gbr TopMask.gbr BotMask.gbr TopSilk.gbr BotSilk.gbr Board.gbr DrillPlated.drl MillPlated.drl

$(TARGET): $(SOURCES)
	rm -f $(TARGET)
	zip -r $(TARGET) $(SOURCES)

Top.gbr: 1\ -\ F.Cu.gbr
	cp "1 - F.Cu.gbr" Top.gbr

Bot.gbr: 2\ -\ B.Cu.gbr
	cp "2 - B.Cu.gbr" Bot.gbr

BotMask.gbr: BottomMask.gbr
	cp BottomMask.gbr BotMask.gbr

BotSilk.gbr: BottomSilk.gbr
	cp BottomSilk.gbr BotSilk.gbr

Board.gbr: BoardOutline.gbr
	cp BoardOutline.gbr Board.gbr

.PHONY: clean
clean:
	rm *.gbr *.drl $(TARGET)

.PHONY: view
view:
	gerbview $(SOURCES)
