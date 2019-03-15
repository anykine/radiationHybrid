#!/bin/bash

# run the analyze marker2gene to gene program
for i in `seq 1 24`; do
	echo $i
	#./analyze_marker2gene.pl marker2gene_chr$i.txt > genes_withFDR40_chr$i.txt
	./4analyze_marker2gene.pl marker2gene_chr$i.txt > fdr10/genes_withFDR10_chr$i.txt
done
