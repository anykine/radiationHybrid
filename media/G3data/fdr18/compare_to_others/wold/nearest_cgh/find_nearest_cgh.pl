#!/usr/bin/perl -w
#
# For a wold gene that overlaps a (mouse) zero gene block,
# find the closest CGH marker and report its -log pval.
#
#
# Numbering starts at ZERO
use strict;
use Data::Dumper;
use lib '/home/rwang/lib';
use t31markerpos;

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

# for a lincRNA, find the closest CGH marker to start of lincRNA
# return a hash of cgh markers
sub find_closest_cgh_to_wold{
	my %closeCGH=();
	load_markerpos_from_db_range("mouse_rhdb");
	open(INPUT, "../../20090330mus_wold_overlap.txt") || die "cannot open mouse wold overlap";
	while(<INPUT>){
		next if /^#/; chomp;
		my @d = split(/\t/);
		my($chr,$woldStart,$woldStop) = ($d[0],$d[3], $d[4]);
		my %best=(dist=> 10000000);
		for (my $i=0; $i<scalar @{$t31markerpos{$chr}{pos}}; $i++){
			if (abs($woldStart - ${$t31markerpos{$chr}{pos}}[$i]) < $best{dist}){
				$best{dist} = abs($woldStart-${$t31markerpos{$chr}{pos}}[$i]);
				$best{idx}  = ${$t31markerpos{$chr}{idx}}[$i];
			}
		}
		if ($best{dist} < 10000000){
				$closeCGH{ $best{idx} } = 1;	
				print join("\t",@d), "\t";
				print $best{dist},"\t";
				print $best{idx},"\n";
		}
	}
	return \%closeCGH;
}

# get the pval for CGH markers closest to lincRNA
sub get_close_pvals{
	my ($close) = @_;
	open(INPUT, '/media/G3data/fdr18/trans/zero_gene_peaks/mouse/0_gene_300k_trans_4.0_peak2.txt') || die "cannot open mouse zero gene peaks";
	while(<INPUT>){
		next if /^#/; chomp;
		my @d = split(/\t/);
		if (defined $close->{$d[2]} ){
			print join("\t", @d),"\n";
		}
	}
}
####### MAIN #############

#load_lincRNA();
#load_mus_blocks();
#matchup();
my $close = find_closest_cgh_to_wold();
get_close_pvals($close);
