#!/bin/bash

PREFIX=trans
for i in `seq -f %03g 751 774`
do
	list=$list\ $PREFIX$i.sort
done
#echo $list
sort -m -g $list > sort99
