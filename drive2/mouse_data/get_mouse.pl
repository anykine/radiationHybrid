#!/usr/bin/perl -w
#
use strict;
use lib '/home/rwang/lib';
use t31datamanip;
use Data::Dumper;

unless(@ARGV==3){
	print <<EOH;
	usage $0 <nlp/alpha> <gene> <marker>
	
	get nlp/alp data from file for specified gene/marker pair
EOH
exit(1);
}

my $fh;
if ($ARGV[0] eq 'alpha'){
	$fh = open_t31file('alpha');
} elsif ($ARGV[0] eq 'nlp') {
	$fh = open_t31file('nlp');
} else {
	print "error: specify alpha or nlp\n";
	exit(1);
}

my $rec = get_t31record($ARGV[1], $ARGV[2], $fh);

print "gene=$ARGV[1]\tmarker=$ARGV[2]\t";
print "alpha=$rec\n" if $ARGV[0] eq 'alpha';
print "nlp=$rec\n" if $ARGV[0] eq 'nlp';
