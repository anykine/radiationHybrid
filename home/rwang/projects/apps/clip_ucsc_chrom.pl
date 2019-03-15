#!/usr/bin/perl -w

use strict;

unless (@ARGV == 2){
	print <<EOH;
	usage: $0 <file with chrom> <column of chrom (this is 0-based)>

	Feed in a tab delim file of UCSC genome position output. This will
	get rid of the leading 'chr' before the chromosome and 
	convert X and Y to numbers. 

	As a standard chrUn = 99, chrM=98, chrY=97, chrX=96
EOH
exit(0);
}

open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	$line[$ARGV[1]] =~ s/chrX/chr96/i;
	$line[$ARGV[1]] =~ s/chrY/chr97/i;
	$line[$ARGV[1]] =~ s/chrM/chr98/i;
	$line[$ARGV[1]] =~ s/chrU/chr99/i;
	#get rid of leading chr
	$line[$ARGV[1]] =~ s/chr//ig;
	print join("\t",@line);
	print "\n";
}
