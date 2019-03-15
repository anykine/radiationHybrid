#!/usr/bin/perl -w
#quickie script to calc avg of loss_gain.txt
use strict;
my $losssum;
my $gainsum;
my $count;
open(INPUT, $ARGV[0]) or die "cannot open file\n";
while(<INPUT>){
	my($rh,$loss,$gain) = split(/\t/);
	print $loss,"\n";
	$losssum += $loss;
	$gainsum += $gain;
	$count++;
}
print $count,"\n";
print "loss avg is: ", $losssum/$count, "\n";
print "gain avg is: ", $gainsum/$count;
