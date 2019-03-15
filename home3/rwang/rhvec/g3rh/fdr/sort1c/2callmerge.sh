#!/bin/bash

PREFIX=g3s1c
for i in ${PREFIX}*.sort
do
	list=$list\ $i
done
echo $list
#sort -m -k1g -k2g $list > dog_fdr_inorder.txt
sort -m -k1n -k2n $list > g3_fdr_inorder.txt
