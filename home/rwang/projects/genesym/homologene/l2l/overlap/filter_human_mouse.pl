#!/usr/bin/perl -w

use strict;
use Data::Dumper;
my %human_genes = ();
unless (@ARGV==1){
	print <<EOH;
	usage: $0 <2-col file>

	This script takes a file w/ 2 cols of gene names, human and mouse
	and tries to find unique pairs of gene names to build a translation
	table of human->mouse genes. 
	It reports cases of ambiguity where the left col gene name
	is used more than once.
EOH
exit(0);
}
open(INPUT, $ARGV[0]) or die "cannot open file\n";
open(OUTPUT, ">$ARGV[0].filtered") or die "cannot open file for write\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @genes = split(/\t/, $_);
	if (($genes[0] ne '') && ($genes[1] ne '')) {
		if (exists $human_genes{$genes[0]} ){
			push @{$human_genes{$genes[0]}}, $genes[1] if join(" ",@{$human_genes{$genes[0]}})!~/$genes[1]/ig;
		} else {
			$human_genes{$genes[0]} = [$genes[1] ];
		}
	}
}
#print Dumper(\%human_genes);
#get unique human genes
my @ilmngene = keys(%human_genes);
print "number of distinct human ILMN genes is: ", scalar @ilmngene, "\n";
foreach my $key (keys %human_genes){
	#print "$key has ", scalar @{$human_genes{$key}} , " matches\n";
	if (scalar @{$human_genes{$key}} > 1){
		print "$key has ", scalar @{$human_genes{$key}} , " matches ";
		print "@{$human_genes{$key}}\n";
	}else{
		print OUTPUT "$key\t@{$human_genes{$key}}\n";
	}
}
