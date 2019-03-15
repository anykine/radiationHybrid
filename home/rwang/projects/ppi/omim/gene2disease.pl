#!/usr/bin/perl -w

#assembles a list of diseases and  genes 
# from OMIM database, morbidmap

use strict;
use Data::Dumper;

my %disease=();
#this is bar separated
open(INPUT, "morbidmap") or die "cannot open file1!\n";
while(<INPUT>) {
	chomp;
	my @data = split(/\|/);
	#data[0] is the disease
	#data[1] is list of genes assoc w/disease

	#skip if disease starts with a [ or a {
	next if /^\[/;
	next if /^\{/;

	my @genes = split(/,/, $data[1]);
	foreach my $el (@genes){
		print "$data[0]\t$el\n";
	}
}

close(INPUT);

