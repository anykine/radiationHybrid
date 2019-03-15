#!/usr/bin/bash
# run blat on dog with params
#  no header
#  min match
#
# note: 
#   -renamed ucsc chrX.fa to chr39.fa
#   -renamed ucsc chrM.fa to chr30.fa

for i in `seq 37 -1 20`;
do
	echo $i
	padnum=$(printf "%02d" $i)
	echo blat -t=dna -q=dna -noHead ./ucsc/chr$i.2bit ./geneseq/outcfa${padnum}.2bit dog_chr$i.rw.psl
	blat -t=dna -q=dna -noHead ./ucsc/chr$i.2bit ./geneseq/outcfa${padnum}.2bit dog_chr$i.rw.psl
done

