#!/usr/bin/perl -w
use strict;

# count the number of gene regulated by each marker
my %markers=();
open(INPUT, "/media/G3data/fdr18/trans/trans_2.4bymarker1.txt") || die "cannot open input\n";
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
#foreach my $i (sort {$a<=>$b} keys %markers){
# faster
for (my $i = 1; $i <= 235829; $i++){
	print "$i\t$markergc[$i-1]\t$markers{$i}\n";
}
