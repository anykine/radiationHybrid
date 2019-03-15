#!/bin/bash
# do sort on each file separately

prefix=sp2;
for i in `seq -f %02g 0 24`
do
	echo "sort -k1n -k2n $prefix$i > $prefix$i.sort"
	sort -k1n -k2n  $prefix$i > $prefix$i.sort
done

#for ((i=0; i<48; i+2)) 
#do
#	#echo $i
#	echo "sort -g -k3 $prefix$i > $i.sort"
#done
	
