#!/usr/bin/perl -w

use strict;
use Data::Dumper;

unless (@ARGV==2){
	print <<EOH;
	usage $0 <file containing markers to remove> <file to filter>
		eg $0 streak.out dog_fdr_inorder.e02

	Take file1, builds hash and filters file2 so that elements in 
	file1 are removed from file2. This works for specks but not streaks.
	Preprocess first with expand.pl

EOH
exit(0);
}

my %lookup = ();

#load has dictionary 
open(INPUT, $ARGV[0]) or die "cannot open file $ARGV[0]\n";
while(<INPUT>){
	chomp;
	my @data = split(/\t/);	
	my $key = "$data[0]\t$data[1]";
	$lookup{$key} = 1;
}
close (INPUT);
#print Dumper(\%lookup);

open(INPUT2, $ARGV[1]) or die "cannot open file $ARGV[1]\n";
while(<INPUT2>){
	my @data = split(/\t/);
	my $key = "$data[0]\t$data[1]";
	if (exists $lookup{$key}) {
		#print $_ if $lookup{$key} != 1;
	} else {
		print $_; 
	}
}
