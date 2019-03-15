#!/bin/bash

# run the assign marker to gene program
for i in `seq 1 24`; do
	./assign_marker2chrom.pl $i > marker2gene_chr$i.txt
	echo $i
done
