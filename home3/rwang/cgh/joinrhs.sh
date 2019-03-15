#!/usr/bin/bash

for i in rh*
do
args=$args\ $i
done
paste $args > batch2.txt
