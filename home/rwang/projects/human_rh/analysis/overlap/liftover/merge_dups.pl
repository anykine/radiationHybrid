#!/usr/bin/perl -w
# AGIL data format;
#     chrom, start, stop, gene name, probe(unused),kgID (unused) 
# ILMN data format:
#     chrom, start, stop, gene name
use strict;
use Data::Dumper;

unless (@ARGV == 2){
	print <<EOH;
	usage: $0 <file to merge> <ILMN or AGIL>
		e.g. $0 comp_agil/data4.txt AGIL

	this script takes microarray gene name, chrom, position
	and merges adjacent genes s.t. only one gene is in the list
	per file. Some genes have different start/end positions but
	represent the same genes.
EOH
exit(0);
}
my %genehash=();

open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
while(<INPUT>){
	chomp;
	my @data = split(/\t/);
	#agilent files
	if ($ARGV[1] eq 'AGIL'){
		if (exists $genehash{$data[3]}){
			#update start as appropriate
			if ($data[1] < $genehash{$data[3]}{'start'}){
				$genehash{$data[3]}{'start'}=$data[1];
			}
			#update end as appropriate
			if ($data[2] > $genehash{$data[3]}{'end'}) {
				$genehash{$data[3]}{'end'}=$data[2];
			}
			#how many times have i seen you?
			$genehash{$data[3]}{'instance'}++;
		} else {
			$genehash{$data[3]} = {'chrom'=>$data[0], 
				'start'=>$data[1],
				'end'=>$data[2],
				'symbol'=>$data[3],
				'kgID'=>$data[4],
				'instance'=>1
			};
		}
	} elsif ($ARGV[1] eq 'ILMN'){
		if (exists $genehash{$data[3]}){
			#update start as appropriate
			if ($data[1] < $genehash{$data[3]}{'start'}){
				$genehash{$data[3]}{'start'}=$data[1];
			}
			#update end as appropriate
			if ($data[2] > $genehash{$data[3]}{'end'}) {
				$genehash{$data[3]}{'end'}=$data[2];
			}
			#how many times have i seen you?
			$genehash{$data[3]}{'instance'}++;
		} else {
			$genehash{$data[3]} = {'chrom'=>$data[0], 
				'start'=>$data[1],
				'end'=>$data[2],
				'symbol'=>$data[3],
				'instance'=>1
			};
		}
	}
}
#print Dumper(\%genehash);
#my @keys = keys(%genehash);
#print "number of keys=",scalar @keys,"\n";
#print "before sorting\n";
#print "@keys";
#print "sorting by key\n";
my @sortedkeys = sort { $genehash{$a}{'start'} <=> $genehash{$b}{'start'} } keys %genehash;
#print "@sortedkeys\n";
foreach my $i(@sortedkeys){
	print "$genehash{$i}{'symbol'}\t$genehash{$i}{'start'}\t$genehash{$i}{'end'}\n";
}
