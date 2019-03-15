#!/usr/bin/perl -w
use strict;

open(INPUT, "alpha_null_counts_merge_123and45") || die "cannot open file for read\n";
my $div = 20996*235829*5;
while(<INPUT>){
	chomp;
	print $_/$div, "\n";

}
