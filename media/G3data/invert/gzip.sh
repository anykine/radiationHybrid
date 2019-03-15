#!/bin/bash

for i in g3output*
do
	echo $i
	gzip $i
done

echo "running g3dataconv"

/home/rwang/tut/bin/g3conv -b g3bymarker.txt g3alpha_model_resultsT
