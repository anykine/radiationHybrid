#!/bin/bash

./classify.pl 40 50000 > resultsFDR40cm50k.txt
./classify.pl 40 25000 > resultsFDR40cm25k.txt
./classify.pl 40 10000 > resultsFDR40cm10k.txt
./classify.pl 30 100000 > resultsFDR30cm100k.txt
./classify.pl 30 50000 > resultsFDR30cm50k.txt
./classify.pl 30 25000 > resultsFDR30cm25k.txt
./classify.pl 30 10000 > resultsFDR30cm10k.txt
