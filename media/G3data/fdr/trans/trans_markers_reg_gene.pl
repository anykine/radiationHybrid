#!/usr/bin/perl -w
#
# for each marker, find number of genes it regulates
#
use strict;
use Data::Dumper;

#file is: gene marker somethign alpha pval
unless (@ARGV == 2){
	print "usage $0 <start> <end>\n";
	exit(1);
}
open(INPUT, "g3alpha_model_results1_gt2.4trans.txt") or die "cannot open file\n";
my %genemarker=();

while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	if ($line[1] >= $ARGV[0] && $line[0] < $ARGV[1]){
	#if ($line[2] <= 117914){
		$genemarker{$line[1]}{$line[0]} = 1;
	}
#	print STDERR $./1000,"\n" if ($. % 1000 == 0);
}
print STDERR "done reading file\n";
#get genome coords for ea probe
my %pgc=();
open(GC, "/home3/rwang/QTL_comp/g3probe_gc_coords.txt") || die "cannot open coords\n";
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
foreach my $i (sort{$a<=>$b}  keys %genemarker){
	foreach my $j (sort keys %{$genemarker{$i}}){
#for (my $i=1; $i<235830; $i++){
#	for (my $j=1; $j<20997; $j++){
		#print "$i\t$j\n"; 
		$count++ if defined ($genemarker{$i}{$j}) 
		#$count++;
	}
	#foreach gene, print gene_num, genome pos, the number of trans peaks
	print "$i\t$pgc{$i}\t$count\n";
	$count=0;
}
