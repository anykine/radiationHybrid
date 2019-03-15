#!/bin/bash

#get num of trans
#wc -l trans_allp_sorted.txt > num_trans.txt

#read in length file
#numtrans=`cut -f1 -d " " num_trans.txt`
#echo $numtrans

# run qval.pl
#./qval.pl trans_allp_sorted.txt $numtrans > trans_allp_fdr.txt

# split resulting file
#split -a 3 -d -l 6000000 trans_allp_fdr.txt post 

# run qval_mod3
#./qval_reorder3_mod.pl ./ post > trans_allp_qval.txt

#do the sums add up
#wc -l trans_allp_qval.txt >> rw_num.txt

#det breakpoints
../cis/det_breakpoints.pl trans_allp_qval.txt 4932164087 > humanhg18_breakpoints.txt
