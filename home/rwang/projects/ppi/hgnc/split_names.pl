#!/usr/bin/perl -w

use strict;
use constant DEBUGGING => 0;

open(INPUT, $ARGV[0]) || die "cannot open file\n\n";

while(<INPUT>){
	next if /^approved_symbol/;
	s/ //g;
	chomp($_);
	my @linedata = split(/\t/);
	print "line=@linedata\n" if DEBUGGING;
	my @alias = split(/,/, $linedata[2]) if defined $linedata[2] ;
	my @prev  = split(/,/, $linedata[1]) if defined $linedata[1] ;
	push @alias, @prev;
	print "alias=@alias\n" if DEBUGGING;
	for my $i (@alias) {print "$linedata[0]\t$i\n";}
	#print identity
	print "$linedata[0]\t$linedata[0]\n";
}
