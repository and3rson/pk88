GALASM_SOURCES = $(wildcard src/*.gpld)
CUPL_SOURCES = $(wildcard src/*.pld)
GALASM_OBJECTS = $(SOURCES:.gpld=.jed)
CUPL_OBJECTS = $(SOURCES:.pld=.jed)
TESTS = $(SOURCES:.pld=.vec)

all: $(GALASM_OBJECTS) $(CUPL_OBJECTS)

src/%.jed: src/%.gpld
	@#galasm -c -p -f -v $<
	galasm -v $<

src/%.jed: src/%.pld
	../bin/cupl.exe -j -xu cupl.dl $<
	mv $@ $(@:.JED=.jed)

.PHONY: clean
clean:
	rm -f bin/*
	rm -f src/*.jed src/*.fus src/*.chp src/*.pin src/*.hex src/*.lgc

.PHONY: test
test: $(SRC)
	@set -e; for test in $(TESTS); do \
		echo "*** $$test"; \
		python3 ~/src/ginger/ginger/__main__.py $${test%.*}.pld $$test; \
		echo; \
	done

.PHONY: program
program: src/$(PROGRAM).jed
ifndef PROGRAM
	$(error PROGRAM is required)
endif
	minipro -p ATF16V8B -w ./src/$(PROGRAM).jed -z

.PHONY: program
program-22v10: src/$(PROGRAM).jed
ifndef PROGRAM
	$(error PROGRAM is required)
endif
	minipro -p 'ATF22V10C(UES)' -w ./src/$(PROGRAM).jed -z
