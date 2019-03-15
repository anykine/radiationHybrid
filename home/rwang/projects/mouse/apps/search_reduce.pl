#!/usr/bin/perl -w
use strict;
#
# 
# get pvals excluding surrounding 20 markers 

use Data::Dumper;

open(INPUT, $ARGV[0]) or die "cannot open file $!\n";

my @chromosomes = ('1','2','3','4','5','6','7','8','9','10','11','12',
	'13','14','15','16','17','18','19','X');
#my @chromosomes = ('1');
my $pvalue = 0.000000000001;

while (<INPUT>) {
	my @stuff = split(/\t/);
	if ($stuff[1] > $stuff[0]+50) {
		print "$stuff[0]\t$stuff[1]\t$stuff[2]";
	}
}


