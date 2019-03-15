#!/usr/bin/perl -w
#
use strict;

my $flag = 1;
open(INPUT, "hotspot100.txt") || die "cannot open hotspots\n";
while(<INPUT>){
	chomp;
	if ($flag==0 && /marker/){
		close(FILE);
		my ($marker) = /\*marker (\d+) regulates/;
		open(FILE, ">"."hot$marker".".txt") || die "cannot open output\n";
		next;
	} elsif (/marker/) {
		$flag=1;
		my ($marker) = /\*marker (\d+) regulates/;
		open(FILE, ">"."hot$marker".".txt") || die "cannot open output\n";
		next;
	} else {
		$flag=0;
	}
	
	if ($flag==0 && /\w/ ){
		chomp;
		s/\t//;
		print FILE $_,"\n";
	}
}
