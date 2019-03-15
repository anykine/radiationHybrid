#!/usr/bin/perl -w

use strict;
for my $file (<./comp_ilmnT/*.txt>){
	open(INPUT, "./comp_ilmnT/$file") or die "cannot open file\n";
	while(<INPUT>){
		my($chrom,$low,$hi,$name) = split;
		open(SEARCH, "./comp_agil/data$chrom.txt") or die "cannot open search file\n";
		while(<SEARCH>){
			#do some sort of comparison here, less than, greater within a window
		}
	}
}
