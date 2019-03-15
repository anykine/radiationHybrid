#!/bin/bash
# do sort on each file separately

prefix=trans;
for i in `seq -f %03g 0 246`
do
	echo $prefix$i
	sort -k1g  $prefix$i > $prefix$i.sort
done

	
