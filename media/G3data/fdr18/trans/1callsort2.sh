#!/bin/bash
# do sort on each file separately

prefix=trans;
for i in `seq -f %03g 247 493`
do
	sort -k1g  $prefix$i > $prefix$i.sort
done
	
