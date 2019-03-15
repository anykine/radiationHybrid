#!/usr/bin/perl -w
#
# take the raw marker-gene data and reformat 
# genepos | markerpos | neglogPval

# 9/14/2009 updated for hg18

use strict;
use Data::Dumper;

unless (@ARGV==1){
	print "usage $0 <file to add genome coords>\n";
	print "takes file of gene|marker|alpha|nlp and converts to\n";
	print "genepos|markerpos|nlp  for plotting purposes using genome coords\n";
	exit(1);
}
#REMEMBER, genepos and markerpos START at ZERO!
my @genepos =();
my @markerpos = ();

open(GENEPOS, "/home3/rwang/QTL_comp/g3gene_gc_coordshg18.txt") || die "cannot open gene\n";
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
open(INPUT, $ARGV[0]) || die "cannot open file to format\n";
while(<INPUT>){
	chomp; next if /^#/;
	my @line = split(/\t/);
	print $genepos[$line[0]-1], "\t", $markerpos[$line[1]-1], "\t", $line[3], "\n";
}
