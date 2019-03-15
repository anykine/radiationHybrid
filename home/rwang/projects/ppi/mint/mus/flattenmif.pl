#!/usr/bin/perl -w

#script to take network output of mifextract and turn into
# a list of gene names
use strict;

open(INPUT, $ARGV[0]) or die "cannot open file\n";
my @data;

while (<INPUT>){
	my($rec1, $rec2)= split(/:/, $_);
#	print "$rec1\n";
	chomp($rec2);
	$rec2 =~ s/^\s+//g;
	$rec2 =~ s/\s+/ /g;
	#print "$rec2\n";
	my @tmp = split(/ /, $rec2);
	for my $i (@tmp){
		print "$i\n";
	}
}
