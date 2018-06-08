# INshm
A lean API for using Unix/Linux intra-node shared-memory across processes
in Fortran programs that run on distributed parallel systems

SUMMARY

1. Use this library if you want your MPI Fortran code to share chunks of
memory within a given node/host.

2. Proper clean-up of the memory segment takes place, leaving no memory
behind past the program life-cycle.

3. It is easier to use than it sounds!

4. There are a C and a Fortran demo included, for those learning by example.


USING THE LIBRARY

- Compiling

At present, the library code is expected to be used in a very crude manner, and
this is so that things are quick, simple and intuitive. This will change...
Modify the Makefile to put your own compiler and compiler options to be used.
Type 'make' and you are done.

The library needs to be compiled with a C and a Fortran compiler. Once compiled,
the library and its core functionality consists of the following compiled
objects: inshm.o inshm_fortran.o inshm_module.o and inshm.mod. Compiling code
against this library is, at present, as simple as adding the necessary object
files to the (linking) command.

Building a simple C program that uses the library looks like this:
  'cc main.c inshm.o'

Building a simple Fortran program that uses the library looks like this:
  'fort main.f inshm.o inshm_fortran.o inshm_module.o'

When compiling code with fortran, one must use the module for all subroutines
that need access to the library API. A subroutine should begin with something
like this:
```
      Subroutine my_operation()
      Use inshm
      Implicit None
      !--- procedure code goes here
      End subroutine
```

- Using shared-memory segments in your code

Using the API to create and to access shared-memory segments is simple. The
main idea to keep in mind is that one has to specify which process will be the
owner, or initial creator, of the shared memory segment. In all cases, this
process needs to be started first. When using this library, the process that
creates the segment will automatically attach to it as soon as the segment is
created (see below for explanations and a more technical discussion). This
process can attach to the segment in multiple ways, or detach and re-attach
to it later, etc, so long as the segment is still around (see below for the
technical explanation for this).

Other processes that will be accessing the memory segment have to start after
the segment has been created, and they need to be somehow notified of the
identifier for the segment to which they must attach. How this is done is up
to the programmer. For example, one idea is to have a file that stores some
information, and then, processes that need to attach to the segment will have
to read the segment identifier from this file and subsequently attach to it.
This is just a matter of convention and flow-control, both dictated by the
programmer. Another idea is to have sockets or pipes opened, through which
the segment identifier can be communicated. And lastly, and the main reason
behind the motivation of creating this library, is to have processes start
simultanuously from a library that coordinates distributed parallel processing.
In this case, the programmer will have to introduce flow-control such that a
process creates the memory segment on a given host (or NUMA node) and other
processes subsequently attach to it. In this case, conventions need to be
introduced, querying of hostnames to group processes on hosts, and queries of
the NUMA nodes to group processes by NUMA nodes.

For C programmers, creating and accessing memory segments is very simple.
Here is the process that creates the memory segment:
```
int main() {
   struct inSHM_segment_s s;
   size_t isize = 100;

   inSHM_CreateSegmentPrivate( &s, isize, 1 );

   // put some data in the segment
   sprintf( (char *) s.shm, "*****************************" );

   // go into an infinite loop for now...
   while(1) { usleep(100000); }

   inSHM_DetachSegment( &s, 1 );

   return(0);
}
```
All the programmer has to do is look at the inSHM_segment_s structure for
two key components, the segment identifier and the pointer to the allocated
memory segment. The pointer can be re-cast to anything one needs, just as in
the example above is cast to a memory of "char" type. The identifier is going
to be communicated to any processes that may need to connect to the shared
memory segment.

Programs that will access the memory segment will look like this:
```
int main() {
   struct inSHM_segment_s s;

   shmid = method_to_get_notified_of_SHMid();

   ier = inSHM_AttachSegment( &s, shmid, 1 );
   // check for errors

   // over-write in the shared memory segment right away!
   sprintf( (char *) s.shm, "1111111" );

   inSHM_DetachSegment( &s, 1 );

   return(0);
}
```

For Fortran programmers it is also simple enough, although instead of the
structures, we access memory segments via handles. This is to hide a lot of
the library operations that make use of the core library functionality, which
is written in C, something that can create confusion.

The process that creates (and attaches to) the segment needs to make the API
call to create the segment, and then it needs to take that piece of memory and
associate it with the pointer through which the data will be accessed. At the
end, the process will detach (but not necessarily at termination). An example
of this is here:
```
      Program maker
      Use inshm
      Implicit None
      Integer(KIND=4) ishm_handle, ishm_id, ier
      Integer(KIND=8) lshm_size
      Integer(KIND=4), dimension(:), Pointer :: p
      Integer(KIND=4) iarray_size(7)

      lshm_size = 100 * 4     ! 100x 4-byte integers, for example

      call inSHM_CreateSegment_f( lshm_size, ishm_handle, ishm_id, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'
      PRINT*,'Segment ID (shmid) is',ishm_id

      call inshm_AssignPointer_f( ishm_handle, p, iarray_size, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'

      call system( 'sleep 3600' )

      call inSHM_DetachSegment_f( ishm_handle, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'

      End
```

A program that will attach to an existing shared-memory segment and use it
will look like this:
```
      Program consumer
      Use inshm
      Implicit None
      Integer(KIND=4) ishm_handle, ishm_id, ier
      Integer(KIND=4),dimension(:),Pointer :: p
      Integer(KIND=4) iarray_size(7)
      Integer i


      !--- Get the segment identifier from the user
      PRINT*,'Type the segment indeitifier (an integer)'
      READ(*,*) ishm_id
      PRINT*,'Segment ID (shmid) to attach is',ishm_id

      call inSHM_AttachSegment_f( ishm_id, ishm_handle, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'

      iarray_size(1) = 100   !! this should be known externally (communicated)
      call inshm_AssignPointer_f( ishm_handle, p, iarray_size, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'
      !--- data should have been set by the maker
      do i = 1,5   ! only the first few
         PRINT*,'p(i)=', p(i)
      enddo

      call inSHM_DetachSegment_f( ishm_handle, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'

      End
```

The order of creation of the segment and accesses for reading and writing can
be externally coordinated. In the case of distributed computing with a message
passing library like MPI, the process is straightforward.


MOTIVATION

This library is most useful when used in conjunction with a distributed
parallel software framework, for example, scientific simulation software
that synchronizes using the message passing interface (MPI) or similar library.
Primarily, it allows for multiple processes to not have to duplicate large
chunks of identical data, which can become a potential bottleneck, rendering
some operations impossible due to lack of memory on a given host. It is also
meant to be used primarily by Fortran programmers, who do not have access to
a straightforward way of performing such operations.

The main motivation for authoring this library is to allow for processes that
execute on the same host (and on the same NUMA node within the host) to have
access to a common segment of memory. This is something that can be done very
easily with a threaded implementation, and within hybrid distributed-threaded
software (e.g. parallelization with MPI and POSIX threads, or the more popular
loop-based parallelization using OpenMP). Experience shows, however, that the
programming paradigm that continues to survive as the "de facto" practice in
the scientific computing and simulation communities involves the naive spawning
of one process for every core. (There are many good reasons for doing this, but
those are not discussed here.)


OVERVIEW OF THE FUNCTIONALITY AND IMPORTANT TECHNICAL DETAILS

This is a library that allows a program that is written in Fortran to access
shared memory on a Unix/Linux system, in an effort to avoid duplication of large
chunks of identical data. Namely, it allows for processes with different memory
spaces (values stored in pointers are not meaningful across processes)
to share a piece of memory. The shared memory can be accessed for both reads
and writes. However, this requires synchronization of the processes at the
flow-control level semantics, such that any conflicts are avoided. For this
purpose, semaphores and other structures can be used for flow control, although
this library intentionally does not introduce or make use of such concepts.
Rather, the library provides a relatively low-level API functionality on top of
which the programmer can introduce their own flow-control. This requires that
some logic and synchronization are architected and programmed, but it provides
more flexibility.

The library relies on the shared memory operations of the Unix system that
conforms to the POSIX standard "SVr4, POSIX.1-2001" as per the 3.23 (2008-06-03)
Linux man-pages project. It utilizes the following calls: shmget(), shmctl(),
shmat() and shmdt(). It also utilizes the Fortran "C_ISO" functionality to
handle pointers across the native C calls and the Fortran procedures.

The library creates a shared memory segment with ownership by the calling
process. It immediately attaches the memory segment to this process, which
effectively provides an address pointing to the start of the shared memory
segment. And following that, it notifies the kernel that the shared memory
segment can be deleted once no processes are attached to it.

This last part is necessary for subsequent clean-up of the segment in the event
that the processes that access it terminate ungracefully (for example, because
of a segmentation fault, kernel kill, etc), and prior to having detached from
the segment. Not having flagged the segment for deletion would have the kernel
maintain that memory segment even after all processes that attached to it have
terminated (or were killed). In that case, the memory segment would have to be
cleaned-up by calling 'iprm' manually from the shell, a highly undesirable
situation (with potential consequences on system stability and usability in
extreme cases).

A related point must be made with regard to the order of creation, attachment
and flagging operations. The owner process that creates the segment has to
attach to it prior to flagging it for removal. This may not be obvious at first,
but the kernel has no reason for keeping the segment around if it has been
flagged for removal. But more importantly, this is precisely the mechanism of
removal of the segment if it is to have a life-cycle shorter than the processes
that accessed it (i.e. creating a segment and only using it for some period of
time and then discarding it while execution continues indefinitely).

Process other than the process that created (and already attached to) the
segment should attach to it only after they have been notified of the segment's
id. Once this has happened, all processes --in the present library-- have read-
and write-access to the segment. Any process that terminates is no longer
attached to the segment; the kernel keeps track of the processes that are
attached to each shared memory segment, as well at some other information.


IN 2018/06/01
