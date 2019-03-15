#!/usr/bin/perl -w
#
use strict;

my $tot = 0;
open(INPUT, $ARGV[0]) || die "cannot read file\n";
while(<INPUT>){
	chomp;
	$tot += $_;
}

print "sum is $tot\n";
