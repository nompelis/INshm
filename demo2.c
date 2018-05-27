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
   int itime,ier;


   if( argc == 1 ) {
      printf("You are not supposed to execute this program on your own!\n");
      return(1);
   }

   s.shmid = atoi( argv[1] );
   itime = atoi( argv[2] );

   printf(" - Process \"%s\" to attach to shmid=%d \n", argv[3], s.shmid );

   // create a shared-memory segment, attach to it, and mark it for deletion
   ier = inSHM_AttachSegment( &s, s.shmid, 1 );
   if( ier == 0 ) {
      printf(" - Process \"%s\" attached to segment %d \n", argv[3], s.shmid );
   } else {
      printf(" - Process \"%s\" failed to attach to segment %d \n",argv[3],s.shmid);
      return(2);
   }

   // print the (char) data that is in the segment
   printf(" - Process \"%s\" printing: \"%s\" \n", argv[3], (char *) s.shm );

   // over-write the buffer
   printf(" - Process \"%s\" writing in segment \n", argv[3] );
   sprintf( (char *) s.shm, "1111111" );

   printf(" - Process \"%s\" is waiting %d seconds... \n", argv[3], itime );
   sleep( itime );

   printf(" - Process \"%s\" detaching and terminating \n", argv[3]);
   inSHM_DetachSegment( &s, 1 );

   return(0);
}

