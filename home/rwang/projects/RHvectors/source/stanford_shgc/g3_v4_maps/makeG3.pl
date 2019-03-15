#!/usr/local/bin/perl -w

# this script removes empty lines from G3_Chromosome_*.txt files

open (FILE, $ARGV[0]) || die "ERROR couldn't open $ARGV[0]\n";
open (OUT, ">>$ARGV[0].reformat") || die "error in making file\n";

while (<FILE>) {
    chomp;
    if (/\S/) {
	print OUT  "$_\n";
    }
   

}
	
