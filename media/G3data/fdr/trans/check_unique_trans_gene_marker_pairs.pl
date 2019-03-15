#!/usr/bin/perl -w
#
#just quick check to see if gene/marker pairs are unique
#and output number of peaks for every gene
use strict;
use Data::Dumper;

open(INPUT, "trans_peaks_FDR40.txt") or die "cannot open file\n";
my %genemarker=();
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	$genemarker{$line[0]}{$line[1]} = 1;
}

#get genome coords for ea probe
my %pgc=();
open(GC, "/home3/rwang/QTL_comp/g3gene_gc_coords.txt") || die "cannot open coords\n";
my $index=1;
while(<GC>){
	chomp;
	$pgc{$index} = $_;
	$index++;
}
close(GC);

#print Dumper(\%genemarker);

my $count=0;
foreach my $i (sort{$a<=>$b}  keys %genemarker){
	foreach my $j (sort keys %{$genemarker{$i}}){
		#print "$i\t$j\n"; 
		$count++;
	}
	#foreach gene, print gene_num, genome pos, the number of trans peaks
	print "$i\t$pgc{$i}\t$count\n";
	$count=0;
}
