#!/usr/bin/perl -w

unless (@ARGV == 2) {
	print <<EOH;
	extract a particular cell line from data
	usage $0 <marker file> <column>

EOH
exit(0);
}
open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	my @data = split(/\t/, $_);
	my @hybrid = split(//, $data[1]);
	print "$data[0]\t$hybrid[$ARGV[1]]\t$data[2]\t$data[3]\t$data[4]";
}
