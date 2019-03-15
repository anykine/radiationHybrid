#!/bin/bash
# do sort on each file separately

prefix=mouse;
for i in `seq -f %02g 0 86`
do
	#echo "sort -k1n -k2n $prefix$i > $prefix$i.sort"
	#sort -k1n -k2n  $prefix$i > $prefix$i.sort
	echo "sort -k1n -k2n $prefix$i > $prefix$i.sort"
	sort -k3g  $prefix$i > $prefix$i.sort
done

	
