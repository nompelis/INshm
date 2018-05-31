      MODULE inshm

      Use, intrinsic :: iso_c_binding, only : c_int, c_long, c_double, c_ptr,
     &                  c_f_pointer

      Implicit none
      !----- this is the variable that will hold the C pointer value when
      !----- internal procedures will be using it
      TYPE(C_PTR) :: mem_ptr

      !----- forcing very specific arguments to these external procedures
      INTERFACE inshm_CreateSegment_f
         SUBROUTINE inshm_Fortran_CreateSegment( size, handle, id, iverb, ier )
            INTEGER(KIND=8), INTENT(IN) :: size
            INTEGER(KIND=4), INTENT(OUT) :: handle
            INTEGER(KIND=4), INTENT(OUT) :: id
            INTEGER(KIND=4), INTENT(IN) :: iverb
            INTEGER(KIND=4), INTENT(OUT) :: ier
         END SUBROUTINE inshm_Fortran_CreateSegment
      END INTERFACE inshm_CreateSegment_f

      INTERFACE inshm_AttachSegment_f
         SUBROUTINE inshm_Fortran_AttachSegment( shmid, handle, iverb, ier )
            INTEGER(KIND=4), INTENT(IN) :: shmid
            INTEGER(KIND=4), INTENT(OUT) :: handle
            INTEGER(KIND=4), INTENT(IN) :: iverb
            INTEGER(KIND=4), INTENT(OUT) :: ier
         END SUBROUTINE inshm_Fortran_AttachSegment
      END INTERFACE inshm_AttachSegment_f

      INTERFACE inshm_DetachSegment_f
         SUBROUTINE inshm_Fortran_DetachSegment( handle, iverb, ier )
            INTEGER(KIND=4), INTENT(IN) :: handle
            INTEGER(KIND=4), INTENT(IN) :: iverb
            INTEGER(KIND=4), INTENT(OUT) :: ier
         END SUBROUTINE inshm_Fortran_DetachSegment
      END INTERFACE inshm_DetachSegment_f

      !----- forcing very specific arguments to these external functions
      INTERFACE inshm_SegmentID_f
         INTEGER(KIND=4) FUNCTION inshm_Fortran_SegmentID( handle, iverb )
            INTEGER(KIND=4), INTENT(IN) :: handle
            INTEGER(KIND=4), INTENT(IN) :: iverb
         END FUNCTION inshm_Fortran_SegmentID
      END INTERFACE inshm_SegmentID_f

      INTERFACE inshm_SegmentPointer
         TYPE(C_PTR) FUNCTION inshm_Fortran_SegmentPointer( handle, iverb )
            Use, intrinsic :: iso_c_binding, only : c_ptr
            INTEGER(KIND=4), INTENT(IN) :: handle
            INTEGER(KIND=4), INTENT(IN) :: iverb
         END FUNCTION inshm_Fortran_SegmentPointer
      END INTERFACE inshm_SegmentPointer

      !----- forcing very specific arguments to internal module procedures
      INTERFACE inshm_AssignPointer_f
         MODULE PROCEDURE inshm_SegmentPtr_INT4
         MODULE PROCEDURE inshm_SegmentPtr_INT8
      END INTERFACE inshm_AssignPointer_f


      CONTAINS

c--- a set of routines that assign a pointer to a 4-byte integer for rank 0-7
      SUBROUTINE inshm_SegmentPtr_INT4( handle, data_ptr, iverb, ier )
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=4), DIMENSION(:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier

      mem_ptr = inshm_SegmentPointer( handle, iverb )

      ier = 0

      call c_f_pointer(mem_ptr, data_ptr, [100])

      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_INT4


c--- a set of routines that assign a pointer to a 8-byte integer for rank 0-7
      SUBROUTINE inshm_SegmentPtr_INT8( handle, data_ptr, iverb, ier )
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=8), DIMENSION(:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier

      mem_ptr = inshm_SegmentPointer( handle, iverb )

      ier = 0

      call c_f_pointer(mem_ptr, data_ptr, [100])

      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_INT8



      END MODULE inshm

