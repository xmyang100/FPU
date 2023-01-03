COMPILE = gcc -c -Wall -O  # Command to compile a module from .c to .o
LINK =    gcc -Wall        # Command to link .o to executable file


# Make all the main programs, first makes the modules used by main programs
progs:	modules
	$(COMPILE) main.c
	$(LINK) main.o flt16.o -lm -o main
	rm -rf *.o

# Make the modules used by main programs
modules:
	$(COMPILE) flt16.c