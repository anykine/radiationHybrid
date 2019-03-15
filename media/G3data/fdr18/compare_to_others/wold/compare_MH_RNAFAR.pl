#!/usr/bin/perl -w
#
# Let's see how close our mouse mm7 zero gene eqtls are to
# RNAFAR (mm9)

use strict;
use Data::Dumper;

my %rnafar=();
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

sub load_rnafar{
	open(INPUT, "./RNAFAR/mm9tomm7/RNAFAR_mm7.txt") || die "cannot open RNAfar";
	my $counter=0;
	while(<INPUT>){
		chomp;next if /^#/; 
		my @d = split(/\t/);
		push @{$rnafar{$d[0]}{start}}, $d[1];
		push @{$rnafar{$d[0]}{stop}}, $d[2];
		push @{$rnafar{$d[0]}{index}}, $counter++;
	}
	close(INPUT);
}

#find closest
#based on start positions
sub matchup{
	my $j;

	#for each mouse block
	foreach my $i (sort {$a<=>$b} keys %musblocks){
		my %best=(dist=>100000000,index=>undef );

		my $chr = $musblocks{$i}{chrom};
		my $start = $musblocks{$i}{start};
		my $stop = $musblocks{$i}{stop};

		#search over all RNAFAR 
		foreach my $j ($rnafar{$chr}{start}){
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
		#rnafar stuff
		print join("\t", ${rnafar}{$chr}{start}[$best{index}], 
											${rnafar}{$chr}{stop}[$best{index}]
								), "\t";
		print $best{dist},"\n";
	}
}

####### MAIN #############

load_rnafar();
#print Dumper(\%rnafar);
load_mus_blocks();
matchup();

