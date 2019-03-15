#!/usr/bin/perl -w

use strict;

unless(@ARGV==2){
	print <<EOH;
	usage: $0 <gene_info> <taxid>
	 e.g. $0 gene_info 10090
	
	This script extracts entries with the given taxID from a Entrez Gene 
	file and writes to separate files. Is assumes column #1 is taxid.
	10090=Mouse, 9606=Human, 10116=Rat
EOH
exit(0)
}

open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
open(OUTPUT,">$ARGV[0]".".$ARGV[1]") or die "cannot open file for write\n";
while(<INPUT>){
	next if /^#/;
	print OUTPUT $_ if /^$ARGV[1]\t/;		

}
