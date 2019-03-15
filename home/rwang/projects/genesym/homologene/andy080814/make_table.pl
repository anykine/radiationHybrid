#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

# make a table out of this data
open(INPUT, "orthologous_genes_Hom_Mus.txt") || die "cannot open file\n";
my %data=();
print "#mouse\thuman\n";
while(<INPUT>){
	chomp; 
	my @line = split(/\t/);
	$data{$line[0]}{hum} = $line[3] if $line[1] == 9606;
	$data{$line[0]}{mus} = $line[3] if $line[1] == 10090;
}
#print Dumper(\%data);

#output
my $counter = 0;
my @keys = sort { $a<=>$b} keys %data;
foreach my $i (@keys){
	print "$data{$i}{mus}\t$data{$i}{hum}\n";
	$counter++ if uc($data{$i}{mus}) eq uc($data{$i}{hum});
}

print "$counter out of ".scalar @keys. "or: ". $counter/scalar @keys, "\n";
