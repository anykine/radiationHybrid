#!/usr/bin/perl -w

my $c = 0;
open(INPUT, $ARGV[0]);
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	$c++ if $line[6] eq "0";
}
print "sum: $c\n";
