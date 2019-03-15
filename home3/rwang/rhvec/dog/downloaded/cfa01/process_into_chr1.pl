#!/usr/bin/perl -w
#concat separate psl files for chr1 into one file
# rename the identifier with filename (GENEnnnnn)
use strict;
open(OUTPUT, ">dog_chr1.psl") or die "cannot open file for write\n";

for my $file (<*.psl>) {
	print $file, "\n";
	#open each file
	open(INPUT, $file) or die "cannot open file for read\n";
		while(<INPUT>){
			chomp;
			my @line = split(/\t/);
			#get GENEnnnn part of filename
			my $geneid = substr($file, 0, length($file)-8);
			$line[9] = $geneid;
			print OUTPUT join("\t", @line),"\n";
		}
		
	close(INPUT);
}
