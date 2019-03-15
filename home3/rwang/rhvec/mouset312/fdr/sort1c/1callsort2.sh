#!/bin/bash
# do sort on each file separately

prefix=mouc;
for i in `seq -f %02g 16 30`
do
	sort -k1n -k2n  $prefix$i > $prefix$i.sort
done
	
