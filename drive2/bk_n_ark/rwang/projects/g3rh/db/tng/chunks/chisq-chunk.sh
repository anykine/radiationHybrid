#!/bin/bash
# script to run the get the chisquares for 
# all "chunk" files by calling testchisq.pl

LIMIT=66
a=36
b=0
while [ $a -le $LIMIT ]
do
	a=$(($a+1))
	#echo "$a"
	#echo "length of a is ${#a}"
	if [ ${#a} -lt 2 ]
	then
		c="0$a"
	else
		c=$a
	fi
	#b=pad $a
	d="chunk$c"
	#echo $d	
	./testchisq.pl $d
done

