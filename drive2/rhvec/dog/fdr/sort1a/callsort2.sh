#!/bin/bash
# do sort on each file separately

prefix=spl;
for i in `seq -f %02g 25 47`
do
	echo "sort -g -k3 $prefix$i > $prefix$i.sort"
	sort -g -k3 $prefix$i > $prefix$i.sort
done

#for ((i=0; i<48; i+2)) 
#do
#	#echo $i
#	echo "sort -g -k3 $prefix$i > $i.sort"
#done
	
