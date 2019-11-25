all: Proyecto1.asm
	nasm -f elf64 -l Proyecto1.lst -o Proyecto1.o Proyecto1.asm
	ld Proyecto1.o
	gdb a.out

clean:
	rm Proyecto1
