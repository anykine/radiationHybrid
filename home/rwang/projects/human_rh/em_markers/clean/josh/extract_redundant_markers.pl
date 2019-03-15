#!/usr/bin/perl -w
# extract rows with only one entry
# getting markers contained inside other markers to be removed
use strict;
open(INPUT, $ARGV[0]) or die "cannot open file";

while(<INPUT>) {
	my @data = split(/\t/);
	print "$data[0]\n" if $data[1] eq "";
	#print $data[1],"\n";

}
