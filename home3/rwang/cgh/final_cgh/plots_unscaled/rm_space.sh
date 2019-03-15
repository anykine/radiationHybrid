#!/bin/bash
# replace spaces in filename with underscores
for dir in RH_*; do
	cd $dir
	for file in *.pdf; do
		echo $file
		echo Convert "$file" to "${file// /_}"
		mv "$file" "${file// /_}"
	done
	cd ..

done
