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
		echo $i
		file=hhit$i.summary.mirscan
		if [ -f "$file.out" ]; then
			echo "parsing $file.out"
			../run_mirscan_parse.pl $i $i
		fi
done
