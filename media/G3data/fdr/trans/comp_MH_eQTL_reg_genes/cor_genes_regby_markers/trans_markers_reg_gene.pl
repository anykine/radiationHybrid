#!/usr/bin/perl -w
#
# for each gene, find number of markers that regulate it 
#
use strict;
use Data::Dumper;

unless(@ARGV==1){
	print "$0 <-log p cutoff> ($0 3.9)\n";
	print "for each gene, find # of markers that regulate it\n";
	exit(1);
}

#file is: gene marker somethign alpha pval
open(INPUT, "mouse_trans_peaks_3.99.txt") or die "cannot open file\n";
my %genemarker=();

while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	if ($line[3] >= $ARGV[0]) {
		$genemarker{$line[0]}{$line[1]} = 1;
	}
#	print STDERR $./1000,"\n" if ($. % 1000 == 0);
}
print STDERR "done reading file\n";

#get genome coords for ea probe
my %pgc=();
open(GC, "mouse_gc_coords.txt") || die "cannot open coords\n";
my $index=1;
while(<GC>){
	chomp;
	$pgc{$index} = $_;
	$index++;
}
close(GC);

#print Dumper(\%genemarker);

print STDERR "writing to file\n";
my $count=0;

#for ea gene
foreach my $i (sort{$a<=>$b}  keys %genemarker){
	#for ea marker
	foreach my $j (sort keys %{$genemarker{$i}}){
		$count++ if defined ($genemarker{$i}{$j}) 
	}
	#foreach gene, print gene_num, genome pos, the number of trans peaks
	print "$i\t$pgc{$i}\t$count\n";
	$count=0;
}
