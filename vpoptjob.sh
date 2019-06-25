#!/bin/bash

set -o errexit

u=4

if [ x${1} != x ];then

if [ ! -s exband-atk.sh ];then
  echo "           --------------- ERROR -------------            "
  echo ">>>>>>>>>>>>>>>>> No prgram exband-atk.sh <<<<<<<<<<<<<<<<<<"
  echo
  exit 1
fi

if [ ! -s uniqstr.ne ];then
  echo "           --------------- ERROR -------------            "
  echo ">>>>>>>>>>>>>>>>> No prgram uniqstr.ne <<<<<<<<<<<<<<<<<<"
  echo
  exit 1
fi

cd ${1}
../exband-atk.sh
../uniqstr.ne SUMBANDENE-sort
sort -nk 2 rmdupl.dat >rmdupl.dat-sort
cat rmdupl.dat-sort
cd ../

uninum=$(cat ${1}/rmdupl.dat-sort|cut -d' ' -f1)
mkdir ${1}-vpopt
cd ${1}-vpopt

for m in ${uninum[@]}
do
#ilen=${#m}
#ilast=$(echo $m|cut -c ${ilen})
#jlen=$((ilen-1))
#j=$(echo $m|cut -c 1-${jlen})
#if [ $ilast == 'N' ];then
#  posroot=${j}
#else
  posroot=${m}
#fi
mkdir p${posroot}
cd p${posroot}
cp ../../${1}/POSCAR_permu${posroot} POSCAR

atxt=$(head -8 POSCAR|tail -1|awk '{print $1}')
if [ ${atxt} == 'Selective' ];then
  sed -i '8d' POSCAR
fi

#sed -i 's//' POSCAR

    if [ -e POSCAR ];then
      aelem2=($(head -6 POSCAR|tail -1))
    else
      exit 1
    fi
    if [ -e POTCAR ];then
      rm POTCAR
    fi
    for k in ${aelem2[@]}
    do
     if [ "${k}" == "C" ] || [ "${k}" == "N" ] || [ "${k}" == "O" ] || [ "${k}" == "H" ];then
       cat /opt/QMD/paw-pbe/${k}/POTCAR>>POTCAR
     elif [ "${k}" == "Sc" ] || [ "${k}" == "Zr" ];then
       cat /opt/QMD/paw-pbe/${k}_sv/POTCAR>>POTCAR
     else
       cat /opt/QMD/paw-pbe/${k}_pv/POTCAR>>POTCAR
     fi
   done

cat>KPOINTS<<EOF
kp
0
Gamma
 1  1  1
 0  0  0
EOF

echo "Sys: ${1}-${m}"
ntype=$(head -7 POSCAR|tail -1|wc|awk '{print $2}')
echo "ntype: $ntype"
l=1
ntot=0
while [ $l -le $ntype ]; do
ni=$(head -7 POSCAR|tail -1|awk '{print $'$l'}')
iion[$l]=$(head -6 POSCAR|tail -1|awk '{print $'$l'}')
#echo "type$l: $ni"
echo "ion$l: $iion"
if [ ${iion[$l]} == 'C' ] || [ ${iion[$l]} == 'N' ] || [ ${iion[$l]} == 'O' ];then
  mg[$l]="$ni*0"
  ul[$l]="-1"
  uu[$l]="0"
  uj[$l]="0"
#elif [ ${iion[$l]} == 'Cr' ] || [ ${iion[$l]} == 'Mn' ] || [ ${iion[$l]} == 'Fe' ] || [ ${iion[$l]} == 'Co' ];then
#  mg[$l]="$ni*3"
else
  mg[$l]="$ni*1.5"
  ul[$l]="2"
  uu[$l]=${u}
  uj[$l]="0"
# u=${uu[$l]}
fi
echo "mag: ${mg[$l]}"
ntot=$((ni+ntot))
l=$((l+1))
done
echo "ntot: $ntot"

cat>INCAR<<EOF
ISTART=0
ISMEAR = 0; SIGMA = 0.08 
PREC = A; LREAL = A 
EDIFF = 1E-05   #stopping-criterion
ENCUT=520 

#Define Convergence
NELM = 100;   NELMIN= 2
LMAXMIX = 4
ALGO=F

#Define ion move
IVDW=10
NSW=100
IBRION=2
ISIF=3
CELLCONT= 0 0 1 1 1 1    # 1 fixed; 0 unfixed
#POTIM=0.2
EDIFFG=-0.02
 
#Define parallel
LPLANE  = T
NSIM = 4
#NPAR = 1 #root of nodes or nodes
#ISYM=0
LWAVE = F ; LCHARG = F ; LELF =  F 
ISPIN=2
MAGMOM=${mg[*]}
LDAU = T
LDAUL = ${ul[*]}
LDAUU = ${uu[*]}
LDAUJ = ${uj[*]}
LORBIT=10
EOF

cat>calopt.pbs<<EOF
#!/bin/bash
#PBS -N p${posroot}-sc2${1}
#PBS -l nodes=1:ppn=12
#PBS -j oe
#PBS -V

cd \${PBS_O_WORKDIR}
export OMP_NUM_THREADS=1
#exec="atkpython"
exec="vp544s_std"
#fname1=""
#startcpu="0"
#endcpu="17"
startcpu="0"
endcpu="17"

#mpirun -np \${NP} -env I_MPI_PIN_PROCESSOR_LIST=\${startcpu}-\${endcpu} \${exec} >vpopt1.out
NP=\$(cat \$PBS_NODEFILE | wc -l)
mpirun -np \${NP} \${exec}>vpopt1.out
if [ -s vpopt1.out ];then
 atxt=\$(tail -1 vpopt1.out|awk '{print \$1}')

 if [ \${atxt} == 'reached' ];then
   cp CONTCAR POSCAR.optF
   cp CONTCAR POSCAR
 fi
fi
# else
#prep opt2
#   cp CONTCAR POSCAR.opt1
#   cp CONTCAR POSCAR
#   mpirun -np \${NP} \${exec}>vpopt2.out
#   if [ -s vpopt2.out ];then
#     atxt=\$(tail -1 vpopt2.out|awk '{print \$1}')
#     if [ \${atxt} == 'reached' ];then
#       cp CONTCAR POSCAR.optF
#       cp CONTCAR POSCAR
#     else
#       cp CONTCAR POSCAR.opt2
#       cp CONTCAR POSCAR
#       mpirun -np \${NP} \${exec}>vpopt3.out
#       if [ -s vpopt3.out ];then
#         atxt=\$(tail -1 vpopt3.out|awk '{print \$1}')
#         if [ \${atxt} == 'reached' ];then
#           cp CONTCAR POSCAR.optF
#           cp CONTCAR POSCAR
#         else
#           cp CONTCAR POSCAR.opt3
#           cp CONTCAR POSCAR
#         fi
#       fi
#     fi
#   fi
# fi
#fi
EOF

qsub calopt.pbs
cd ../
done
fi
