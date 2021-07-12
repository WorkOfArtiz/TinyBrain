.PHONY: all clean compile link


all: compile link

clean:
	rm brain brain.o

compile:
	nasm -felf64 brain.asm -o brain.o

link: brain.o
	ld brain.o -o brain
