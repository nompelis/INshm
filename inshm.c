#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>

#include "inshm.h"


//
// Function to create a private shared-memory segment and immediately
// allow for it to be removed _after_ the process has attached to it.
//

int inSHM_CreateSegmentPrivate(
      struct inSHM_segment_s * inshm,
      size_t size,
      int iverb )
{
   int shmid;
   void *shm;
   struct shmid_ds *ds;


   // sanity check
   if( inshm == NULL ) {
      if( iverb != 0 ) {
         printf(" [inSHM] Incoming structure pointer cannot be bull!\n");
      }
      return(1);
   }
   ds = &( inshm->ds );

   // first create the segment
   shmid = shmget( IPC_PRIVATE, size, IPC_CREAT | 0666 );
   if( shmid < 0 ) {
      if( iverb != 0 ) {
         printf(" [inSHM] Could not create IPC_PRIVATE segment of size %ld \n",
                (long) size );
      }
      return(2);
   } else {
      if( iverb != 0 ) {
         printf(" [inSHM] Created IPC_PRIVATE segment of size %ld (shmid=%d)\n",
                (long) size, shmid );
      }
      inshm->shmid = shmid;
      inshm->size = size;
      inshm->key = 0;
   }

   // second, attach the current process to the segment
   shm = shmat( shmid, NULL, 0 );
   if( shm == (void *) -1 ) {
      if( iverb != 0 ) {
         printf(" [inSHM] Could not attach to new segment (shmid=%d)\n", shmid );
      }

      // delete the segment
      shmctl( shmid, IPC_RMID, ds );

      // clean-up the returned structure
      inshm->shmid = -1;
      inshm->size = 0;
      inshm->shm = NULL;

      return(3);
   } else {
      if( iverb != 0 ) {
         printf(" [inSHM] Assigned pointer to segment: shm=%p \n", shm);
      }
      inshm->shm = shm;
   }

   // third, flag the segment as "ready-to-clean"
   if( shmctl( shmid, IPC_RMID, ds ) == -1 ) {
      if( iverb != 0 ) {
         printf(" [inSHM] Could not cleanly shmctl(IPC_RWID) on the segment! \n");
      }
      return(4);
   } else {
      if( iverb != 0 ) {
         printf(" [inSHM] Marked segment (shmid=%d) for cleaning \n", shmid);
      }
   }

   // finally, fill the structure with segment data
   if( shmctl( shmid, IPC_STAT, ds ) == -1 ) {
      if( iverb != 0 ) {
         printf(" [inSHM] Could not cleanly shmctl(IPC_STAT) on the segment! \n");
      }
      return(5);
   } else {
      if( iverb != 0 ) {
      printf(" [inSHM] Status of segment with shmid=%d\n", inshm->shmid);
      printf("   struct ipc_perm shm_perm; (NOT SHOWN) \n");
      printf("   size_t   shm_segsz; %ld \n", (long) inshm->ds.shm_segsz );
      printf("   time_t   shm_atime; %ld \n", (long) inshm->ds.shm_atime );
      printf("   time_t   shm_dtime; %ld \n", (long) inshm->ds.shm_dtime );
      printf("   time_t   shm_ctime; %ld \n", (long) inshm->ds.shm_ctime );
      printf("   pid_t    shm_cpid;  %ld (PID of creator) \n", (long) inshm->ds.shm_cpid );
      printf("   pid_t    shm_lpid;  %ld (PID of last shmat) \n", (long) inshm->ds.shm_lpid );
      printf("   shmatt_t shm_nattch; %d \n", (int) inshm->ds.shm_nattch );
      }
   }

   return(0);
}


//
// Function to detach from a segment
//

int inSHM_DetachSegment(
      struct inSHM_segment_s * inshm,
      int iverb )
{
// struct shmid_ds *ds;


   // sanity check
   if( inshm == NULL ) {
      if( iverb != 0 ) {
         printf(" [inSHM] Incoming structure pointer cannot be bull!\n");
      }
      return(1);
   }
// ds = &( inshm->ds );

   if( iverb != 0 ) {
      printf(" [inSHM] Attempting to detach from segment (shmid=%d, shm=%p) \n",
      inshm->shmid, inshm->shm );
   }
   if( shmdt( inshm->shm ) != 0 ) {
      if( iverb != 0 ) {
         printf(" [inSHM] Could not cleanly detach the segment! \n");
      }

      return(1);
   } else {
      if( iverb != 0 ) {
         printf(" [inSHM] Detached from segment \n");
      }
      inshm->shmid = -1;
      inshm->size = 0;
      inshm->shm = NULL;
   }

   return(0);
}


int inSHM_AttachSegment(
      struct inSHM_segment_s * inshm,
      int shmid,
      int iverb )
{
   struct shmid_ds *ds;


   // sanity check
   if( inshm == NULL ) {
      if( iverb != 0 ) {
         printf(" [inSHM] Incoming structure pointer cannot be bull!\n");
      }
      return(1);
   }

   // check for a valid memory segment
   if( shmid < 0 ) {
      if( iverb != 0 ) {
         printf(" [inSHM] Incoming segment identifier is problematic: shmid=%d \n",
                shmid );
      }
      return(2);
   }

   inshm->shm = shmat( shmid, NULL, 0 );
   if( inshm->shm == (void *) -1 ) {
      if( iverb != 0 ) {
         printf(" [inSHM] Could not attach to segment shmid=%d \n", shmid );
      }
      return(3);
   }
   inshm->shmid = shmid;
   ds = &( inshm->ds );

   // finally, fill the structure with segment data
   if( shmctl( inshm->shmid, IPC_STAT, ds ) == -1 ) {
      if( iverb != 0 ) {
         printf(" [inSHM] Could not cleanly shmctl(IPC_STAT) on the segment! \n");
      }
      return(4);
   } else {
      if( iverb != 0 ) {
      printf(" [inSHM] Status of segment with shmid=%d\n", inshm->shmid);
      printf("   struct ipc_perm shm_perm; (NOT SHOWN) \n");
      printf("   size_t   shm_segsz; %ld \n", (long) inshm->ds.shm_segsz );
      printf("   time_t   shm_atime; %ld \n", (long) inshm->ds.shm_atime );
      printf("   time_t   shm_dtime; %ld \n", (long) inshm->ds.shm_dtime );
      printf("   time_t   shm_ctime; %ld \n", (long) inshm->ds.shm_ctime );
      printf("   pid_t    shm_cpid;  %ld (PID of creator) \n", (long) inshm->ds.shm_cpid );
      printf("   pid_t    shm_lpid;  %ld (PID of last shmat) \n", (long) inshm->ds.shm_lpid );
      printf("   shmatt_t shm_nattch; %d \n", (int) inshm->ds.shm_nattch );
      }
   }

   inshm->size = ds->shm_segsz;

   return(0);
}

