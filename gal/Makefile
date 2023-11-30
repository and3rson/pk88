GALASM_SOURCES = $(wildcard src/*.gpld)
CUPL_SOURCES = $(wildcard src/*.pld)
GALASM_OBJECTS = $(GALASM_SOURCES:.gpld=.jed)
CUPL_OBJECTS = $(CUPL_SOURCES:.pld=.jed)
GALASM_TESTS = $(CUPL_SOURCES:.pld=.vec)

all: $(GALASM_OBJECTS) $(CUPL_OBJECTS)

src/%.jed: src/%.gpld
	@#galasm -c -p -f -v $<
	galasm -v $<

src/%.jed: src/%.pld
	bin/cupl/cupl.exe -j -xu bin/cupl/cupl.dl $<
	@# Rename file from uppercase to lowercase,
	@# e. g. src/FOO.pld to src/foo.pld
	@# This is needed only when the file is created for the first time.
	@NAME=$(shell echo $@ | sed -re 's/\/([^\.]+)/\/\U\1/g') sh -c 'mv $$NAME $@' 2>/dev/null || true

.PHONY: clean
clean:
	rm -f src/*.jed src/*.fus src/*.chp src/*.pin src/*.hex src/*.lgc

.PHONY: test
test: $(SRC)
	@set -e; for test in $(GALASM_TESTS); do \
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
