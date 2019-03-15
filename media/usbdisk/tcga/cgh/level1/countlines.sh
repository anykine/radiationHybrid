#!/bin/bash
for i in TCGA*.txt
do
	wc -l $i >> wc.txt
done
