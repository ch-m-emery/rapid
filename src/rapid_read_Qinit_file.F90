!*******************************************************************************
!Subroutine - rapid_read_Qinit_file
!*******************************************************************************
subroutine rapid_read_Qinit_file

!Purpose:
!Read Qinit_file from Fortran.
!Author: 
!Cedric H. David, 2017-2019.


!*******************************************************************************
!Global variables
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   rank,ierr,                                                  &
                   IS_nc_status,IS_nc_id_fil_Qinit,IS_nc_id_var_Qinit,         &
                   IS_riv_bas,IV_riv_loc1,IV_riv_index,ZV_read_riv_tot,        &
                   IS_riv_tot,ZV_QoutinitM

implicit none


!*******************************************************************************
!Includes
!*******************************************************************************
#include "petsc/finclude/petscsys.h"       
!base PETSc routines
#include "petsc/finclude/petscvec.h"  
#include "petsc/finclude/petscvec.h90"
!vectors, and vectors in Fortran90 
#include "petsc/finclude/petscmat.h"    
!matrices
#include "petsc/finclude/petscksp.h"    
!Krylov subspace methods
#include "petsc/finclude/petscpc.h"     
!preconditioners
#include "petsc/finclude/petscviewer.h"
!viewers (allows writing results in file for example)
#include "petsc/finclude/petsclog.h" 
!PETSc log


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************


!*******************************************************************************
!Read file
!*******************************************************************************
if (rank==0) then
     IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Qinit,IS_nc_id_var_Qinit,          &
                               ZV_read_riv_tot,(/1,1/),(/IS_riv_tot,1/))
end if


!*******************************************************************************
!Set values in PETSc vector
!*******************************************************************************
if (rank==0) then
     call VecSetValues(ZV_QoutinitM,IS_riv_bas,IV_riv_loc1,                    &
                       ZV_read_riv_tot(IV_riv_index),INSERT_VALUES,ierr)
end if


!*******************************************************************************
!Assemble PETSc vector
!*******************************************************************************
call VecAssemblyBegin(ZV_QoutinitM,ierr)
call VecAssemblyEnd(ZV_QoutinitM,ierr)


!*******************************************************************************
!End subroutine 
!*******************************************************************************
end subroutine rapid_read_Qinit_file
