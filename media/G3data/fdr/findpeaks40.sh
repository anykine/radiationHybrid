#!/usr/bin/sh
#too many trans, so i broke trans into 4 files and called
#find_peaks_and_cis on each part separately
perl find_peaks_and_cis.pl trans/part1 > tF30part1 
perl find_peaks_and_cis.pl trans/part2 > tF30part2 
perl find_peaks_and_cis.pl trans/part3 > tF30part3 
perl find_peaks_and_cis.pl trans/part4 > tF30part4 
