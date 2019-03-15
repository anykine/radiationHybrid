#!/usr/bin/perl -w
#
use strict;
use lib '/home/rwang/lib';
use hummarkerpos;
use Data::Dumper;

unless(@ARGV==0){
	print <<EOH;
	usage $0 <zero_gene_peaks_uniq.txt>
 
	add positions to zero_gene_peaks_uniq.txt file for MOUSE
EOH
exit(1);
}

######## MAIN #############
my %pos=();
open(INPUT,"mouse_cgh_pos.txt") || die "cannot open pos\n";
while(<INPUT>){
	chomp;
	my @line=split(/\t/);
	$pos{$line[3]}{chrom} = $line[0];
	$pos{$line[3]}{start} = $line[1];
	$pos{$line[3]}{stop} = $line[2];

}

#print Dumper(\%hummarkerpos_by_index);

open(INPUT, "zero_gene_peaks_uniq.txt")||die "cannot open 0-gene peaks\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	print $line[0],"\t";
	print $line[1],"\t";
	print $pos{$line[1]}{chrom},"\t";
	print $pos{$line[1]}{start},"\t";
	print $pos{$line[1]}{stop},"\t";
	print $line[2],"\t";
	print $line[3], "\n";
}
