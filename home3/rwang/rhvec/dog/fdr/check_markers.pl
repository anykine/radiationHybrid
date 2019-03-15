#!/usr/bin/perl -w
use Data::Dumper;

my %key1= ();
my %key2= ();
open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @data = split(/\t/);
	push @{$key1{$data[0]}} , $data[1];
}

print Dumper(\%key1);
my @keys = keys %key1;
foreach $i (@keys){
	print $i, "\t",scalar @{$key1{$i}},"\n";
}
