#!/usr/bin/perl -w
#
use strict;
my %source=();


unless(@ARGV==2){
	print <<EOH;
	usage $0 <file with everything> <file to remove from>
EOH
exit(1);

}
open(INPUT, $ARGV[0]) || die "cannot open file1\n";
while(<INPUT>){
	chomp;
	$source{$_}++;
}

open(INPUT, $ARGV[1]) || die "cannot open file2\n";
while(<INPUT>){
	chomp;
	$source{$_}=0;
}

#print the first file excluding the second file
foreach my $k (keys %source){
	print $k,"\n" if $source{$k} !=0;
}
