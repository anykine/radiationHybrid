#!/usr/bin/perl -w
#
# take the raw marker-gene data and reformat 
# genepos | markerpos | neglogPval

use strict;
use Data::Dumper;

#REMEMBER, genepos and markerpos START at ZERO!
my @genepos =();
my @markerpos = ();

open(GENEPOS, "/home3/rwang/QTL_comp/g3gene_gc_coords.txt") || die "cannot open gene\n";
while(<GENEPOS>){
	chomp;
	push @genepos, $_;
}
close(GENEPOS);
open(MARKPOS, "/home3/rwang/QTL_comp/g3probe_gc_coords.txt") || die "cannot open gene\n";
while(<MARKPOS>){
	chomp;
	push @markerpos, $_;
}

#filter my big ass file to get it into matlab plottable format
open(INPUT, "cis_FDR30.txt") || die "cannot open big file\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	print $genepos[$line[0]-1], "\t", $markerpos[$line[1]-1], "\t", $line[3], "\n";
}
