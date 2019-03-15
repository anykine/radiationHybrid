#!/bin/bash
# do sort on each file separately

prefix=mou;
for i in `seq -f %02g 0 15`
do
	sort -k3g  $prefix$i > $prefix$i.sort
done

	
