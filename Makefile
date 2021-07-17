.PHONY: all clean compile link fmt strip
BRAINFUCK_PROGRAMS=$(wildcard bf/*.b)
DEBUG_FILES=$(patsubst bf/%.b, debug/%.debug, $(BRAINFUCK_PROGRAMS))

all: compile link strip sstrip

fmt:
	./nasmfmt brain.asm

clean:
	rm brain brain.o

compile:
	nasm -felf64 brain.asm -o brain.o

link: brain.o
	ld brain.o -s -n -o brain
	@#ld brain.o -o brain

strip: brain
	strip -x --strip-all -R .comment brain

sstrip: brain
	./sstrip brain

$(DEBUG_FILES) : debug/%.debug : bf/%.b
	[ -d debug ] || mkdir debug
	./brain < $^ | ndisasm -b 64 -p intel - > $@

readelf:
	readelf -a brain