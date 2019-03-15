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

PVAL_FILE=
PREFIX=g3
#sort by pval
if [ -d sort1a ] ; then
	sleep 0
else
	mkdir sort1a
fi
cd sort1a
split -d -l2000000 ${PVAL_FILE} ${PREFIX}spl
#do the sorting
#merge

#calc qval
qval.pl  
#reorder qval
if [ -d sort1b ] ; then
	sleep 0
else
	mkdir sort1b
fi
cd sort1b
split -d -l2000000 ../sort1a/g3_allq.txt g3s1b
qval_reorder3.pl > g3_fdr.txt
#sort by marker



