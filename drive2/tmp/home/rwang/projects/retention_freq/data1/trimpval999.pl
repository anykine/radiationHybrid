#!/usr/bin/perl -w
# 
# trim pval and leave only marker1 and marker2 
#  

#homemade library
use lib '/home/rwang/lib';
use util;

open(INPUT, "$ARGV[0]");
open(OUTPUT, ">$ARGV[0]".".txt");
while (<INPUT>) {
	my @dum = split(/\t/, $_);
	print OUTPUT "$dum[0]\t$dum[1]\n";
}
close INPUT;
close OUTPUT;

