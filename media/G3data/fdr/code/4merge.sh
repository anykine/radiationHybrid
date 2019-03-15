#!/bin/bash

PREFIX=sort
for i in `seq 0 25`
do
	list=$list\ $PREFIX$i
done
echo $list
sort -m -g $list > /home/rwang/trans_allp_sorted.txt
