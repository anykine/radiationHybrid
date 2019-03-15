#!/bin/bash

PREFIX=rat
for i in ${PREFIX}*.sort
do
	list=$list\ $i
done
echo $list
sort -m -k1n -k2n $list > rat_fdr_inorder.txt
