#!/usr/bin/perl -w
# 
#  based on counts, determine if pair is in attraction
#  or repulsion 

#homemade library
use lib '/home/rwang/lib';
use util;
use strict;

open(INPUT, "$ARGV[0]");
open(OUTPUT, ">attr_repul.txt");
while (<INPUT>) {
	my @dum = split(/ /, $_);
	#print "dum = @dum\n";
	my @counts = split(/\t/, $dum[0]);	
	#print "counts = @counts\n";
	my $attr = $counts[0] + $counts[3];
	my $repul = $counts[1] + $counts[2];
	if ($attr > $repul) {
		#attraction
		print OUTPUT "A\n";
	} elsif ($attr < $repul ) {
		#repulsion
		print OUTPUT "R\n";
		#can't call
	} else {
		print OUTPUT "U\n";
	}
}
