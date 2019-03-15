#!/usr/bin/perl -w

#assembles a list of genes and their phenotypes
#1.take a list of phenotypes-to-MP:nnnnnnn mapping and
#create a hash
#2.parse gene-phenotype ontology file

use strict;
use Data::Dumper;

my %phenoID=();
#this is comma separated
open(INPUT, "phenotype-ID-matching.txt") or die "cannot open file1!\n";
while(<INPUT>) {
	chomp;
	my @data = split(/,/);
	$phenoID{$data[1]}=$data[0] unless (exists $phenoID{$data[1]} );
}

close(INPUT);

my %gene=();
#this file is tab separated
open(INPUT, "gene_phenotypeID.txt") or die "cannot open file2\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @data=split(/\t/);
	my @ids = split(/,/, $data[1]);
	#print "data0 is $data[0]\n";
	#data[0] is gene name
	#@ids are phenotype id's
	if (exists $gene{$data[0]} ) {
		#check if phenotypeID already in array
		my $idstring = join(" ", @{$gene{$data[0]}});
		#print "$idstring\n";
		foreach my $el (@ids) {
			if ($idstring !~ /$el/) { 
				push @{$gene{$data[0]}}, $el;
			} 
		}
	} else {
		push @{$gene{$data[0]}}, @ids;
	}
}
close(INPUT);
#print Dumper(\%gene);

#output
while (my($k,$vref) = each(%gene) ){
	foreach my $el (@$vref){
		print "$k\t$phenoID{$el}\n";
	}
}
