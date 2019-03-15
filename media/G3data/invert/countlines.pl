#!/usr/bin/perl -w
#
open(INPUT, $ARGV[0]) || die "cannot open file $ARGV[0]\n";
my $counter = 0;
while(<INPUT>){
	$counter++
}
print "num of lines is $counter\n";
