#!/usr/bin/perl -w

use strict;
# this file has human alpha|human nlp | mouse alpha | mouse nlp
# so split into files for human/mouse alpha and human/mouse nlp
open(INPUT, "all.txt") || die "cannot open all.txt\n";
open(ALPHA, ">all_alpha.txt") || die "cannot open alpha for write";
open(NLP, ">all_nlp.txt") || die "cannot open nlp for write";
while(<INPUT>){
	chomp; next if /^#/;
	my @d = split(/\t/);
	print ALPHA join("\t", $d[0], $d[2]),"\n";
	print NLP join("\t", $d[1], $d[3]),"\n";
}
