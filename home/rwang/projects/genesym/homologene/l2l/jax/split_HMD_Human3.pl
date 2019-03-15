#!/usr/bin/perl -w

# this just strips the HMD_Human3.rpt file which is space delim(bastards) into tab delim
use strict;
use Data::Dumper;

open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
#$fmt = cut2fmt(8, 14, 20, 26, 30);
#cut at columns 20, 44, 68...)
#calculates the unpack A19, An, An...
my $fmt = cut2fmt(20, 44, 68, 100, 133, 158, 182, 193, 204 );
#print "$fmt\n";

while(<INPUT>){
	next if /^#/;
	my @data = unpack($fmt, $_);
	foreach my $i(@data){
		$i =~ s/\s+//;
	}
	print join("\t", @data), "\n";
	#print Dumper(\@data);
}
# right out of perl cookbook
sub cut2fmt {
	my(@positions) = @_;
	my $place;
	my $template   = '';
	my $lastpos    = 1;
	foreach $place (@positions) {
		$template .= "A" . ($place - $lastpos) . " ";
		$lastpos   = $place;
	}
	$template .= "A*";
	return $template;
}

