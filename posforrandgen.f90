program posforrandgen
implicit none
real(8)  :: pos(3,5000)
character(2) :: elem(50)
integer :: natom,nspec
character(2) :: markelem
character(2) :: toelem
character(80) :: infile
integer :: nwpos(50)
real(8) :: avec(3,3)
integer :: n,nargc

markelem='C'
toelem='N'
infile='POSCAR'
n=iargc()
if(n>=1) then
  call getarg(1,markelem)
endif
if(n>=2) then
  call getarg(2,toelem)
endif
if(n>=3) then
  call getarg(3,infile)
endif

call read_pos(infile,natom,nspec,nwpos,elem,pos,avec)
call write_pos(markelem,toelem,natom,nspec,nwpos,elem,pos,avec)

stop
end program

subroutine read_pos(inpos,natom,nspec,nwpos,elem,pos,latt_dir)
implicit none
integer :: i
character(100) :: nomean
character(80) :: inpos
!character(2) :: markelem
integer :: nblock
character(10) :: iblock(100),title
logical :: alive,alive1      
integer :: nspec
integer :: nwpos(50)
real(8) :: pos(3,5000)
character(2) :: elem(50)
integer :: natom
real(8) :: latt_dir(3,3),ascale

inquire(file=inpos,exist=alive1)
  if(alive1) then
    open(33,file=inpos,status='old')
  else
    stop 'no POSCAR if found!'
endif

read(33,*) title
read(33,*) ascale
do i=1,3
  read(33,*) latt_dir(1:3,i)
enddo
do i=1,3
  latt_dir(1,i)=latt_dir(1,i)*ascale
  latt_dir(2,i)=latt_dir(2,i)*ascale
  latt_dir(3,i)=latt_dir(3,i)*ascale
enddo

read(33,"(A100)") nomean
call splitblock(nomean,nblock,iblock)
nspec=nblock
!allocate(nwpos(nspec),elem(nspec))
Backspace(33)
read(33,*) elem(1:nspec)
read(33,*) nwpos(1:nspec) 
natom=sum(nwpos(1:nspec))
!natom=0
!do i=1,nspec
!  natom=natom+nwpos(i)
!enddo
!write(*,*) 'natoms= ',natom
!allocate(pos(3,natom))
read(33,*) nomean
nomean=trim(adjustl(nomean))
! write(*,*) "From CONTCAR/POSCAR, I found :"
! write(*,*) "   ",nspec," type ions: ",elem(1:nspec)
! write(*,*) "have ",nwpos(1:nspec)," repectively"
if(nomean(1:1)=='s' .or. nomean(1:1)=='S') then
  read(33,*) nomean
  do i=1,natom
    read(33,*) pos(1:3,i),nomean,nomean,nomean
  enddo
else
  do i=1,natom
     read(33,*) pos(1:3,i)
  enddo  
endif
close(33)

return
end subroutine

subroutine splitblock(ablock1,nblock,iblock)
  implicit none
  character(100),intent(IN) :: ablock1
  integer,intent(OUT) :: nblock
  character(10),intent(OUT)  :: iblock(100)
  character(100)       :: ablock
  integer             :: i,toend,nblank

  nblock=1
  ablock=trim(adjustl(ablock1))
  toend=len_trim(adjustl(ablock1))
! write(*,*)
! write(*,"(A,I4)") "Length of whole words read in: ",toend
  if(toend==0) stop 'Blank string!'
  iblock=' '

  do i=1,toend
    if(i<toend) then
      if(ablock(i:i)==' ' .and. ablock(i+1:i+1)/= ' ') then
        nblock=nblock+1
      endif
    endif
    if(ablock(i:i)/=' ') then
      iblock(nblock)=trim(iblock(nblock))//ablock(i:i)
    endif
  enddo

!  write(*,*)
!  write(*,"(' Whole input were splited into',I4,' words, which are:')") nblock
!  write(*,"(100A10)") iblock(1:nblock)

  return
end subroutine

subroutine write_pos(markelem,toelem,natom,nspec_old,nwpos_old,elem,pos,avec)
implicit none
integer :: i,j,k
integer :: nspec,natom,nspec_old
real(8) :: avec(3,3)
real(8) :: pos(3,5000)
integer :: nwpos_old(50)
character(2) :: spsymb(50),elem(50)
character(2) :: markelem,toelem,markwhat
character(2),allocatable :: elem_tmp(:),elem_full(:)
!character(1),allocatable :: markornot(:,:)
real(8),allocatable :: wpos(:,:,:)
integer,allocatable :: nwpos(:)
character(80) :: sysname

!write(*,*) "old nspec: ",nspec_old
allocate(elem_tmp(natom),elem_full(natom))
k=0
do i=1,nspec_old
!  write(*,*) "atoms in each spec: ",nwpos_old(i)
  do j=1,nwpos_old(i)
    k=k+1
!    write(*,*) "k in tmp: ",k
    elem_full(k)=elem(i)
!    write(*,*) "elem in tmp: ",elem_full(k)
  enddo
enddo

elem_tmp=elem_full

! count ion types
do i=1,natom-1
  if(elem_tmp(i)/='no') then
    do j=i+1,natom
      if(elem_tmp(i) == elem_tmp(j)) then
         elem_tmp(j)='no'
      endif
    enddo
  endif
enddo

nspec=0
!spsymb='no'
do i=1,natom
  if(elem_tmp(i)/='no') then
    nspec=nspec+1
    spsymb(nspec)=elem_tmp(i)
  endif
enddo
!write(*,*) "new nspec: ",nspec
!write(*,*) "new symb: ",spsymb(1:nspec)

allocate(nwpos(nspec),wpos(3,natom,nspec))
!nwpos=0
do i=1,nspec
!   acount=0
  nwpos(i)=0
  do j=1,natom
    if(spsymb(i)==elem_full(j)) then
      nwpos(i)=nwpos(i)+1
!     acount=acount+1
!     wpos(:,acount,i)=pos(:,j)
      wpos(:,nwpos(i),i)=pos(:,j)
    endif
  enddo
enddo

do i=1,nspec
  if(i==1) then
    sysname=trim(adjustl(spsymb(i)))
  else
    sysname=trim(sysname)//adjustl(spsymb(i))
  endif
enddo

open(75,file='POSCAR.md',status='replace')
write(75,"(A)") trim(sysname)
write(75,"(A)") "1.000"
write(75,"(3F16.11)") avec(:,1)
write(75,"(3F16.11)") avec(:,2)
write(75,"(3F16.11)") avec(:,3)
if(nspec==1) then
  write(75,"(A4)") spsymb(i)
  write(75,"(I5)") nwpos(1)
! write(75,"(A9)") 'Selective'
  write(75,"(A6)") 'Direct'
else
  do i=1,nspec
    write(75,"(A4)",advance='no') spsymb(i)
  enddo
  write(75,"(/I5)",advance='no') nwpos(1)
  do i=2,nspec
    write(75,"(I5)",advance='no') nwpos(i)
  enddo
! write(75,"(/A9)") 'Selective'
  write(75,"(/A6)") 'Direct'
endif

!allocate(markornot(nspec))
do i=1,nspec
  if(spsymb(i) == markelem) then
     markwhat=toelem
  else
     markwhat='M'
  endif
  do j=1,nwpos(i) 
    write(75,"(3F16.11,3X,A)") wpos(1:3,j,i),markwhat
  enddo
enddo
close(75)

deallocate(wpos,nwpos,elem_tmp,elem_full)
return
end subroutine

