/******************************************************************************
 Copyright (c) 2018, Ioannis Nompelis
 All rights reserved.
 ******************************************************************************/

#ifndef _INSHM_H_
#define _INSHM_H_

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <stdlib.h>

#define SHMSIZE     27


struct inSHM_segment_s {
    int shmid;
    key_t key;
    size_t size;
    void *shm;
    struct shmid_ds ds;
};



int inSHM_CreateSegmentPrivate(
      struct inSHM_segment_s * inshm,
      size_t size,
      int iverb );

int inSHM_DetachSegment(
      struct inSHM_segment_s * inshm,
      int iverb );

int inSHM_AttachSegment(
      struct inSHM_segment_s * inshm,
      int shmid,
      int iverb );

#endif

