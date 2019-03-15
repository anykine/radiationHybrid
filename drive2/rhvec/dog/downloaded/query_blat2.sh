#!/usr/bin/bash
# run blat on dog with params
#  no header
#  min match
#
# note: 
#   -renamed ucsc chrX.fa to chr39.fa
#   -renamed ucsc chrM.fa to chr30.fa

for i in /home2/rwang/projects/dog/downloaded/geneseq/cfa01/*-seq;
do
	echo $i
	name=$(basename $i)
	blat -t=dna -q=dna -noHead -dots=10 ./ucsc/chr1.2bit $i ./cfa01/$name.psl
done

