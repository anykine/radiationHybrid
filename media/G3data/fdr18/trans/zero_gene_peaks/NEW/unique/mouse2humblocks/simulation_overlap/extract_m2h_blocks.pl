#!/usr/bin/perl -w
# extract the m2h and human blocks and create
# list of mouse block = human block
#
# fileformat
#hchrom|hstart|hstop|m2hblocknum|m2hhstart|m2hstop|mblocknum
open(INPUT, "m2h.txt") || die "cannot open m2h";
print "#mouseblock\thumanblock\n";
while(<INPUT>){
	next if /^#/; chomp;
	my @d = split(/\t/);
	my $hblock = $d[3];
	my $mblock = $d[6];

	#create the list, cross join if mult mblocks
	foreach my $m ( split(/, /, $mblock) ){
		foreach my $h ( split(/, /, $hblock) ){
			print "$m\t";
			print "$h\n";
		}
	}
}
