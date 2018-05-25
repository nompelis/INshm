# INshm
A lean API for using Unix/Linux intra-node shared-memory across processes
in Fortran programs that run on distributed parallel systems

SUMMARY

1. Use this library if you want your MPI Fortran code to share chunks of
memory within a given node/host.

2. Proper clean-up of the memory segment is possible, leaving no memory
behind past the program life-cycle.

3. It is easier to use than it sounds!


MOTIVATION

This library is most useful when used in conjunction with a distributed
parallel software framework, for example, scientific simulation software
that synchronizes using the message passing interface (MPI) or similar library.
Primarily, it allows for multiple processes to not have to duplicate large
chunks of identical data, which can become a potential bottleneck, rendering
some operations impossible due to lack of memory on a given host. It is also
meant to be used primarily by Fortran programmers.

The main motivation for authoring this library is to allow for processes that
execute on the same host (and on the same NUMA node within the host) to have
access to a common segment of memory. This is something that can be done very
easily with a threaded implementation, and within hybrid distributed-threaded
software (e.g. parallelization with MPI and POSIX threads, or the more popular
loop-based parallelization using OpenMP). Experience shows, however, that the
programming paradigm that continues to survive as the "de facto" practice in
the scientific computing and simulation communities involves the naive spawning
of one process for every core. (There are many good reasons for doing this, but
this is not discussed here.)


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
terminated (or killed). In that case, the memory segment would have to be
cleaned-up by calling 'iprm' manually from the shell, a highly undesirable
situation (with potential consequences on system stability and usability in
extreme cases).

A related point must be made with regard to the order of creation, attachment
and flagging operations. The owner process that creates the segment has to
attach to it prior to flagging it for removal. This may not be obvious at first
but the kernel has no reason for keeping the segment around if it has been
flagged for removal. But more importantly, this is precisely the mechanism of
removal of the segment if it is to have a life-cycle shorter than the processes
that accessed it (i.e. creating a segment and only using it for some period and
then discarding it while execution continues indefinitely).

Process other than the process that created (and already attached to) the
segment should attach to it only after they have been notified of the segment's
id. Once this has happened, all processes --in the present library-- have read
and write access to the segment. Any process that terminates is no longer
attached to the segment; the kernel keeps track of the processes that are
attached to each shared memory segment, as well at some other information.

TO BE CONTINUED...


IN 2018/05/25
