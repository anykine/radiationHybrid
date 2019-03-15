#!/bin/bash
for i in *.txt
do
	echo "sorting $i"
	#sort -tk -k3n $i > $i.sort
	sort -k5.7,5.10 -k6,6n $i > $i.sort
done

