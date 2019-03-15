#!/usr/bin/perl 
#
use strict;
use warnings;
# removes duplicates from a file and remove all duplicates but keep orig order
# of lines

unless(@ARGV==1){
	print("usage $0 <file w/ duplicates>\n");
	exit(1);
}

#my $file = 'mus_hum_neaest_zerg_imputed.sort.txt';
my $file = $ARGV[0];
my %seen=();
{ 
	# if there's no file handle in the diamond operators, perl will
	# examine the @ARGV variable for things to read. If @ARGV is
	# empty, it will then read from STDIN.
	#
	# Here we make a local version of @ARGV, which doesn't touch
	# the global @ARGV and assign $file to it, which is then read.
	# The $^I is the backup operator and creates a file .bac which
	# is the original
	local @ARGV = ($file);
	local $^I = '.bac';
	while(<>){
		$seen{$_}++;
		next if $seen{$_} > 1;
		print ;
	}
}
print "finished processing file.\n";
