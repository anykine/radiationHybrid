#!/bin/bash
# merge groups of 30 files. This merges trans000.sort to trans810.sort

prefix=trans

for i in `seq -f %03g 811 822`
do
	list=$list\ $prefix$i.sort
done
	echo $list
	sort -m -g  $list > sort27
	
