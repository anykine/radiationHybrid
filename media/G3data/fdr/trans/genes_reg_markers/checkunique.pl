#!/usr/bin/perl -w
#
use strict;
open(INPUT, "trans2.4bymarker.txt") || die "cannot read\n";
#open(INPUT, "test.txt") || die "cannot read\n";

my $lastgene=-1; #first time only
my $lastmarker;
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	if ($lastgene == $line[0]){
		print "$line[1] not unique for $line[0]\n";
	}
	$lastgene = $line[0];
}
