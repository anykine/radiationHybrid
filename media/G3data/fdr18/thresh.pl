#!/usr/bin/perl -w
#
#threshold mouse cis peaks on -log p
use strict;
unless(@ARGV==2){
	print <<EOH;
	$0 <file> <pval thresh>
EOH
	exit(1);
}

open(INPUT, $ARGV[0]) || die "cannot open file for read\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	if ($line[4] >= $ARGV[1]){
		print join("\t", @line), "\n";
	}
}
