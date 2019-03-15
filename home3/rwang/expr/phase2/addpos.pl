#!/usr/bin/perl -w
#
#add positions to those genes that have unique locations
#the ilmn_goodpos.txt file has genes with unique genome locations

use strict;
use Data::Dumper;

my %pos= ();

#build dictionary of probeIDs and pos
open(INPUT, "ilmn_goodpos.txt") || die "cannot open input\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);	
	$pos{$line[0]} = join("\t", $line[1], $line[2], $line[3]);
}
close(INPUT);
#print scalar (keys %pos);
#print Dumper(\%pos);

#if my file has a good probe, print line, otherwise ignoreA
open(INPUT, "../phase1/g3rhset_mednorm_175cols.txt") || die "cannot open exprs\n";
#print header
$_ = <INPUT>;
chomp;
print "chrom\tstart\tstop\t$_\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	if (exists $pos{$line[0]}){
		print $pos{$line[0]}, "\t",  join("\t", @line), "\n";
	}
}
