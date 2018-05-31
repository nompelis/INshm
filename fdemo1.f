      Program maker

      USE inshm

      Implicit None
      Integer(KIND=4) ishm_handle, ishm_id, ier
      Integer(KIND=8) lshm_size
      Integer(KIND=4), dimension(:), Pointer :: p
C     Real   (KIND=4), dimension(:), Pointer :: pr
C     Real   (KIND=8), dimension(:), Pointer :: pre
      Integer i


c--- Establish that we want a segment of 100 integers (4-bytes)
      lshm_size = 100 * 4

c--- make a call to the library API to get a handle for the segment
      call inSHM_CreateSegment_f( lshm_size, ishm_handle, ishm_id, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'
c--- Print the segment identifier so that other processes can manually attach
      PRINT*,'Segment ID (shmid) is',ishm_id

c--- Get the segment identifier (for testing)
      ishm_id = inSHM_SegmentID_f( ishm_handle, 1 )
      PRINT*,'Segment ID (shmid) is',ishm_id,'(second time)'

c--- Show the segments with IPCS
      PRINT*,'Maker is querying the segment from the shell with "ipcs"'
      PRINT*,'(The segment should be there, since we are attached to it.)'
      call SYSTEM( 'ipcs -m' )

c--- Attach the segment to a pointer so that we can access data
      call inshm_AssignPointer_f( ishm_handle, p, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'
      do i = 1,100
         p(i) = -(1000 + i)
      enddo
      do i = 1,5   ! only the first few
         PRINT*,'p(i)=', p(i)
      enddo

CCCCCC DO NOT TRY THESE AT HOME...
c--- Just for fun, assign the same pointer to an array of 4-byte reals
c     call inshm_AssignPointer_f( ishm_handle, pr, 1, ier )
c     PRINT*,'ier=',ier,'(should be zero)'
c     do i = 1,5   ! only the first few
c        pr(i) = -9999.9 + float(i-1)
c        PRINT*,'pr(i)=', pr(i)
c     enddo

c--- Just for fun, look at the result from an array of 8-byte reals (overlaped)
c     call inshm_AssignPointer_f( ishm_handle, pre, 1, ier )
c     PRINT*,'ier=',ier,'(should be zero)'
c     do i = 1,5   ! only the first few
c        PRINT*,'pre(i)=', pre(i)
c     enddo

c--- Wait some time to allow other processes to attach to your segment
      PRINT*,'This is the part where the maker does work for a while...'
      call SYSTEM( 'sleep 10' )

c--- Detach from the segment
      call inSHM_DetachSegment_f( ishm_handle, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'

c--- Show the segments with IPCS
      PRINT*,'Maker is querying the segment from the shell with "ipcs"'
      PRINT*,'(The segment should be there only if otherss are attached.)'
      call SYSTEM( 'ipcs -m' )

      End

