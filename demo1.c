#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "inshm.h"


// This is the process that creates the segment. We call it the "maker" for now.
// This process creates a segment of memory that can be shared by other processes
// (that do not share a memory space) in a read/write manner. This process starts,
// creates the segment, spawns two processes that will make accesses to the segment
// both prior to and after this process (the maker) terminates.

int main( int argc, char *argv[] )
{
   struct inSHM_segment_s s;
   size_t isize = 100;
   char cmd[100];


   // create a shared-memory segment, attach to it, and mark it for deletion
   inSHM_CreateSegmentPrivate( &s, isize, 1 );

   // put some data in the segment
   sprintf( (char *) s.shm, "*****************************" );

   // wait some time and spawn a process; provide the process info on the segment
   // via its command-line arguments; the first is the segment identifier, the
   // second is the time to wait until doing anything form the time its is spawned,
   // and the third is an identifier to print on the screen
   printf("Maker is waiting...\n");
   sleep( 2 );
   printf("Maker is spawning a process (sending shmid=%d) \n",s.shmid);
   sprintf( cmd, "./consumer %d %d %s & ", s.shmid, 10, "process1" );
   system( cmd );
   printf("Done \n");

   printf("Maker is waiting...\n");
   sleep( 2 );
   printf("Maker is spawning a process (sending shmid=%d) \n",s.shmid);
   sprintf( cmd, "./consumer %d %d %s & ", s.shmid, 10, "process2" );
   system( cmd );
   printf("Done \n");

   printf("Maker is waiting...\n");
   sleep( 8 );

   printf("------------- Maker detaching and terminating ------------- \n");
   inSHM_DetachSegment( &s, 1 );
   printf("Done \n");

   return(0);
}

