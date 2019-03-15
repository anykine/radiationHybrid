#!/usr/bin/perl -w
# ***modified for human lifted onto mouse...
# make a list of the original mouse marker order
#  with liftover to human order
# to see where gaps exist
use strict;
use Data::Dumper;

our %lo=();
unless (@ARGV==1){
	print("\nusage $0 ./liftover95/mus_hg18_pos.bed\n");
	print("show mouse and liftover mouse2human side by side\n");
	exit(1);
}
open(INPUT, $ARGV[0]) || die "cannot open input file\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	#only store chrom | start | stop
	$lo{$line[3]} = join("\t", $line[0], $line[1], $line[2]);
}

# use mouse as reference
open(INPUT, "human_cgh_pos.bed" ) || die "cannot open file\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	print join("\t",@line[0,1,2]), "\t";
	if (exists $lo{$line[3]}) {
		print $lo{$line[3]}, "\n";
	} else {
		print "0\t0\t0\n";
	}
}
