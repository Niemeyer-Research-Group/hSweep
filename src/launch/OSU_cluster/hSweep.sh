#!/bin/zsh

#$ -cwd
#$ -N hSweptTest
#$ -q mime4
#$ -pe mpich3i 40
#$ -j y
#$ -R y
#$ -o ../../.runOut/hSweptTest.out
#$ -l h='compute-e-[1-2]

export JID=$JOB_ID

echo $JOB_ID

hostname

ls rslts

rm rslts/* || true

ls rslts

tfile="trslt/otime.dat"
opath="$MSCRATCH/rslts"
testdir=$HSWEEPDIR/src/oneD/tests
rm $tfile || true

eqs=(euler heat)
tfs=(0.06 1.2)
nxStart=100000

mkdir -p $opath
mkdir -p $(dirname $tfile)

for ix in $(seq 2)
do
	eq=$eqs[$ix]
	tf=$tfs[$ix]
	for sc in S C
	do
		for t in $(seq 6 10)
		do
			for dvt in $(seq 0 1)
			do
				tpbz=$((2**$t))
				tpb=$(($tpbz + 0.5*$dvt*$tpbz))
				for g in $(seq 0 10 100)
				do
					snx0=$SECONDS
					for x in $(seq 0 7)
					do
						if [[ $x -gt 0 && $x -lt 7 ]]
						then
							midpt=1
						else
							midpt=0
						fi
						for dvx in $(seq 0 $midpt)
						do
							echo -------- START ------------
							nxo=$(($nxStart * 2**$x))
							nx=$(($nxo + 0.5*$dvx*$nxo))
							lx=$(($nxo/10000 + 1))
							S0=$SECONDS

							$MPIPATH/bin/mpirun -np 40 -machinefile $HSWEEPDIR/src/nrg-nodes $HSWEEPDIR/src/bin/$eq $sc $testdir/"$eq"Test.json $opath tpb $tpb gpuA $g nX $nx lx $lx tf $tf
							
                            echo len, eq, sch, tpb, gpuA, nX
							s1=$(($SECONDS-$S0))
							echo $lx, $eq, $sc, $tpb, $g, $nx took $s1
							echo -------- END ------------
							sleep 0.05
						done
					done
					snx1=$(($SECONDS-$snx0))
					snxout=$(($snx1/60.0))
					echo $eq "|" $sc "|" $tpb "|" $g :: $snxout >> $tfile
				done
			done
		done
	done
done

