#!/usr/bin/perl -w
#
use strict;

unless(@ARGV==1) {
	print "usage: $0 <file of columns>\n";
	print " get the chi-sq counts\n";

	exit(1);
}

open(INPUT, $ARGV[0]) || die "cannot open file for read\n";
my $count11 = 0;
my $count10 = 0;
my $count01 = 0;
my $count00 = 0;

#input is: human idx| hum alpha | mouse idx | mouse alpha
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	if ($line[1] > 0 && $line[3] > 0){
		$count11++;
	} elsif ($line[1] > 0 && $line[3] < 0){
		$count10++;
	} elsif ($line[1] < 0 && $line[3] > 0){
		$count01++;
	} elsif ($line[1] < 0 && $line[3] < 0){
		$count00++;	
	}
}

format =

               (+) human        (-) human
(+) mouse       @>>>>>>        @>>>>>>>
                     $count11, $count01
(-) mouse       @>>>>>>        @>>>>>>>
										$count10, $count00
.
write();
