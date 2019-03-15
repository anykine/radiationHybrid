#!/bin/bash

for i in spl*.sort
do
	list=$list\ $i
done
sort -m -k3 -g $list > dog_vec_vectors_inorder.txt.out.qval
