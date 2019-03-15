#!/usr/bin/perl -w
#
# output data for EASE GO analysis
# read in cis FDR for human, get gene symbol/accession/etc
# and writes the data into pos alpha and negative alphas output files
# 
# do same for mouse
use strict;
use Data::Dumper;

unless (@ARGV==2){
	print "usage: $0 <FDR file> <hum or mus>\n";
	print " $0 ./mouse/cis_mouse_FDR04.txt mus\n";
	exit(1);
}
open(HUMANDB, "hum_ids.txt") || die "cannot open human db\n";
open(MOUSEDB, "mouse_ids.txt") || die "cannot open mouse db\n";
open(INPUT1, $ARGV[0]) || die "cannot open file1\n";

my %humandb = ();
my %mousedb = ();

#get the FDR level from filename
my ($fdr) = ($ARGV[0] =~ /FDR(\d+)/ );

#load human identifiers
while(<HUMANDB>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	$humandb{$line[0]} = {
		'probename' => $line[1],
		'accession' => $line[2],
		'symbol' => $line[3]
	};
}

#load the mouse identifiers
while(<MOUSEDB>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	$mousedb{$line[0]} = {
		'unigene' => $line[1],
		'symbol' => $line[2],
		'genbank' => $line[3]
	};
}

open(OUT1, ">$ARGV[0]".".pos.txt") || die "cannot open output1\n";
open(OUT2, ">$ARGV[0]".".neg.txt") || die "cannot open output2\n";
#convert
#format is: human index| alpha | mouse index| alpha
while(<INPUT1>){
	next if /^#/;
	my @line = split(/\t/);
	#negative alphas
	if ($line[2] < 0){
		if ($ARGV[1] eq 'mouse') {
			print OUT2 $mousedb{$line[0]}{'symbol'}	,"\n" if defined $mousedb{$line[0]}{'symbol'};
		} else {
			print OUT2 $humandb{$line[0]}{'symbol'}	,"\n" if defined $humandb{$line[0]}{'symbol'};
		}
	#positive alphas
	} else {
		if ($ARGV[1] eq 'mouse'){
			print OUT1 $mousedb{$line[0]}{'symbol'}	,"\n" if defined $mousedb{$line[0]}{'symbol'};
		} else {
			print OUT1 $humandb{$line[0]}{'symbol'}	,"\n" if defined $humandb{$line[0]}{'symbol'};
		}
	}
}


