.PHONY: all clean compile link fmt strip


all: compile link strip

fmt:
	./nasmfmt brain.asm

clean:
	rm brain brain.o

compile:
	nasm -felf64 brain.asm -o brain.o

link: brain.o
	ld brain.o -s -n -o brain
	#ld brain.o -o brain

strip: brain
	strip -x --strip-all -R .comment brain

readelf:
	readelf -a brain