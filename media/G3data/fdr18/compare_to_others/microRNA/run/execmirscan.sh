#!/bin/bash

# run mirscan in every directory, write file to file.out
if [ $# -ne 2 ]; then
  echo "Usage: `basename $0` start stop"
	exit 65
fi

start=$1
end=$2

for i in `seq $start $end`
do
	if [ -d "hpin/$i" ]; then

		echo hpin/$i
		cd hpin/$i

		path=`pwd`
		file=hhit$i.summary.mirscan
		if [ -f $file ]; then 
			echo "running mirscan on $file"
			mirscan $file > $file.out 2>/dev/null
		fi
		cd ../..
		if [ -f "$path/$file.out" ]; then
			echo "parsing $path/$file.out"
			./run_mirscan_parse.pl $i $i
		fi
	fi
done
