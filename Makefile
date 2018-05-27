CC = gcc
COPTS = -fPIC -Wall -O0

FORT = gfortran
FOPTS = -fPIC -Wall -O0 -ffixed-line-length-132


all: lib prog

lib:
	$(CC) $(COPTS) -c inshm.c

prog:
	$(CC) $(COPTS) main.c inshm.o 

demo: lib
	$(CC) $(COPTS) demo1.c inshm.o -o maker
	$(CC) $(COPTS) demo2.c inshm.o -o consumer

clean:
	rm -f *.o *.out maker consumer 

