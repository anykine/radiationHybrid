#!/usr/bin/perl -w
#
open(INPUT, $ARGV[0]) || die "cannot open file";
srand;
my $count = 0;
while(<INPUT>){
	#every line has a Unif(0,1) probability
	#select those lines with a specified probablility
	#print rand($count), " \n";
	print $_ if rand($count) < 0.10;
}
