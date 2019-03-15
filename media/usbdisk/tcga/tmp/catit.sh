#!/usr/bin/bash

for i in broad.mit.edu_GBM.HT_HG-U133A.*.sdrf.txt;
do
	list=$list" "$i
done
cat $list > allsdrf.txt
