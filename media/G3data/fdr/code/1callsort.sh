#!/bin/bash
# do sort on each file separately

prefix=cir;
for i in `seq -f %02g 0 6`
do
	echo $prefix$i
	sort -k1g  $prefix$i > $prefix$i.sort
done

	
