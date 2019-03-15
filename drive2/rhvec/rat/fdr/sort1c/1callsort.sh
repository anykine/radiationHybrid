#!/bin/bash
# do sort on each file separately

prefix=rat;
for i in `seq -f %02g 0 48`
do
	sort -k1n -k2n  $prefix$i > $prefix$i.sort
done

	
