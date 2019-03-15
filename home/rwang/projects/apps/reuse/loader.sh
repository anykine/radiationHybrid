#!/bin/bash

for i in /home/rwang/projects/g3rh/downloaded/stanford_shgc/STS_INFO/Chromosome*; do
	echo "inserting" $i
	./bcp_stsinfo.pl $i
done
