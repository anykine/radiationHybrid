#!/usr/bin/perl -w
#utilit to strip some characters from file and output specific marker

use strict;

unless ($ARGV[0] && $ARGV[1]) {
	print "$0 <filename> <marker1>\n";
	exit;
}
open(INPUT, $ARGV[0]) || die "cannot open input\n";
open(OUTPUT, ">$ARGV[0]".".e$ARGV[1]") || die "cannot open output\n";
while (my $line=<INPUT>) {
	$line=~/m1=(.*) m2=/	;
	if ($1 eq $ARGV[1]) {
		$line =~ s/m1=//;
		$line =~ s/m2=//;
		$line =~ s/://;
		print OUTPUT "$line";
	}
}
close(INPUT);
close(OUTPUT);
