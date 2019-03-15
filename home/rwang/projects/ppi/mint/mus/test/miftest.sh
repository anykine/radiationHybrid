#!/bin/bash 
#
# this script gives the total number of lines for all files
#
wd=`pwd`
echo $wd
for i in /home/rwang/projects/ppi/mint/mus/test/*_small.xml; do
	#uncomment this to get total per file
	./mifextractest.pl $i
done
