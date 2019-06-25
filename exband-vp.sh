#!/bin/bash

set -o errexit

if [ -e SUMBANDENEVP ];then
  rm -f SUMBANDENEVP
fi

if [ -e SUMBANDENEVP-sort ];then
  rm -f SUMBANDENEVP-sort
fi

if [ x${1} != x ];then

uninum=$(cat ${1}/rmdupl.dat-sort|cut -d' ' -f1)
cd ${1}-vpopt

for m in ${uninum[@]}
do
posroot=$m 
cd p${posroot}

if [ -s POSCAR.optF ];then
ene=$(tail -1 OSZICAR | awk '{print $5}')
#enescf=$(tail -2 OSZICAR | head -1 | awk '{print $3}')
#la=$(head -3 POSCAR | tail -1|awk '{printf("%6.3f",$1)}')
#dip=$(grep 'dipolmoment' OUTCAR | awk '{print $4}')
vbm=$(vpholu.ne|head -3|tail -1|awk '{print $8}')
cbm=$(vpholu.ne|head -4|tail -1|awk '{print $8}')
kpv=$(vpholu.ne|head -3|tail -1|awk '{print " " $11 " " $12 " " $13}')
kpc=$(vpholu.ne|head -4|tail -1|awk '{print " " $11 " " $12 " " $13}')
gap=$(vpholu.ne|tail -1|awk '{print $7}')
#dipc=$(grep 'dipol+quadrupol energy correction' OUTCAR | awk '{print $4}')
#vdwc=$(grep 'Edisp (eV)' OUTCAR | awk '{print $3}')
echo "${1}-${posroot}  $ene  $vbm  $cbm  $gap  $kpv  $kpc">>../../SUMBANDENEVP-${1}
else
echo "${1}-${m} no gd.out/POSCAR.optF!"
exit 1
fi

cd ../
done

cd ../
fi
#sort -gk 2 SUMBANDENEVP>>SUMBANDENEVP-sort
#sort -gk 2 SUMBANDENEVP-${i} >>SUMBANDENEVP-${i}-sort
