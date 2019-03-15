#!/usr/bin/perl -w

open (INPUT, $ARGV[0]) || die "cannot open file\n";

while (<INPUT>) {
	if (/.*\t[01]/) {
		print $. . "\n";
	}

}
