#!/bin/bash

for i in ./Genebridge4*; do
	cat $i >> newfile.txt
done
