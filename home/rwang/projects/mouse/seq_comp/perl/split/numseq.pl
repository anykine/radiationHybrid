#!/usr/bin/perl -w

use strict;
unless (@ARGV == 1) {
	print <<EOH;
	usage: $0 <file to read>

	this program looks at output of exsim.pl and counts number
	of alignments of a certain length (for the 60mer);

	e.g. $0 ./hamster_compv4.txt
EOH
	exit 0;
}
my %seqlist = ();
our $count = 0;
#loop through file of genbank records & their genes
open INPUT, $ARGV[0] or die "cannot open file\n";
while (<INPUT>){
	next if $_ !~/seq1=/;
	my ($seq) = ($_ =~ /seq1=(\d+:\d+)/);
	print "$seq\n";
	$seqlist{$seq}++;
}
#while( my($k,$v) = each(%genelist) ) {
#	print "gene=$k count=$v\n";
#	$count++;
#}
for my $k (sort keys %seqlist){
	print "gene=$k count=$seqlist{$k}\n";
	$count++;
}
print "total seq: $count\n";
