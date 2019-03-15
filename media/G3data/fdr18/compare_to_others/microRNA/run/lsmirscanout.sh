#!/bin/bash

start=$1
end=$2

for i in `seq $start $end`
do
	#echo $file
	file=hpin/$i/hhit$i.summary.mirscan.out.result
	if [ -f $file ]; then
		#cp $file ./tmp
		ls -l $file
	fi
done
