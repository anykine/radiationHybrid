#!/usr/bin/bash
# run blat on human genome with params
#  no header
#  min match

for i in `seq 1 22`;
do
	echo $i
	./blat -t=dna -q=dna -noHead ./db/ucsc/chr$i.fa ilmn-target-probe.fa output$i.psl
done

#also need to run for X and Y chroms
