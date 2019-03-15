#!/usr/bin/perl -w
# Filter cgh_markers_within_genes.txt so that only one
# marker per gene
use strict;
use Data::Dumper;

my %seen=();
open(INPUT, "cghmarkers_within_genes.txt") || die "err $!";
while(<INPUT>){
	chomp; next if /^#/;
	my @d = split(/\t/);
	if (defined $seen{ $d[0] } ){
		#print
	} else {
		print join("\t", @d), "\n";
		$seen{ (split(/\t/))[0]}++;
	}
}

#print Dumper(\%seen);
