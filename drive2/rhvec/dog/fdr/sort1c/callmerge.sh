#!/bin/bash

for i in sp2*.sort
do
	list=$list\ $i
done
echo $list
sort -m -k1g -k2g $list > dog_fdr_inorder.txt

#sort -m -k3 -g $list > dog_vec_vectors_inorder.txt.out.qval
