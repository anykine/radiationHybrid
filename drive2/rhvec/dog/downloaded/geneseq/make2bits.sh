#!/bin/bash
for i in *.fasta
do
	echo ${i} ${i%.fasta}.2bit
	faToTwoBit ${i} ${i%.fasta}.2bit
done


