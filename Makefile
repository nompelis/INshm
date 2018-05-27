CC = gcc
COPTS = -fPIC -Wall -O0

FC = gfortran
FOPTS = -fPIC -Wall -O0 -ffixed-line-length-132


all: lib prog

lib:
	$(CC) $(COPTS) -c inshm.c
	$(CC) $(COPTS) -c inshm_fortran.c

prog:
	$(CC) $(COPTS) main.c inshm.o inshm_fortran.o

demo: lib
	$(CC) $(COPTS) demo1.c inshm.o -o maker
	$(CC) $(COPTS) demo2.c inshm.o -o consumer

demo2: lib
	$(FC) $(FOPTS) demo1.f inshm.o inshm__fortran.o -o maker
	$(FC) $(FOPTS) demo2.f inshm.o inshm__fortran.o -o consumer

clean:
	rm -f *.o *.out maker consumer 

