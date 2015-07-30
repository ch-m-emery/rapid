!*******************************************************************************
!Subroutine - rapid_QtoV
!*******************************************************************************
subroutine rapid_QtoV(ZV_k,ZV_x,ZV_QoutbarR,ZV_Qext,ZV_VbarR) 

!Purpose:
!Computes the volume of water in each river reach from the flows based on the 
!Muskingum method (McCarthy 1938). 
!Author: 
!Cedric H. David, 2015. 


!*******************************************************************************
!Declaration of variables
!*******************************************************************************
use rapid_var, only :                                                          &
                   ZM_Net,ierr


implicit none


!*******************************************************************************
!Includes
!*******************************************************************************
#include "finclude/petscsys.h"       
!base PETSc routines
#include "finclude/petscvec.h"  
#include "finclude/petscvec.h90"
!vectors, and vectors in Fortran90 
#include "finclude/petscmat.h"    
!matrices
#include "finclude/petscksp.h"    
!Krylov subspace methods
#include "finclude/petscpc.h"     
!preconditioners
#include "finclude/petscviewer.h"
!viewers (allows writing results in file for example)


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************
Vec, intent(in)    :: ZV_QoutbarR,ZV_Qext,                                     &
                      ZV_k,ZV_x 
Vec, intent(out)   :: ZV_VbarR

PetscInt :: IS_localsize,JS_localsize

PetscScalar, pointer :: ZV_QoutbarR_p(:),ZV_Qext_p(:),                         &
                        ZV_k_p(:),ZV_x_p(:),                                   &
                        ZV_VbarR_p(:)


!*******************************************************************************
!Get local sizes for vectors
!*******************************************************************************
call VecGetLocalSize(ZV_QoutbarR,IS_localsize,ierr)


!*******************************************************************************
!Calculation of Volume 
!*******************************************************************************
call MatMult(ZM_Net,ZV_QoutbarR,ZV_VbarR,ierr)                
!Vbar=Net*QoutbarR

call VecGetArrayF90(ZV_QoutbarR,ZV_QoutbarR_p,ierr)
call VecGetArrayF90(ZV_Qext,ZV_Qext_p,ierr)
call VecGetArrayF90(ZV_k,ZV_k_p,ierr)
call VecGetArrayF90(ZV_x,ZV_x_p,ierr)
call VecGetArrayF90(ZV_VbarR,ZV_VbarR_p,ierr)

do JS_localsize=1,IS_localsize
     ZV_VbarR_p(JS_localsize)=ZV_VbarR_p(JS_localsize)+ZV_Qext_p(JS_localsize) 
     !VbarR=VbarR+Qext
     ZV_VbarR_p(JS_localsize)=ZV_VbarR_p(JS_localsize)*ZV_x_p(JS_localsize)
     !VbarR=VbarR*x
     ZV_VbarR_p(JS_localsize)=ZV_VbarR_p(JS_localsize)                         &
                             +(1-ZV_x_p(JS_localsize))                         &
                             *ZV_QoutbarR_p(JS_localsize) 
     !VbarR=VbarR+(1-x)*QoutbarR
     ZV_VbarR_p(JS_localsize)=ZV_VbarR_p(JS_localsize)*ZV_k_p(JS_localsize)
     !VbarR=VbarR*x
end do

call VecRestoreArrayF90(ZV_QoutbarR,ZV_QoutbarR_p,ierr)
call VecRestoreArrayF90(ZV_Qext,ZV_Qext_p,ierr)
call VecRestoreArrayF90(ZV_k,ZV_k_p,ierr)
call VecRestoreArrayF90(ZV_x,ZV_x_p,ierr)
call VecRestoreArrayF90(ZV_VbarR,ZV_VbarR_p,ierr)


!*******************************************************************************
!End
!*******************************************************************************
end subroutine rapid_QtoV