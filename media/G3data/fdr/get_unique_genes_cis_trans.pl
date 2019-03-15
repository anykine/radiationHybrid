#!/usr/bin/perl -w
use strict;

my %genes=();
open(INPUT, $ARGV[0]) || die "cannot open file for read\n";
while(<INPUT>){
	my @line = split(/\t/);
	$genes{$line[0]} = 1;
}
#output
foreach my $i (sort {$a<=>$b} keys %genes){
	print $i,"\n";
}
