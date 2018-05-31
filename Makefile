CC = gcc
COPTS = -fPIC -Wall -O0

FC = gfortran
FOPTS = -fPIC -Wall -O0 -ffixed-line-length-132


all: lib prog

lib:
	$(CC) $(COPTS) -c inshm.c
	$(CC) $(COPTS) -c inshm_fortran.c
	$(FC) $(FOPTS) -c inshm_module.f

prog:
	$(CC) $(COPTS) main.c inshm.o inshm_fortran.o

demo: lib
	$(CC) $(COPTS) demo1.c inshm.o -o maker
	$(CC) $(COPTS) demo2.c inshm.o -o consumer

demo2: lib
	$(FC) $(FOPTS) fdemo1.f inshm.o inshm_fortran.o inshm_module.o -o maker
	$(FC) $(FOPTS) fdemo2.f inshm.o inshm_fortran.o inshm_module.o -o consumer

clean:
	rm -f *.o *.out maker consumer *.mod

