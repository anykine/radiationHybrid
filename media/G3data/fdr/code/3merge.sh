#!/bin/bash
# merge groups of 30 files. This merges trans000.sort to trans810.sort

prefix=trans;
for j in `seq 0 26`
do
	k=$(($j*30))
	k1=$(($k+30-1))
	#echo $k $k1
	for i in `seq -f %03g $k $k1`
	do
		list=$list\ $prefix$i.sort
		#echo $prefix$i.sort
	done
	echo $list
	#sort -m -g  $list > sort$j
	unset list
done

#for i in `seq -f %03g 0 30`
#do
#	list=$list\ $prefix$i.sort
#done
#	echo $list
#	sort -m -g  $list > sort0_30.txt
	
