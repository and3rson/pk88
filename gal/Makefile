SOURCES = $(wildcard src/*.pld)
OBJECTS = $(SOURCES:.pld=.jed)
TESTS = $(SOURCES:.pld=.vec)

all: $(OBJECTS)

src/%.jed: src/%.pld
	galasm -c -p -f -v $<

.PHONY: clean
clean:
	rm -f bin/*
	rm -f src/*.jed src/*.fus src/*.chp src/*.pin src/*.hex src/*.lgc

.PHONY: test
test: $(SRC)
	@for test in $(TESTS); do \
		echo "*** $$test"; \
		ginger $${test%.*}.pld $$test; \
		echo; \
	done

.PHONY: program
program: src/$(PROGRAM).jed
ifndef PROGRAM
	$(error PROGRAM is required)
endif
	minipro -p ATF16V8B -w ./src/$(PROGRAM).jed -z
