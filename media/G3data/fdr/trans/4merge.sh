#!/bin/bash

PREFIX=sort
for i in `seq 0 27`
do
	list=$list\ $PREFIX$i
done
echo $list
sort -m -T /media/G3data -g $list > trans_allp_sorted.txt
