#!/usr/bin/perl -w
#
use strict;
open(INPUT, "genenames1.txt") || die "cannot open file";
my $memo = "";
while(<INPUT>){
	chomp; next if /^#/;
	my @d = split(/\t/);
	if ($d[0] eq $memo){
		print $d[0],"\n";
	}
	$memo = $d[0];
}
