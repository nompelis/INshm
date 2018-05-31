      Program maker

      USE inshm

      Implicit None
      Integer(KIND=4) ishm_handle, ishm_id, ier
      Integer(KIND=4),dimension(:),Pointer :: p
C     Real   (KIND=4),dimension(:),Pointer :: pr
      Integer i


c--- Get the segment identifier from the user
      PRINT*,'Type the segment indeitifier (an integer)'
      READ(*,*) ishm_id

c--- Print the segment identifier so that other processes can manually attach
      PRINT*,'Segment ID (shmid) to attach is',ishm_id

c--- Show the segments with IPCS
      PRINT*,'Consumer is querying the segment from the shell with "ipcs"'
      PRINT*,'(The segment should be there if the maker has not exited.)'
      call SYSTEM( 'ipcs -m' )

c--- Attach to the segment
      call inSHM_AttachSegment_f( ishm_id, ishm_handle, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'

c--- Attach the segment to a pointer so that we can access data
      call inshm_AssignPointer_f( ishm_handle, p, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'
      !--- data should have been set by the maker
      do i = 1,5   ! only the first few
         PRINT*,'p(i)=', p(i)
      enddo

C     call inshm_AssignPointer_f( ishm_handle, pr, 1, ier )
C     PRINT*,'ier=',ier,'(should be zero)'
C     !--- data should have been set by the maker
C     do i = 1,5   ! only the first few
C        PRINT*,'pr(i)=', pr(i)
C     enddo

c--- Wait some time to allow for the make of the segment to terminate
      PRINT*,'This is the part where the consumer does work for a while...'
      call SYSTEM( 'sleep 10' )

c--- Detach from the segment
      call inSHM_DetachSegment_f( ishm_handle, 1, ier )
      PRINT*,'ier=',ier,'(should be zero)'

c--- Show the segments with IPCS
      PRINT*,'Consumer is querying the segment from the shell with "ipcs"'
      PRINT*,'(The segment should not be there if nobody else is attached.)'
      call SYSTEM( 'ipcs -m' )

      End

