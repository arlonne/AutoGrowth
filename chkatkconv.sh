#!/bin/bash

set -o errexit

for i in ${1}
do
cd ${i}

for m in `ls -d permu*`
do
posroot=${m}
cd ${posroot}

  isconv='F'
  jobconv='N'
  nconv=100
while [ ${isconv} == 'F' ];do
   if [ -s ${posroot}.out ];then
     jobconv=$(grep 'Calculation Converged' ${posroot}.out | awk '{print $3}')
     nconv=$(grep 'Calculation Converged' ${posroot}.out | awk '{print $5}')
#    if [ $? -eq 0 ];then
     nconv=${nconv:=1000}
     jobconv=${jobconv:=1000}
       if [ ${nconv} -lt 100 ] && [ ${jobconv} == 'Converged' ];then
         isconv='T'
         echo "${posroot} Converged!"
       else
         sleep 60
       fi
#    fi
   else
     sleep 60
   fi
done

cd ../
done

cd ../
done
