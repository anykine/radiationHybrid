#!/usr/bin/perl -w
#
# output data for EASE GO analysis
# this only looks at the common genes between human/mouse arrays
use strict;
use Data::Dumper;

unless (@ARGV==1){
	print "usage: $0 <FDR file>\n";
exit(1);
}
open(HUMANDB, "cis_hum_identifiers_forEASE.txt") || die "cannot open human db\n";
open(MOUSEDB, "cis_mouse_identifiers_forEASE.txt") || die "cannot open mouse db\n";
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
#

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

open(BOTHPOSHUM, ">EASE_pos_hum".$fdr.".txt") || die "cannot open output1\n";
open(BOTHPOSMUS, ">EASE_pos_mus".$fdr.".txt") || die "cannot open output1\n";
open(BOTHNEGHUM, ">EASE_neg_hum".$fdr.".txt") || die "cannot open output1\n";
open(BOTHNEGMUS, ">EASE_neg_mus".$fdr.".txt") || die "cannot open output1\n";
#convert
#format is: human index| alpha | mouse index| alpha
while(<INPUT1>){
	next if /^#/;
	my @line = split(/\t/);
	#both alphas pos
	if ($line[1] > 0 && $line[3] > 0){
		print BOTHPOSHUM "$humandb{$line[0]}{'symbol'}\n";
		print BOTHPOSMUS "$mousedb{$line[2]}{'symbol'}\n";
		#print BOTHPOSHUM "$line[0]\t$humandb{$line[0]}{'symbol'}\n";
		#print BOTHPOSMUS "$line[2]\t$mousedb{$line[2]}{'unigene'}\n";
	} elsif ($line[1] > 0 && $line[3] < 0){

	} elsif ($line[1] < 0 && $line[3] > 0){

	#both neg
	} elsif ($line[1] < 0 && $line[3] < 0){
		print BOTHNEGHUM "$humandb{$line[0]}{'symbol'}\n";
		print BOTHNEGMUS "$mousedb{$line[2]}{'symbol'}\n";
		#print BOTHNEGHUM "$line[0]\t$humandb{$line[0]}{'symbol'}\n";
		#print BOTHNEGMUS "$line[2]\t$mousedb{$line[2]}{'unigene'}\n";
	}
}


