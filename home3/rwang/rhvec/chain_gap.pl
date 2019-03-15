#!/usr/bin/perl -w

use strict;

unless (@ARGV==1) {
	print <<EOH;
	usage $0 <input file> <pval threshold>
	 eg

	See if the pval between adjacent markers is not significant (possibly
	indicative of a inversion.

EOH
exit(0);
}

open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);	
	#print "$line[0]\t$line[1]\n";
	if ($line[1] == $line[0]+1 ){
		print "$line[0]\t$line[1]\n" if $line[2] > 0.05;
	} 
}
