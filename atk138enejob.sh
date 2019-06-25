#!/bin/bash

set -o errexit

if [ x${1} != x ];then

if [ ! -s /opt/QMD/pos2py.ne ];then
  echo "           --------------- ERROR -------------            "
  echo ">>>>>>>>>>>>>>>>> No prgram /opt/QMD/pos2py.ne <<<<<<<<<<<<<<<<<<"
  echo
  exit 1
fi

for m in `ls POSCAR_permu*`
do
posroot=${m:7}
p=${m:12}
#if [ -d ${posroot} ];then
#  rm -rf ${posroot}
#fi
mkdir ${posroot}
cd ${posroot}
cp ../${m} POSCAR
pos2py.ne POSCAR
for n in `ls *.py`
do
if [ -e ${n} ];then
  mv ${n} ${posroot}.py
else
  echo "Error in find *.py!"
  exit 1
fi
done
 
sh ../../atk138cal.sh ${posroot}

cat>calene.pbs<<EOF
#!/bin/bash
#PBS -N p${p}-sc2${1}
#PBS -l nodes=1:ppn=1
#PBS -j oe
#PBS -V

cd \${PBS_O_WORKDIR}
export OMP_NUM_THREADS=1
exec="atkpython138"
fname1="${posroot}"

NP=\$(cat \$PBS_NODEFILE | wc -l)
mpirun -np \${NP} \${exec} \${fname1}.py>\${fname1}.out
EOF

 qsub calene.pbs

cd ../
done

else
echo "USEAG: xx [id name]"
exit 1
fi
