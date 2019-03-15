#!/usr/bin/perl -w

# count the number of genes per chrom in the 
# UCSChg18 clean sort file

use strict;
use Data::Dumper;
use Tie::IxHash;

my %count = ();
tie %count, "Tie::IxHash";
open(INPUT, "ucschg18_miRNA_cleaned_sort.txt") || die;
while(<INPUT>){
	next if /^#/; chomp;
	my @d =split(/\t/);
	$count{$d[0]}++;
}

foreach my $k ( keys %count){
	print "$k\t$count{$k}\n";
}
