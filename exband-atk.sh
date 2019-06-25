#!/bin/bash

set -o errexit

#cd ${1}

if [ -e SUMBANDENE ];then
  rm -f SUMBANDENE
fi

if [ -e SUMBANDENE-sort ];then
  rm -f SUMBANDENE-sort
fi

for m in `ls POSCAR_permu*`
do
posroot=${m:7}
cd ${posroot}
ldaene=$(grep 'Total energy' ${posroot}.out|head -1 | awk '{print $5}')
#huckene=$(grep 'Total energy' ${posroot}.out|tail -1 | awk '{print $5}')
echo "${m:12}   $ldaene ">>../SUMBANDENE
cd ../
done

sort -gk 1 SUMBANDENE >>SUMBANDENE-sort
#cd ../
#sort -gk 2 SUMBANDENE >>SUMBANDENE-sort
