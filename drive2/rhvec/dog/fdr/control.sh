#!/bin/bash
# handles the sorting by pval, qval calc, reordering qval, sort by marker1,marker2
#handle splitting of fdr'd file

REORDER_FILE=dog_fdr_reorder2.txt
DIR=sort2a
PREFIX=sp2
if [ -d $DIR ] ; then
		sleep 0
	else
		mkdir $DIR
fi
cd $DIR
if [ -e ../$REORDER_FILE ]; then
	echo "splitting files"
	split -d -l1000000 ../${REORDER_FILE} ${PREFIX}
fi
