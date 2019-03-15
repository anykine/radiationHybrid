#!/usr/bin/perl -w
#takes 2 columns from illumina ref8 files, target,probe
# and makes fasta format
#  >fastname
#   gatcgatcgatc

use strict;

open(INPUT, $ARGV[0]) or die "cannot open file\n";

while(<INPUT>){
	next if /^#/;
	my @data = split(/,/);
	print ">$data[0]\n";
	print "$data[1]\n";
}
