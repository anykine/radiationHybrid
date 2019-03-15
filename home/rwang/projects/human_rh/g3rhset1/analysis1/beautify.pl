#!/usr/bin/perl -w

#rearranges output of summary data for each radiation hybrid
# ie. output of R/beadarray bsdata$R 
# into everything on one line per microarray

use strict;
open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	chomp;
	if (/AVG_Signal/) {
		print "\n";	
	}
	print " $_";
}
