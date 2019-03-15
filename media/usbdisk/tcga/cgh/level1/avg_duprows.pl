#!/usr/bin/perl -w
# for duplicate probes, pick one and drop the rest
# 
use strict;

my %seen=();
#data is sorted so duplicate probes are next to each other
open(INPUT, $ARGV[0]) || die "err $!";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @d = split(/\t/);
	next if  $seen{$d[0]};
	print $_, "\n";
	$seen{$d[0]} ++;
}
