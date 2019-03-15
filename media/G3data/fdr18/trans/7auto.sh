#clean up prev files
rm post* 

# split the trans
perl ../../fdr/trans/split_on_genenum.pl ../../fdr/trans/g3alpha_model_results1_gt2.4trans.txt 6000 part

# get the trans peaks
sh findpeaks40.sh
