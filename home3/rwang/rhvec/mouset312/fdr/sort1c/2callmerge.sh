#!/bin/bash

PREFIX=mouc
for i in ${PREFIX}*.sort
do
	list=$list\ $i
done
echo $list
sort -m -k1n -k2n $list > mou_fdr_inorder.txt
