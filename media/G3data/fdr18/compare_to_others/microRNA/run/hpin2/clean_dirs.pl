#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

my @josh = `ls -l josh/*`;
my %josh = map {chomp; my @d=split(" "); $d[7]=>$d[4]} grep{ /hhit/ } @josh;

#print Dumper(\%josh);
my @hpin = `ls -l ../hpin/*` ;
my %hpin = map {chomp; my @d=split(" "); $d[7]=>$d[4]} grep{ /hhit/ } @hpin;
#print Dumper(\%hpin);

foreach my $k (keys %josh){
	if (defined $hpin{$k}){
		if ($josh{$k} == $hpin{$k}){
			print "$k is safe\n";
		}
	} else {
		print "WARN: $k is not found in hpin\n";
	}
}
