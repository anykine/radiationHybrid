#!/usr/bin/perl -w
# used to get input for search_congruency2RM.pl
# which finds same peaks between rat and mouse datasets for chisquare
# 
# Since input is not in db, took raw file, searched for chisq
# pvals less than some number and output to file.
# 
# Output of this file is then filtered to get lists of markers > 20 markers
# away (expected to be about 2mb away).

open(INPUT, $ARGV[0]) or die "cannot open file\n";
while ($line = <INPUT>) {
	$line =~ s/^idx1=//;
	$line =~ s/idx2=//;
	$line =~ s/prob=//;
	my @data = split(/\t/,$line);
	if (($data[0] == 4146) && ($data[1] >=11592) && ($data[1] <=13015)){
		print $line;
	}
}
