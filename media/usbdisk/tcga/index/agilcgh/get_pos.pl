#!/usr/bin/perl -w
#
# get probe pos info and make table
use strict;
open(INPUT, "front.1") ||die "err";
while(<INPUT>){
	chomp;
	next if $_!~/^chr/;
	next if /random/;
	my($pos, $probe, $sym) = split(/\t/);
	my $chr;
	($chr, $pos) = split(":", $pos);
	$chr =~ s/^chr//;
	$chr = 23 if $chr=~/X/;
	$chr = 24 if $chr=~/Y/;
	my($start,$stop) = split("-", $pos);
	print join("\t", $chr, $start, $stop, $probe, $sym),"\n";
}

