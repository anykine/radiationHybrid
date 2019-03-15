#!/bin/bash

PREFIX=mou
for i in ${PREFIX}*.sort
do
	list=$list\ $i
done
echo $list
sort -m -k3 -g $list > mou_allp_sorted.txt
