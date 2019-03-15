#!/usr/bin/perl -w
use strict;

open(INPUT, "alpha_hist.txt") || die "cannot read\n";
#open(INPUT, "test") || die "cannot read\n";
my $sum;
while(<INPUT>){
	chomp;
	$sum += $_;
	print $sum,"\n";
}
