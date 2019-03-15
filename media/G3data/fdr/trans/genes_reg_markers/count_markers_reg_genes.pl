#!/usr/bin/perl -w
use strict;

my %markers=();
open(INPUT, "trans2.4bymarker.txt") || die "cannot open input\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	$markers{$line[1]}++;
}

#get position
my @markergc = ();
open(POS, "/home3/rwang/QTL_comp/g3probe_gc_coords.txt") || die "cannot open coords\n";

while(<POS>){
	chomp;
	push @markergc, $_;	
}
close(POS);


#output
foreach my $i (sort {$a<=>$b} keys %markers){
	print "$i\t$markergc[$i-1]\t$markers{$i}\n";
}
