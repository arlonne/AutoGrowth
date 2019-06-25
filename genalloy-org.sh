#!/bin/bash
set -o errexit

j=${1}         #start from j defects       
natom=${2}     #How many atoms will be replaced or instrincted or vacancy!

k=$(($natom-${j}+1))
i=$((j-1))
if [ -s POSCAR.${i} ];then
mkdir N${j}
cat>inpara.in<<!
${k}
1
POSCAR.${i}
!
else
  echo "           --------------- ERROR -------------            "
  echo ">>>>>>>>>>>>>>>>> No inital POSCAR.${i} <<<<<<<<<<<<<<<<<<"
  echo
  exit 1
fi
if [ -s /opt/QMD/genrandefect.ne ];then
genrandefect.ne
mv POSCAR_permu*  N${j}
mv Finalpermu.out N${j}
else
  echo "           --------------- ERROR -------------            "
  echo ">>>>>>>>>>>>>>>>> No prgram /opt/QMD/genrandefect.ne <<<<<<<<<<<<<<<<<<"
  echo
  exit 1
fi

if [ -s atk138enejob.sh ] && [ -s atk138cal.sh ];then
#cp atk138enejob.sh N${j}
cd N${j}
../atk138enejob.sh N${j}
cd ../
else
  echo "           --------------- ERROR -------------            "
  echo ">>>>>>>>>>>>>>>>> No prgram atk138enejob.sh | atk138cal.sh <<<<<<<<<<<<<<<<<<"
  echo
  exit 1
fi

#./subatkjob.sh N${j}
