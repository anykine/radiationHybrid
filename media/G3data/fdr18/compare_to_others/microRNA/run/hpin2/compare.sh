#!/bin/bash

start=$1
end=$2

if [ $# -ne 4 ] ;then
	echo "Usage: `basename $0` start stop dir1 dir1"
	exit 65
fi

#cmd='ls -l'
cmd='wc -l'
path=/media/G3data/fdr18/compare_to_others/microRNA/run/hpin2/
for i in `seq $start $end`
do
	file=hhit$i.summary.mirscan.out
	#echo $file
	if [ $3 = "smith1" ]; then
		path1=/media/G3data/fdr18/compare_to_others/microRNA/run/hpin/$i/$file
		#echo $path1
	else 
		path1=$path$3/$i/$file
	fi
	path2=$path$4/$i/$file
	if [ -f $path1 ] && [ -f $path2 ]; then
		#echo $path1
		#echo $path2
		#var1=`$cmd $path1 | awk '{print $5 " " $8}'`
		#var2=`$cmd $path2 | awk '{print $5 " "$8}'`

		var1=`$cmd $path1`
		var2=`$cmd $path2`
		echo $var1
		echo $var2
		echo "---"
	fi
done
