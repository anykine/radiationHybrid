#!/bin/bash 
#
# this script gives the total number of lines for all files
#
tot=0
linetot=0
tmp=0
for i in /home/rwang/projects/g3rh/downloaded/stanford_shgc/STS_INFO/Chromosome*; do
	#uncomment this to get total per file
	#tot=0
	linetot=`cat -n $i | wc -l` 
	tot=`expr $linetot + $tot`
	echo "$i has length $tot"
done
