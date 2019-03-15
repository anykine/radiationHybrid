#!/usr/bin/perl -w

use strict;
unless (@ARGV == 1) {
	print <<EOH;
	usage: $0 <file to read>

	read in count.txt of #genes in hamster_compv4.txt and
	create another file with same genes grouped together
	to facilitate pruning;

	e.g. $0 ./hamster_compv2.txt
EOH
	exit 0;
}
our %genelist = ();
my %geneonlylist = ();
our $genecount = 0;
our $seqcount = 0;

builddb();
reportdb();

my %testgenelist=();
$testgenelist{ubc} = 2;
#loop through file of genbank records & their genes
open INPUT, $ARGV[0] or die "cannot open file\n";
$/ = '###';
for my $k (sort keys %genelist){
	#move to beg of file
	seek(INPUT, 0, 0);
	while (my $record = <INPUT>){
		if ($record =~ /^RECORD:\s$k\+A_51_\w+\.txt/m){
			print $record;
		} else {
			next;
		}
	}
}

sub builddb{
	open INPUT, "count.txt" or die "cannot open count.txt file\n";
	while(<INPUT>){
		next if ($_ !~ /gene=/);
		my($gene,$count) = ($_ =~ /gene=(.+) count=(\d+)/);
		$genelist{$gene} = $count;
		print "$gene and $count\n";
	}
	close INPUT;
}
sub reportdb{
	for my $k (sort keys %genelist){
		#print "gene=$k count=$genelist{$k}\n";
		print "key=$k gene=$genelist{$k}\n";
	}
}
