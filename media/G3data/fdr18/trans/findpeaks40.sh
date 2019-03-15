#!/usr/bin/sh
#too many trans, so i broke trans into 4 files and called
#find_peaks_and_cis on each part separately
perl find_peaks_trans.pl ../zpart1 > tF30part1 
perl find_peaks_trans.pl ../zpart2 > tF30part2 
perl find_peaks_trans.pl ../zpart3 > tF30part3 
perl find_peaks_trans.pl ../zpart4 > tF30part4 
