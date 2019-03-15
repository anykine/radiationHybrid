#!/bin/bash

PREFIX=rat
for i in ${PREFIX}*.sort
do
	list=$list\ $i
done
echo $list
sort -m -k3 -g $list > rat_allp_sorted.txt
