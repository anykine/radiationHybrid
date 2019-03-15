#!/bin/bash
# for incomplete runs, get the remainder of the input file, move the 
# partial files to an "inc/" directory
path=/u/home3/richardw

#NUMS="182 184 192 194 199 332 336 341 344 350 9901 9902 9903 9905 9906 9908 9909" 
#NUMS="199"
NUMS="332 344 350 9801 9802 9803" 

for i in $NUMS
do
	echo "processing $i"
	# directory must exist
	if [ -d "$path/hpin/$i" ]; then
		cd $path/hpin/$i
		#create my temp dir
		if [ -d "./inc" ]; then
			echo "inc exists!"
		else 
			echo "making dir"
			mkdir inc
		fi

		file1=hhit$i.summary.mirscan
		file2=hhit$i.summary.mirscan.out

		# both files must exist
		if [ -e "$file1" ] && [ -e "$file2" ]; then
			flen1=`wc -l $file1 | awk '{print $1}'`
			flen2=`wc -l $file2 | awk '{print $1}'`
			diff=`expr $flen1 - $flen2`
			echo "mirscan file length $flen1"
			echo "output file length $flen2"
			echo "difference $diff"
	
			if [ "$flen1" -gt "$flen2" ]; then
				echo "doing stuff"
				mv $file1 ./inc
				mv $file2 ./inc
				tail -n $diff ./inc/$file1 > hhit$i.summary.mirscan
			fi
		fi
		cd ../
	fi
done

