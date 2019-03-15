#!/bin/bash

echo "running stitch..."
./stitch.pl > g3bymarker.txt
echo "running count ... "
wc -l g3bymarker.txt > g3bymarker_count.txt
