#!/usr/bin/perl -w

open (INPUT, $ARGV[0]) || die "cannot open";

while(<INPUT>) {
	$count = ($_  =~ s/\t//g);
	print "$count\n";
}
