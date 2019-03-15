#!/bin/bash

PREFIX=g3spl
for i in ${PREFIX}*.sort
do
	list=$list\ $i
done
echo $list
#sort -m -k1g -k2g $list > dog_fdr_inorder.txt
sort -m -k3 -g $list > g3_allp_sorted.txt
