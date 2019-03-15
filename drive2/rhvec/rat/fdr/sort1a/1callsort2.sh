#!/bin/bash
# do sort on each file separately

prefix=rat;
for i in `seq -f %02g 49 95`
do
	sort -k3g  $prefix$i > $prefix$i.sort
done
	
