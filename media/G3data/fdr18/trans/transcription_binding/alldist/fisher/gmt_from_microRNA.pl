#!/usr/bin/perl -w
#
use strict;

my %data = ();
# quick reformat of microRNA into .GMT format
#
#
open(INPUT, "microrna") || die;
while(<INPUT>){
	chomp; next if /^#/;
	$data{uc($_)} = 1;
}

# output
print "MICRORNA\tna\t";
print join("\t", (sort keys %data)),"\n"
