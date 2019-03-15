#!/usr/bin/perl -w
#
# count how many genes regulated by each marker
# and how many markers regulating each gene
use strict;

my %seen=(); #for each marker, how many
#for each marker, how many genes does it regulate
open(INPUT, "../trans_peaks_3.99.txt") || die "cannot open file\n";
while(<INPUT>){
	my @d = split(/\t/);
	$seen{$d[1]}++;
}

foreach my $k (sort {$a<=>$b} keys %seen){
	print "$k\t$seen{$k}\n";
}
