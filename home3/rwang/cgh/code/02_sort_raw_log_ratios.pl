#!/usr/bin/perl -w

$t="\t";
$n="\n";

$file=$ARGV[0];

open (HANDLE, $file);
open(OUTHAN, ">temp");
while (<HANDLE>) {
	chomp $_;
	($chr, $start, $stop, $l)	= split ("\t" , $_);

	if ($chr =~ /chr1$/) { $chr="chr01"; }
	if ($chr =~ /chr2$/) { $chr="chr02"; }
	if ($chr =~ /chr3$/) { $chr="chr03"; }
	if ($chr =~ /chr4$/) { $chr="chr04"; }
	if ($chr =~ /chr5$/) { $chr="chr05"; }
	if ($chr =~ /chr6$/) { $chr="chr06"; }
	if ($chr =~ /chr7$/) { $chr="chr07"; }
	if ($chr =~ /chr8$/) { $chr="chr08"; }
	if ($chr =~ /chr9$/) { $chr="chr09"; }

	print OUTHAN $chr.$t.$start.$t.$stop.$t.$l.$n;

}
close (HANDLE);

`sort -k 1,1 -k 2,2n temp > $ARGV[1]`;
`rm temp`;
