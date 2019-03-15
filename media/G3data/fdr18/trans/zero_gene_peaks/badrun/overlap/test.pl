#!/usr/bin/perl -w
#
# For the 2700+ zero gene eqtl's (peak marker) , are they in the human set within dist of RADIUS?
use strict;
use Math::Round;
use Data::Dumper;
use lib '/home/rwang/lib';
use hummarkerpos;

##########################################################
#### read in mus->human marker position translation table
##########################################################
my %trans=();
open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/mus_hg18_pos_coordonly.txt") || die "file open failed\n";
while(<INPUT>){
	next if /^#/;
	next if /^M/;
	chomp;
	my @line = split(/\t/);
	#get rid of _random; assume correct
	$line[0] =~ s/_random//ig;
	#use markerID as key
	$trans{$line[3]} = join("\t", $line[0], round(($line[1]+ $line[2])/2));
}
close(INPUT);
#print Dumper(\%trans);


##########################################################
# read in mus zerog eqtl
##########################################################

my($chr,$pos);
my $counter1=0;
my $counter2= 0;

open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/uniq_markers300k_zerog_pos.txt") || die "file fail\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	#print "--line @line\n";
	if ( exists $trans{$line[3]} ) {
		$counter1++;	
	} else {
		$counter2++;	
	}
}
print "num translated $counter1, num untranslated $counter2\n";
