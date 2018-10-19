cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c ***  Copyright (c) 2018, Ioannis Nompelis
c ***  All rights reserved.
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      MODULE inshm

      Use, intrinsic :: iso_c_binding, only : c_int, c_long, c_double, c_ptr,
     &                  c_f_pointer

      Implicit none
      !----- this is the variable that will hold the C pointer value when
      !----- internal procedures will be using it
      TYPE(C_PTR) :: mem_ptr

      !----- forcing very specific arguments to all external procedures
      !-***- For now there is implied type-casting at the caller!
      !-***- This treatment may not work as type-casting may not happen!

      !----- this routine implies type-casting at invocation
      INTERFACE inshm_CreateSegment_f
         SUBROUTINE inshm_Fortran_CreateSegment( size, handle, id, iverb, ier )
     & bind(C,name='inshm_fortran_createsegment_')
            Use, intrinsic :: iso_c_binding, only : c_long,c_int
            INTEGER(KIND=c_long), INTENT(IN) :: size
            INTEGER(KIND=c_int), INTENT(OUT) :: handle
            INTEGER(KIND=c_int), INTENT(OUT) :: id
            INTEGER(KIND=c_int), INTENT(IN) :: iverb
            INTEGER(KIND=c_int), INTENT(OUT) :: ier
         END SUBROUTINE inshm_Fortran_CreateSegment
      END INTERFACE inshm_CreateSegment_f

      !----- this routine implies type-casting at invocation
      INTERFACE inshm_AttachSegment_f
         SUBROUTINE inshm_Fortran_AttachSegment( shmid, handle, iverb, ier )
     & bind(C,name='inshm_fortran_attachsegment_')
            Use, intrinsic :: iso_c_binding, only : c_int
            INTEGER(KIND=c_int), INTENT(IN) :: shmid
            INTEGER(KIND=c_int), INTENT(OUT) :: handle
            INTEGER(KIND=c_int), INTENT(IN) :: iverb
            INTEGER(KIND=c_int), INTENT(OUT) :: ier
         END SUBROUTINE inshm_Fortran_AttachSegment
      END INTERFACE inshm_AttachSegment_f

      !----- this routine implies type-casting at invocation
      INTERFACE inshm_DetachSegment_f
         SUBROUTINE inshm_Fortran_DetachSegment( handle, iverb, ier )
     & bind(C,name='inshm_fortran_detachsegment_')
            Use, intrinsic :: iso_c_binding, only : c_int
            INTEGER(KIND=c_int), INTENT(IN) :: handle
            INTEGER(KIND=c_int), INTENT(IN) :: iverb
            INTEGER(KIND=c_int), INTENT(OUT) :: ier
         END SUBROUTINE inshm_Fortran_DetachSegment
      END INTERFACE inshm_DetachSegment_f

      !----- this routine implies type-casting at invocation
      INTERFACE inshm_SegmentID_f
         INTEGER(KIND=c_int) FUNCTION inshm_Fortran_SegmentID( handle, iverb )
     &                   bind(C,name='inshm_fortran_segmentid_')
            Use, intrinsic :: iso_c_binding, only : c_int
            INTEGER(KIND=c_int), INTENT(IN) :: handle
            INTEGER(KIND=c_int), INTENT(IN) :: iverb
         END FUNCTION inshm_Fortran_SegmentID
      END INTERFACE inshm_SegmentID_f

      !----- this is the interface to the C function
      !----- this fucntion gets its arguments type-casted by the wrappers below
      INTERFACE inshm_SegmentPointer
         TYPE(C_PTR) FUNCTION inshm_Fortran_SegmentPointer( handle, iverb )
     &           bind(C,name='inshm_fortran_segmentpointer_')
            Use, intrinsic :: iso_c_binding, only : c_ptr,c_int
            INTEGER(KIND=c_int), INTENT(IN) :: handle
            INTEGER(KIND=c_int), INTENT(IN) :: iverb
         END FUNCTION inshm_Fortran_SegmentPointer
      END INTERFACE inshm_SegmentPointer

      !----- forcing very specific arguments to internal module procedures
      !----- the procedures also "wrap" argument type-casting
      INTERFACE inshm_AssignPointer_f
         MODULE PROCEDURE inshm_SegmentPtr_X_INT4
         MODULE PROCEDURE inshm_SegmentPtr_XX_INT4
         MODULE PROCEDURE inshm_SegmentPtr_XXX_INT4
         MODULE PROCEDURE inshm_SegmentPtr_XXXX_INT4
         MODULE PROCEDURE inshm_SegmentPtr_XXXXX_INT4
         MODULE PROCEDURE inshm_SegmentPtr_XXXXXX_INT4
         MODULE PROCEDURE inshm_SegmentPtr_XXXXXXX_INT4
         MODULE PROCEDURE inshm_SegmentPtr_X_INT8
         MODULE PROCEDURE inshm_SegmentPtr_XX_INT8
         MODULE PROCEDURE inshm_SegmentPtr_XXX_INT8
         MODULE PROCEDURE inshm_SegmentPtr_XXXX_INT8
         MODULE PROCEDURE inshm_SegmentPtr_XXXXX_INT8
         MODULE PROCEDURE inshm_SegmentPtr_XXXXXX_INT8
         MODULE PROCEDURE inshm_SegmentPtr_XXXXXXX_INT8
         MODULE PROCEDURE inshm_SegmentPtr_X_REAL4
         MODULE PROCEDURE inshm_SegmentPtr_XX_REAL4
         MODULE PROCEDURE inshm_SegmentPtr_XXX_REAL4
         MODULE PROCEDURE inshm_SegmentPtr_XXXX_REAL4
         MODULE PROCEDURE inshm_SegmentPtr_XXXXX_REAL4
         MODULE PROCEDURE inshm_SegmentPtr_XXXXXX_REAL4
         MODULE PROCEDURE inshm_SegmentPtr_XXXXXXX_REAL4
         MODULE PROCEDURE inshm_SegmentPtr_X_REAL8
         MODULE PROCEDURE inshm_SegmentPtr_XX_REAL8
         MODULE PROCEDURE inshm_SegmentPtr_XXX_REAL8
         MODULE PROCEDURE inshm_SegmentPtr_XXXX_REAL8
         MODULE PROCEDURE inshm_SegmentPtr_XXXXX_REAL8
         MODULE PROCEDURE inshm_SegmentPtr_XXXXXX_REAL8
         MODULE PROCEDURE inshm_SegmentPtr_XXXXXXX_REAL8
      END INTERFACE inshm_AssignPointer_f


      CONTAINS



c--- a set of routines that assign a pointer to a 4-byte integer for rank 0-7
      SUBROUTINE inshm_SegmentPtr_X_INT4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=4), DIMENSION(:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(1), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_X_INT4


      SUBROUTINE inshm_SegmentPtr_XX_INT4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=4), DIMENSION(:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(2), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XX_INT4


      SUBROUTINE inshm_SegmentPtr_XXX_INT4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=4), DIMENSION(:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(3), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXX_INT4


      SUBROUTINE inshm_SegmentPtr_XXXX_INT4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=4), DIMENSION(:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(4), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXX_INT4


      SUBROUTINE inshm_SegmentPtr_XXXXX_INT4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=4), DIMENSION(:,:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(5), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXXX_INT4


      SUBROUTINE inshm_SegmentPtr_XXXXXX_INT4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=4), DIMENSION(:,:,:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(6), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXXXX_INT4


      SUBROUTINE inshm_SegmentPtr_XXXXXXX_INT4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=4), DIMENSION(:,:,:,:,:,:,:), POINTER, INTENT(OUT) ::data_ptr
      INTEGER(KIND=4), dimension(7), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1
      
      END SUBROUTINE inshm_SegmentPtr_XXXXXXX_INT4

c--- a set of routines that assign a pointer to a 8-byte integer for rank 0-7
      SUBROUTINE inshm_SegmentPtr_X_INT8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=8), DIMENSION(:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(1), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_X_INT8


      SUBROUTINE inshm_SegmentPtr_XX_INT8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=8), DIMENSION(:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(2), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XX_INT8


      SUBROUTINE inshm_SegmentPtr_XXX_INT8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=8), DIMENSION(:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(3), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXX_INT8


      SUBROUTINE inshm_SegmentPtr_XXXX_INT8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=8), DIMENSION(:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(4), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXX_INT8


      SUBROUTINE inshm_SegmentPtr_XXXXX_INT8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=8), DIMENSION(:,:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(5), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXXX_INT8


      SUBROUTINE inshm_SegmentPtr_XXXXXX_INT8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=8), DIMENSION(:,:,:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(6), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXXXX_INT8


      SUBROUTINE inshm_SegmentPtr_XXXXXXX_INT8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      INTEGER(KIND=8), DIMENSION(:,:,:,:,:,:,:), POINTER, INTENT(OUT) ::data_ptr
      INTEGER(KIND=4), dimension(7), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1
      
      END SUBROUTINE inshm_SegmentPtr_XXXXXXX_INT8


c--- a set of routines that assign a pointer to a 4-byte real for rank 0-7
      SUBROUTINE inshm_SegmentPtr_X_REAL4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=4), DIMENSION(:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(1), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_X_REAL4


      SUBROUTINE inshm_SegmentPtr_XX_REAL4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=4), DIMENSION(:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(2), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XX_REAL4


      SUBROUTINE inshm_SegmentPtr_XXX_REAL4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=4), DIMENSION(:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(3), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXX_REAL4


      SUBROUTINE inshm_SegmentPtr_XXXX_REAL4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=4), DIMENSION(:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(4), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXX_REAL4


      SUBROUTINE inshm_SegmentPtr_XXXXX_REAL4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=4), DIMENSION(:,:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(5), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXXX_REAL4


      SUBROUTINE inshm_SegmentPtr_XXXXXX_REAL4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=4), DIMENSION(:,:,:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(6), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXXXX_REAL4


      SUBROUTINE inshm_SegmentPtr_XXXXXXX_REAL4( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=4), DIMENSION(:,:,:,:,:,:,:), POINTER, INTENT(OUT) ::data_ptr
      INTEGER(KIND=4), dimension(7), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1
      
      END SUBROUTINE inshm_SegmentPtr_XXXXXXX_REAL4


c--- a set of routines that assign a pointer to a 8-byte real for rank 0-7
      SUBROUTINE inshm_SegmentPtr_X_REAL8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=8), DIMENSION(:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(1), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_X_REAL8


      SUBROUTINE inshm_SegmentPtr_XX_REAL8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=8), DIMENSION(:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(2), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XX_REAL8


      SUBROUTINE inshm_SegmentPtr_XXX_REAL8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=8), DIMENSION(:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(3), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXX_REAL8


      SUBROUTINE inshm_SegmentPtr_XXXX_REAL8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=8), DIMENSION(:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(4), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXX_REAL8


      SUBROUTINE inshm_SegmentPtr_XXXXX_REAL8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=8), DIMENSION(:,:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(5), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXXX_REAL8


      SUBROUTINE inshm_SegmentPtr_XXXXXX_REAL8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=8), DIMENSION(:,:,:,:,:,:), POINTER, INTENT(OUT) :: data_ptr
      INTEGER(KIND=4), dimension(6), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1

      END SUBROUTINE inshm_SegmentPtr_XXXXXX_REAL8


      SUBROUTINE inshm_SegmentPtr_XXXXXXX_REAL8( handle, data_ptr, irank, iverb, ier )
      Implicit None
      INTEGER(KIND=4), INTENT(IN) :: handle
      REAL   (KIND=8), DIMENSION(:,:,:,:,:,:,:), POINTER, INTENT(OUT) ::data_ptr
      INTEGER(KIND=4), dimension(7), INTENT(IN) :: irank
      INTEGER(KIND=4), INTENT(IN) :: iverb
      INTEGER(KIND=4), INTENT(OUT) :: ier
      INTEGER(KIND=c_int) :: iv,ih

      ih = handle
      iv = iverb
      mem_ptr = inshm_SegmentPointer( ih, iv )
      ier = 0
      call c_f_pointer(mem_ptr, data_ptr, irank)
      if( .NOT.associated( data_ptr ) ) ier = 1
      
      END SUBROUTINE inshm_SegmentPtr_XXXXXXX_REAL8



      END MODULE inshm

