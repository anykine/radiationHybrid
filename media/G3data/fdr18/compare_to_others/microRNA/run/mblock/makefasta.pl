#!/usr/bin/perl -w
#
use strict;
#use Data::Dumper;
# sequence files do not have a fasta header,
# this will add it based on filename

my @files = glob("*.txt");
foreach my $f (@files){
	open(INPUT, $f) || die "cannot open $f";
	open(OUTPUT, ">$f.fa") || die "cannot open write file";
	my ($insertline) = ($f =~ /(.*?)\.txt/);

	while(<INPUT>){
		if ($.==1){
			print OUTPUT ">m$insertline\n";
			print OUTPUT $_,"\n";
		} else {
			print OUTPUT $_, "\n";
		}
	}
	close(INPUT);
	close(OUTPUT);
}
######## MAIN #############
