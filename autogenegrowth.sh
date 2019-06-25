#!/bin/bash
set -o errexit
# Input Parameters:
## start from "1" defects
## "2" atoms will be replaced or instrincted or vacancy!
## "3" which postions should be repl/inst/vac!
## "4" should be replace by what kind of elemtary!

if [ x${4} != x ];then

j=${1}
nat=${2}
nround=$((nat-1))
j=$((j-1))
while [ ${j} -lt ${nround} ];do
j=$((j+1))

#A: LDA energy for inital selection
if [ -s atk138enejob.sh ];then
./genalloy-org.sh ${j} ${2}
if [ $? == 1 ];then
  exit 1
fi                
else
  echo "           --------------- ERROR -------------            "
  echo ">>>>>>>>>>>>>>>>> No prgram genalloy-org.sh <<<<<<<<<<<<<<<<<<"
  echo
  exit 1
fi
#END inital selection

#B check A finish or not
if [ -s chkatkconv.sh ];then
./chkatkconv.sh N${j}
if [ $? == 1 ];then
  exit 1
fi
else
  echo "           --------------- ERROR -------------            "
  echo ">>>>>>>>>>>>>>>>> No prgram chkatkconv.sh <<<<<<<<<<<<<<<<<<"
  echo
  exit 1
fi
#END B

#C optimization section
if [ -s vpoptjob.sh ];then
./vpoptjob.sh N${j}
if [ $? == 1 ];then
  exit 1
fi
else
  echo "           --------------- ERROR -------------            "
  echo ">>>>>>>>>>>>>>>>> No prgram vpoptjob.sh <<<<<<<<<<<<<<<<<<"
  echo
  exit 1
fi
#End C optimization section

#D chk C finished or not
if [ -s chkoptconv.sh ];then
./chkoptconv.sh N${j}
if [ $? == 1 ];then
  exit 1
fi
else
  echo "           --------------- ERROR -------------            "
  echo ">>>>>>>>>>>>>>>>> No prgram chkoptconv.sh <<<<<<<<<<<<<<<<<<"
  echo
  exit 1
fi
#END D

#E find the most stable one for the next procedure
if [ -s exband-vp.sh ] && [ -s /opt/QMD/posforrandgen.ne ];then
./exband-vp.sh N${j}
if [ $? == 1 ];then
  exit 1
fi
mv SUMBANDENEVP-N${j} SUMBANDENEVP-N${j}-opt
enemax_pnum=$(sort -nk 2 SUMBANDENEVP-N${j}-opt | head -1 | cut -d'-' -f2)
cp N${j}/POSCAR_permu${enemax_pnum} POSCAR.tmp
#Modify POSCAR
posforrandgen.ne ${3} ${4} POSCAR.tmp
if [ $? == 1 ];then
  exit 1
fi
cp POSCAR.md POSCAR.${j}
#####
else
  echo "           --------------- ERROR -------------            "
  echo ">>>>>>>>>>>>>>>>> No prgram exband-vp.sh <<<<<<<<<<<<<<<<<<"
  echo ">>>>>>>>>>>>>>>>> No prgram /opt/QMD/posforrandgen.ne <<<<<<<<<<<<<<<<<<"
  echo
  exit 1
fi
#END E 

echo ">>>>>>>>>>>>>>>>>>>>> Cong! N${j} Was Successfully Compeleted!<<<<<<<<<<<<<<<<<<"
echo ">>>>>>>>>>>>>>>>>>>>>  N$((j+1)) Will be Started! <<<<<<<<<<<<<<<<<<"

done

fi
