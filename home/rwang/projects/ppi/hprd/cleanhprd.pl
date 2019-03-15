#!/usr/bin/perl -w
# read in Dumper output of genes from josh
# for the HPRD database

use strict;
use Data::Dumper;
open(INPUT, $ARGV[0]) || die "stubborn file died!";
#build hash
my %interactions = ();
my $key;
while(<INPUT>){
	next if /\$VAR1 = {/;
	if (/=>/) {
		s/\s+'([A-Za-z0-9-]*)'\s=>\s\[$/$1/;	
		chomp;
		$key = $_;
		#print "key = $key\n";
	} elsif ( /[\w]/) {
		s/\s+'([A-Za-z0-9-]+)',{0,1}$/$1/;
		#push @{ $interactions{$key} }, $_;
		#print "value = $_\n";
		chomp;
		push @{ $interactions{$key} }, $_;
	}
}
#print Dumper(\%interactions);

#output all genes
foreach $key (keys %interactions){
	print $key, "\n";
	print "number interactions=". scalar @{$interactions{$key}} ."\n";
	for my $i (@{$interactions{$key}}){
		#print $i, "\n";
	}
}

