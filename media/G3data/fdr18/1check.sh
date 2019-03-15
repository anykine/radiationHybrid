#!/usr/bin/sh

wc -l g3alpha_model_results1_trans.txt > num_trans.txt
./thresh.pl g3alpha_model_results1_trans.txt 2.4 > g3alpha_model_results1_transhg18_gt2.4.txt
