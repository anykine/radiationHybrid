#!/bin/bash

for i in ./Stanford*; do
	cat $i >> newfile.txt
done
