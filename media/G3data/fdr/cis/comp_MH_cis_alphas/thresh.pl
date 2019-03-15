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

my $file = "cis_mouse_FDR" . $ARGV[1] . ".txt";
open(INPUT, $ARGV[0]) || die "cannot open file for read\n";
open(OUTPUT, ">$file") || die "cannot open file for read\n";

while(<INPUT>){
	next if /^#/;
	chomp;
	my @line = split(/\t/);
	if ($line[3] >= $ARGV[1]){
		print OUTPUT join("\t", @line), "\n";
	}
}
