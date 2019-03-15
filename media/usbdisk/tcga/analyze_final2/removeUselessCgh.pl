#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;
# Remove the CGH markers that do not vary enough (cghmarkers.ok).
# Beware of indexing! Some files have headers, some do not!
# Use this to create a *.filt file
#
my %ok = ();
# this file has first marker starting at 0.
open(INPUT, "cghmarkers.ok.x") || die "err #!";
while(<INPUT>){
	chomp; next if /^#/;
	my($m, $flag) = split(/\t/);
	$ok{$m} = 1 if $flag==1;
}
#print Dumper(\%ok);

### filter the file of choice
open(INPUT, "../analyze_final/allcgh1.txt_smoothed.scaled") || die "err $!";
#this file has a header, so skip
my $header = <INPUT>; 
print $header;
#open(INPUT, "left_smoothed.input") || die "err $!";
my $counter =0;
while(<INPUT>){
	if (defined $ok{$counter}){
		print;
	} 
	$counter++;
}
