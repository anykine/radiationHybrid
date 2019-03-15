#!/usr/bin/perl -w
#
# Try and find the closest mouse zero gene block to one of 
# these lincRNA regions. I know some overlap.
#
# Find the closest lincRNA block to mouse block. Both are mm7
#
# Numbering starts at ZERO
use strict;
use Data::Dumper;

my %lincRNA=();
my %musblocks=();

sub load_mus_blocks{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k.txt") || die "cannot open mouse blocks";
	my $counter=0;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		$musblocks{$counter}{chrom} = $d[1];
		$musblocks{$counter}{start} = $d[2];
		$musblocks{$counter}{stop} = $d[5];
		$counter++;
	}
}

sub load_lincRNA{
	open(INPUT, "./mm8tomm7/lo95/lincRNA_mm8tomm7_95.txt") || die "cannot open lincRNA";
	my $counter=0;
	while(<INPUT>){
		chomp;next if /^#/; 
		my @d = split(/\t/);
		push @{$lincRNA{$d[0]}{start}}, $d[1];
		push @{$lincRNA{$d[0]}{stop}}, $d[2];
		push @{$lincRNA{$d[0]}{index}}, $counter++;
	}
	close(INPUT);
}

#find closets lincRNA block for ea mouse block
#based on start positions
sub matchup{
	my $j;

	#for each mouse block
	foreach my $i (sort {$a<=>$b} keys %musblocks){
		my %best=(dist=>100000000,index=>undef );

		my $chr = $musblocks{$i}{chrom};
		my $start = $musblocks{$i}{start};
		my $stop = $musblocks{$i}{stop};

		#search over all lincRNAs
		foreach my $j ($lincRNA{$chr}{start}){
			for (my $i=0; $i< scalar @$j; $i++){
				my $sdist = abs($j->[$i] - $start);
				if ($sdist < $best{dist}){
					$best{dist} = $sdist;
					$best{index} = $i;
				}
			}
		}
		#mouse stuff
		print join("\t", $chr, $start, $stop), "\t";
		#lincRNA stuff
		print join("\t", ${lincRNA}{$chr}{start}[$best{index}], 
											${lincRNA}{$chr}{stop}[$best{index}]
								), "\t";
		print $best{dist},"\n";
	}
}

####### MAIN #############

load_lincRNA();
#print Dumper(\%lincRNA);
load_mus_blocks();
matchup();

