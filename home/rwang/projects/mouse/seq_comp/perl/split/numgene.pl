#!/usr/bin/perl -w

use strict;
unless (@ARGV == 1) {
	print <<EOH;
	usage: $0 <file to read>

	this program looks at output of exsim.pl and counts number
	of unique genes;

	e.g. $0 ./hamster_compv2.txt
EOH
	exit 0;
}
my %genelist = ();
my %geneonlylist = ();
our $genecount = 0;
our $seqcount = 0;
#loop through file of genbank records & their genes
open INPUT, $ARGV[0] or die "cannot open file\n";
while (<INPUT>){
	next if $_ !~/RECORD:/;
	my ($gene) = ($_ =~ /\s(.+)\.txt/);
	chop($gene);
	#print "$gene\n";
	$genelist{$gene}++;
	my @names = split(/\+/,$gene);
	$geneonlylist{$names[0]}++;
}
#while( my($k,$v) = each(%genelist) ) {
#	print "gene=$k count=$v\n";
#	$count++;
#}
for my $k (sort keys %genelist){
	#print "gene=$k count=$genelist{$k}\n";
	$seqcount += $genelist{$k};
	$genecount++;
}
#these are things in the form: ubc+A_51_P121212
#since some genes have mult probes
print "total genes: $genecount\n";
print "total sequences: $seqcount\n";

$genecount = 0;
$seqcount = 0;
for my $k (sort keys %geneonlylist){
	print "gene=$k count=$geneonlylist{$k}\n";
	$seqcount += $geneonlylist{$k};
	$genecount++;
}
#these are just genes: ubc
print "total gene onlys: $genecount\n";
print "total sequences: $seqcount\n";
