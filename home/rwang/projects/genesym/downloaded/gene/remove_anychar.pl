#!/usr/bin/perl -w

use strict;
unless(@ARGV==3){
	print <<EOH;
	This script removes lines with the specified symbol in the 
	designated column. Note: first column is column zero (0).
	
	usage: $0 <file> <symbol> <column>
	 e.g., $0 gene2accession.10090.refseq - 2
EOH
exit(0);
}
open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	next if /^#/;
	next if (split(/\t/))[$ARGV[2]] =~ /$ARGV[1]/;
	print;
}
