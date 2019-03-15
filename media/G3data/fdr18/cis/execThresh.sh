#!/usr/bin/sh

# foreach gene, find peak marker at various FDRs 
# 
thresh=./find_peaks_cis2.pl
#input=/home3/rwang/QTL_comp/output1/g3alpha_model_results1_cis.txt
input=/media/G3data/fdr18/g3alpha_model_results1_cis.txt
fdr2nlp[40]=0.75
fdr2nlp[30]=0.92
fdr2nlp[20]=1.16
fdr2nlp[10]=1.55
fdr2nlp[5]=1.92
fdr2nlp[1]=2.77

for iter in 40 30 20 10 5 1 
do
	file=cis_FDR$iter.txt
	#echo $thresh ${fdr2nlp[$iter]} $input > $file 
	echo $iter
	$thresh $input ${fdr2nlp[$iter]} > $file 

done
