#!/usr/bin/perl -w
#
use strict;
use lib '/home/rwang/lib';
use t31datamanip;

sub test1{
	my %data=();
	my $fh = open_t31file('alpha');
	for (my $m=1; $m<100; $m++){
		for (my $g=1; $g<20000; $g++){
			my $val = get_t31record($g, $m, $fh);
			print $val,"\n";
			push @{$data{alpha}}, $val;
		}
	}
	return(\%data);
}

sub test2{
	my $ref = shift;
	for (my $i=0; $i<100; $i++){
		for (my $j=1; $i<20000; $j++){
			print $ref->{alpha}[$i], "\n";
		}
	}

}

my $a=test1();
test2($a);
