### look in this file to force the use of a different compiler and/or options
include Makefile.in

### options for the various compilers
ifeq ($(COMPILER),gnu)
   CC ?= gcc
   COPTS ?= -fPIC -Wall -O0

   FC ?= gfortran
   FOPTS ?= -fPIC -Wall -O0 -ffixed-line-length-132 -fbounds-check
endif

ifeq ($(COMPILER),pgi)
   CC ?= pgcc
   COPTS ?= -fPIC -Mbounds -O0

   FC ?= pgf90
   FOPTS ?= -fPIC -Mextend -Mbounds -O0
endif

ifeq ($(COMPILER),intel)
   CC ?= icc
   COPTS ?= -fPIC -O0

   FC ?= ifort
   FOPTS ?= -fPIC -extend-source -check bounds -check pointer -check uninit -O0
endif

all: lib prog

lib:
	$(CC) $(COPTS) -c inshm.c
	$(CC) $(COPTS) -c inshm_fortran.c
	$(FC) $(FOPTS) -c inshm_module.f

### a simple C based demonstration
prog:
	$(CC) $(COPTS) main.c inshm.o inshm_fortran.o

### a C based multi-process demonstration
demo: lib
	$(CC) $(COPTS) demo1.c inshm.o -o maker
	$(CC) $(COPTS) demo2.c inshm.o -o consumer

### a Fortran based multi-process demonstration
demo2: lib
	$(FC) $(FOPTS) fdemo1.f inshm.o inshm_fortran.o inshm_module.o -o maker
	$(FC) $(FOPTS) fdemo2.f inshm.o inshm_fortran.o inshm_module.o -o consumer

clean:
	rm -f *.o *.out maker consumer *.mod

