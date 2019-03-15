#!/usr/bin/perl -w
#
open(INPUT, $ARGV[0]) || die "cannot open file\n";
$count = 0;
while(<INPUT>){
	chomp;
	$count += $_;
}
print "total is: $count\n";
