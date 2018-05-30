#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>

#include "inshm.h"

static struct inSHM_segment_s * global_inshm_handles = NULL;
static int global_inshm_handles_num = 0;


//
// Function to retrieve a handle from the global array of handles
// It enlarges the global array of handles if needed
//

int inSHM_Fortran_GetSegment(
      int *handle,
      int iverb )
{
   int ichunk = 10;
   int nhandles;
   struct inSHM_segment_s *s;
   int n;


   if( global_inshm_handles == NULL ) {
      global_inshm_handles_num = 0;
   } else {

      for( n=0; n<global_inshm_handles_num; ++n ) {
         struct inSHM_segment_s *p = &( global_inshm_handles[n] );

         if( p->shmid == -1 ) {
            if( iverb != 0 )
               printf("Reusing old (unsued) handle %d \n", n);
            *handle = n;
            return(0);
         }
      }

   }

   nhandles = global_inshm_handles_num + ichunk;

   s = (struct inSHM_segment_s *) realloc( (void *) global_inshm_handles,
              ((size_t) nhandles) * sizeof(struct inSHM_segment_s) );
   if( s == NULL ) {
      if( iverb != 0 )
         printf("Could not reallocate global inshm_s handles array!\n");
      return(-1);
   } else {
      if( iverb != 0 )
         printf("(Re)allocated global handles array \n");
   }

   if( iverb != 0 )
      printf("Initializing newly added elements (%d) \n",ichunk);
   for( n=global_inshm_handles_num; n<nhandles;++n ) {
      struct inSHM_segment_s *p = &( s[ n ] );

      p->shmid = -1;
      p->key = 0;
      p->size = 0;
      p->shm = (void *) NULL;
   }

   *handle = global_inshm_handles_num;

   global_inshm_handles = s;
   global_inshm_handles_num = nhandles;

   return(0);
}


//
// Function to potentially discard the global array of handles
//

int inSHM_Fortran_DropSegment(
      int handle,
      int iverb )
{
   int n,idrop=0;
   struct inSHM_segment_s *p;


   // sanity check
   if( global_inshm_handles == NULL ) {
      if( iverb != 0 )
         printf("Error: there should be no handles floating around! \n");
      return(1);
   }

   if( handle >= global_inshm_handles_num ) {
      if( iverb != 0 )
         printf("Error: Invalid handle to discard! (%d) \n", handle );
      return(2);
   }

   if( global_inshm_handles[ handle ].shmid >= 0 ) {
      if( iverb != 0 )
         printf("Error: Handle seems to be un-clean!\n");
      return(3);
   }

   // drop the array if there are not segments in use
   p = global_inshm_handles;
   idrop = global_inshm_handles_num;
   for(n=0;n<global_inshm_handles_num;++n) {
      if( p[n].shmid == -1 ) --idrop;
   }

   if( idrop == 0 ) {
      free( global_inshm_handles );
      global_inshm_handles = NULL;
      global_inshm_handles_num = 0;
   }

   return(0);
}


//
// Function to create a shared memory segment
//

int inSHM_Fortran_CreateSegment(
      long *size,
      int *handle,
      int *shmid,
      int iverb )
{
   size_t isize = (size_t ) (*size);
   struct inSHM_segment_s *s;
   int ier,ihandle;


   ier = inSHM_Fortran_GetSegment( &ihandle, iverb );
   if( ier != 0 ) {
      if( iverb != 0 )
         printf("Could not get an unused or a new handle!\n");
      return(1);
   }

   s = &( global_inshm_handles[ ihandle ]);

   ier = inSHM_CreateSegmentPrivate( s, isize, iverb );
   if( ier != 0 ) {
      if( iverb != 0 )
         printf("Could not create shared memory segment \n");

      if( ier == 4 ) {
         if( inSHM_DetachSegment( s, iverb ) != 0 ) {
         if( iverb != 0 )
            printf("Also had trouble detaching! \n");
         }
         s->shmid = -1;
         s->size = 0;
         // s->shm may be a number... No hope of doing anything about it here
      }

      (void) inSHM_Fortran_DropSegment( ihandle, iverb );

      return(2);
   }

   *handle = ihandle;
   *shmid = s->shmid;

   return(0);
}

void inshm_fortran_createsegment_(
      long *size,
      int *handle,
      int *shmid,
      int *iverb, int *ier )
{
   *ier = inSHM_Fortran_CreateSegment( size, handle, shmid, *iverb );
}


//
// Detach from a shared memory segment
//

int inSHM_Fortran_DetachSegment(
      int handle,
      int iverb )
{
   struct inSHM_segment_s *s;


   // sanity check
   if( global_inshm_handles == NULL ) {
      if( iverb != 0 )
         printf("Error: there should be no handles floating around! \n");
      return(1);
   }

   if( handle >= global_inshm_handles_num ) {
      if( iverb != 0 )
         printf("Error: Invalid handle to detach from (%d) \n", handle );
      return(2);
   }

   if( global_inshm_handles[ handle ].shmid < 0 ) {
      if( iverb != 0 )
         printf("Error: Handle seems to have been cleaned \n");
      // we will drop the segment even though we return an error code
      (void) inSHM_Fortran_DropSegment( handle, iverb );
      return(3);
   }

   s = &( global_inshm_handles[ handle ] );
   if( inSHM_DetachSegment( s, iverb ) != 0 ) {
      if( iverb != 0 )
         printf("Error: Could not cleanly detach from segment \n");
      return(4);
   }

   (void) inSHM_Fortran_DropSegment( handle, iverb );

   return(0);
}


void inshm_fortran_detachsegment_(
      int *handle,
      int *iverb, int *ier )
{
   *ier = inSHM_Fortran_DetachSegment( *handle, *iverb );
}


//
// Attach to a shared memory segment
//

int inSHM_Fortran_AttachSegment(
      int shmid,
      int *handle,
      int iverb )
{
   struct inSHM_segment_s *s;
   int ier;

   ier = inSHM_Fortran_GetSegment( handle, iverb );
   if( ier != 0 ) {
      if( iverb != 0 )
         printf("Could not get an unused or a new handle!\n");
      return(1);
   }

   s = &( global_inshm_handles[ *handle ]);

   ier = inSHM_AttachSegment( s, shmid, iverb );
   if( ier != 0 ) {
      if( iverb != 0 )
         printf("Error: Could not attach to shared memory segment %d \n",
         shmid );
      return(2);
   }

   return(0);
}

void inshm_fortran_attachsegment_(
      int *shmid,
      int *handle,
      int *iverb,
      int *ier )
{
   *ier = inSHM_Fortran_AttachSegment( *shmid, handle, *iverb );
}


//
// Get the identifier of a shared memory segment
//

int inSHM_Fortran_SegmentID(
      int handle,
      int iverb )
{
   struct inSHM_segment_s *s;

   // sanity check
   if( global_inshm_handles == NULL ) {
      if( iverb != 0 )
         printf("Error: there should be no handles floating around! \n");
      return(-1);
   }

   if( handle >= global_inshm_handles_num ) {
      if( iverb != 0 )
         printf("Error: Invalid handle to attach to (%d) \n", handle );
      return(-1);
   }

   s = &( global_inshm_handles[ handle ] );

   return( s->shmid );
}

int inshm_fortran_segmentid_( int *handle, int *iverb )
{
   return( inSHM_Fortran_SegmentID( *handle, *iverb ) );
}

