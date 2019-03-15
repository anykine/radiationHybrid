#!/usr/bin/perl -w
use strict;

my %affy=();
my %ilmn=();
# count unique affy genes and unique ilmn genes
open(INPUT, "affy_hugo_ilmn_common_new.txt")||die "cannot open file";
while(<INPUT>){
	next if /^#/; chomp;
	my ($affygene , $ilmngene) = split(/\t/);
	$affy{$affygene}++;
	$ilmn{$ilmngene}++;
}

print "---begin affy---\n";
foreach my $k (sort keys %affy){
	if ($affy{$k} != 1){
		print "$k\t$affy{$k}\n";
	}
}

print "--begin ilmn---\n";
foreach my $k (sort keys %ilmn){
	if ($ilmn{$k} != 1){
		print "$k\t$ilmn{$k}\n";
	}
}
