#!/usr/bin/perl -w

#parse list of mig id's s.t. one per line

open(INPUT, $ARGV[0]) || die "cannot open file\n";
while(<INPUT>){
	chomp($_);
	my @data = split(/,/);
	for my $i (@data) {print "$i\n";}
}
