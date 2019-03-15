#!/bin/bash
for file in *.fa
do
	#echo $file
	#conver all Fasta files to 2bit files
	#this removes everything after the .fa
	faToTwoBit ${file} ${file%.fa}.2bit
done
