#!/bin/bash

set -o errexit

for i in ${1}
do
cd ${i}-vpopt

for m in `ls -d p*`
do
posroot=${m}
cd ${posroot}

  isconv='F'
  jobconv='N'
 while [ ${isconv} == 'F' ];do
   if [ -s POSCAR.optF ];then
     isconv='T'
     echo "${posroot} OPT Converged!"
   else
     sleep 60
   fi
 done

cd ../
done

cd ../
done
