#!/usr/bin/perl -w

use strict;
use Data::Dumper;

# for zero gene ceQTL's, see if regulated genes are correlated
#
#read in human zero genes
my %humgenes=();
my %mousegenes=();

open(INPUT, "zero_gene_peaks_ucschg18.txt") || die "cannot open file1\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	$humgenes{$line[0]}++;
}
close(INPUT);

open(INPUT1, "./mouse/0_gene_300k_trans_4.0.txt") || die "cannot open file2\n";
while(<INPUT1>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	$mousegenes{$line[1]}++;
}
close(INPUT1);

open(INPUT2, "/media/G3data/fdr18/trans/comp_MH_regulators/common_human_mouse_indexes.txt") || die "can't open file3\n";
while(<INPUT2>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	if (exists $humgenes{$line[0]} && exists $mousegenes{$line[1]} ){
		print "$line[0]\t$humgenes{$line[0]}\t$line[1]\t$mousegenes{$line[1]}\n"; 
	}
}
#print Dumper(\%mousegenes);
