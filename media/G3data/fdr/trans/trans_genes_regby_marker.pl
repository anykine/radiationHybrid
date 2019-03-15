#!/usr/bin/perl -w
#
# for each gene, find number of markers regulating it 
#
use strict;
use Data::Dumper;

#file is: gene marker somethign alpha pval
unless (@ARGV == 1){
	print "usage $0 <file> \n";
	print "eg $0 trans_peaks_FDR01.txt \n";
	exit(1);
}
open(INPUT, "$ARGV[0]") or die "cannot open file\n";
my %genemarker=();

while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	$genemarker{$line[0]}{$line[1]} = 1;
#	print STDERR $./1000,"\n" if ($. % 1000 == 0);
}
print STDERR "done reading file\n";

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

print STDERR "writing to file\n";
my $count=0;
foreach my $i (sort{$a<=>$b}  keys %genemarker){
	foreach my $j (sort keys %{$genemarker{$i}}){
		#print "$i\t$j\n"; 
		$count++ if defined ($genemarker{$i}{$j}) 
		#$count++;
	}
	#foreach gene, print gene_num, genome pos, the number of trans peaks
	print "$i\t$pgc{$i}\t$count\n";
	$count=0;
}
