#!/usr/bin/perl -w
#
use strict;
use lib '/home/rwang/lib';
use hummarkerpos;
use Data::Dumper;

unless(@ARGV==0){
	print <<EOH;
	usage $0 <zero_gene_peaks_uniq.txt>
 
	add positions to zero_gene_peaks_uniq.txt file for HUMAN
EOH
exit(1);
}

######## MAIN #############
load_markerpos_by_index("g3data");
#print Dumper(\%hummarkerpos_by_index);

open(INPUT, "zero_gene_peaks_uniq.txt")||die "cannot open 0-gene peaks\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	print $line[0],"\t";
	print $line[1],"\t";
	print $hummarkerpos_by_index{$line[1]}{chrom},"\t";
	print $hummarkerpos_by_index{$line[1]}{start},"\t";
	print $hummarkerpos_by_index{$line[1]}{stop},"\t";
	print $line[2],"\t";
	print $line[3], "\n";
}
