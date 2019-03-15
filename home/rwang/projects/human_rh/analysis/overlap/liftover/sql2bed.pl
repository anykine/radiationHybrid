#!/usr/bin/perl -w

use strict;
unless(@ARGV == 1){
	print <<EOH;

usage: $0 <file to convert to BED format>

This file converts MySQL output to BED format. See
genome.ucsc.edu/FAQ/FAQformat for BED specs.

EOH
exit(0);
}

open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my $chr;
	my($chrom,$start,$end,$name) = split(/\t/,$_);
	if ($chrom eq 23) {
		$chr = "chrX";
	} elsif ($chrom eq 24) {
		$chr = "chrY";
	} else{
		$chr = "chr".$chrom;
	}
	print("$chr\t$start\t$end\t$name\n");
}
