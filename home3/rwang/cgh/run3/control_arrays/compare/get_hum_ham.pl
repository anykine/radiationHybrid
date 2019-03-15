#!/usr/bin/perl -w
use strict;
#get the mean R/G signal
open(INPUT, "hum_ham.cgh") || die "cannot open file";
<INPUT> for 1..10;
while(<INPUT>){
	my @d = split(/\t/);
	# if doesn't have a probename A_...
	next if $d[9] !~ /A_\d/;
	print "$d[32]\t$d[33]\n";
}
