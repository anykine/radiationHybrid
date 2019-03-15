#!/usr/bin/perl -w
#
#scale the freaking mouse alphas for X and Y chromosomes
#by multiplying by log10(3/2)/log10(2)
#, 22065 markers are between chroms1-19
use strict;
use POSIX qw(log10);

my $sf = log10(3/2)/log10(2);

#open(INPUT, "alp_grid.txt") || die "cannot open mouse alphas\n";
open(INPUT, "alp_grid.10") || die "cannot open mouse alphas\n";
while(<INPUT>){
	chomp;
	#if ($. <= 220065){
	if ($. <= 1){
		print $_,"\n"; 
	} else {
		my @line = split(/\t/); 
		for (my $i=0; $i < scalar @line; $i++){
			$line[$i] = $line[$i]*$sf;
		}
		print join("\t", @line), "\n";
	}
}
