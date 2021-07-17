.PHONY: all clean compile link fmt strip
BRAINFUCK_PROGRAMS=$(wildcard bf/*.b)
DEBUG_FILES=$(patsubst bf/%.b, debug/%.debug, $(BRAINFUCK_PROGRAMS))

all: compile link sstrip

fmt:
	./nasmfmt brain.asm

clean:
	rm -f *.o brain_debug brain_minified brain_print

compile:
	nasm -felf64 brain.asm -dEXECUTE -o brain_exec.o
	nasm -felf64 brain.asm -dDUMP_CODE -o brain_print.o

link: brain_minified brain_debug brain_print

brain_minified: brain_exec.o
	ld brain_exec.o -s -n -o brain_minified

brain_debug: brain_exec.o
	ld brain_exec.o -o brain_debug

brain_print:
	ld brain_print.o -o brain_print

strip: brain_minified
	strip -x --strip-all -R .comment brain_minified

sstrip: strip
	./sstrip brain_minified

$(DEBUG_FILES) : debug/%.debug : bf/%.b
	[ -d debug ] || mkdir debug
	./brain_print < $^ | ndisasm -b 64 -p intel - > $@

readelf:
	readelf -a brain