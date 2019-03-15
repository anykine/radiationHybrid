#!/usr/bin/perl -w
#
# the level2 CGH normalization gives better separation of 
# male and female data, so we'll use the results of 
# analysis2/malefemale.R to call our male-female data
use strict;

my %fem = ();
# read in predetermined male/female
open(INPUT, "/media/usbdisk/tcga/analyze2/fem.idx") || die "err $!";
while(<INPUT>){
	next if /^#/; chomp;
	my @d = split(/\t/);
	$d[0] =~ s/\.CEL//;
	$fem{ $d[0] } = 1;
}
close(INPUT);

# match up M/F calls with our samples
open(INPUT, "header") || die "err $!";
open(OUTPUT, ">fem.idx") || die "err $!";
my @samples = split(/\t/, <INPUT>);
shift @samples for 1..4;
for (my $i=0; $i<= $#samples; $i++){ 
	if (defined $fem{ $samples[$i]	} ){
		print OUTPUT $samples[$i],"\t", $i+1, "\t" , "\n";
	}
	
}
