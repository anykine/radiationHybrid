#!/bin/bash

#run rhvector
/home/rwang/projects/apps/rhvector/rhvector gb4vec_go060716.txt  

#run runchisq
/home/rwang/projects/apps/nr/runchisq gb4vec_go060716.txt.out >gb4pval_go060716.txt

#run extract smallpval
/home/rwang/projects/apps/reuse/get_small_pval2.pl gb4pval_go060716.txt > gb4pval_go060716_e11.txt

