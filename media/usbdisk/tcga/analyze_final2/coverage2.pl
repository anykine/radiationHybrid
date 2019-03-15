#!/usr/bin/perl -w
use strict;
use Data::Dumper;
# Determine how much of the genome varies in copy number
# in Hapmap samples.
# Criteria 1. CGH intensity must be +/- 0.3228
# Criteria 2. 2 consecutive markers
#
# This depends on global matrix. You must run bitThreshold before bitThreshold2

my $NUMSAMPLES = 237;
my $NUMAUTOMARKERS = 215720;

# 3SD thresholds
#my $thresh = 0.92;
#my $fthresh = 0.26;
#my $mthresh = 0.06;

# log2(3/2) thresholds
my $thresh = 0.58;
my $fthresh = 0.26;
my $mthresh = 0.06;

## matrix stores values; females store fem indices
my @matrix = (); 
my %females=();


#if above/below thresh, turn to 1/0 matrix
sub bitThreshold{
	print STDERR "begin thresholding...\n";	
	
	# for all chroms, except X 
	for (my $i=0; $i<= $#matrix; $i++){
		if ($i< $NUMAUTOMARKERS){
			for (my $j = 0; $j< $NUMSAMPLES; $j++){
				if ($matrix[$i][$j] > $thresh || $matrix[$i][$j] < ($thresh*-1)){
					$matrix[$i][$j] = 1;
				} else {
					$matrix[$i][$j] = 0;
				}
			}
		# Xchrom
		} else {
			for (my $j=0; $j<$NUMSAMPLES; $j++){
				if (defined $females{$j}){
					if ($matrix[$i][$j] > $fthresh || $matrix[$i][$j] < ($fthresh*-1)){
						$matrix[$i][$j] = 1;
					} else {
						$matrix[$i][$j] = 0;
					}
				} else {
					if ($matrix[$i][$j] > $mthresh || $matrix[$i][$j] < ($mthresh*-1)){
						$matrix[$i][$j] = 1;
					} else {
						$matrix[$i][$j] = 0;
					}
				}
			}
		}
	}
}

# how many markers are above/below thresh acros all samples?
sub sumAcrossRows{
	my $output = 1;
	print STDERR "summing...\n";
	open(OUTPUT, ">cghmarkers.ok") || die "err $!" if $output;
	my @rowsum=();
	for (my $i=0;$i < $NUMAUTOMARKERS; $i++){
		my $sum = 0;
		for (my $j=0; $j<$NUMSAMPLES; $j++){
			$sum += $matrix[$i][$j];
		}
		$rowsum[$i] = $sum;
	}
	
	my $rowsum = 0;
	for (my $i=0;$i < $NUMAUTOMARKERS; $i++){
		if ($rowsum[$i] > 1){
			print OUTPUT join("\t", $i, 1),"\n" if $output;
			$rowsum++  ;
		} else {
			print OUTPUT join("\t", $i, 0),"\n" if $output;
		}
	}
	print "\nautosomal coverage is ", $rowsum/$NUMAUTOMARKERS, "\n";

	#do X chromosome separately
	$#rowsum=-1;
	for (my $i=$NUMAUTOMARKERS; $i<=$#matrix; $i++){
		my $sum = 0;
		for (my $j=0; $j<$NUMSAMPLES; $j++){
			$sum += $matrix[$i][$j];
		}
		$rowsum[$i] = $sum;
	}
	
	$rowsum = 0;
	for (my $i=$NUMAUTOMARKERS; $i<=$#matrix; $i++){
		if ($rowsum[$i] > 1){
			print OUTPUT join("\t", $i, 1),"\n" if $output;
			$rowsum++;
		} else {
			print OUTPUT join("\t", $i, 0), "\n" if $output;
		}
	}
	print "\nXchrom coverage is ", $rowsum/($#matrix-$NUMAUTOMARKERS), "\n";
}

### see if there are 2 consecutive 1's
sub bitThreshold2{
	print STDERR "checking for consecutive 1's...\n";
	for (my $j = 0; $j< $NUMSAMPLES; $j++){
	  for (my $i=1; $i< $NUMAUTOMARKERS-1; $i++){
	      if (($matrix[$i][$j] ==1 && $matrix[$i-1][$j]==1) || ($matrix[$i][$j] ==1 && $matrix[$i+1][$j]==1)){
	       $matrix[$i][$j] = 1;
				} else {
					$matrix[$i][$j] = 0;
				}
		}
	}
}
###############################
### MAIN 

open(INPUT, "../analyze_final/allcgh1.txt_smoothed.scaled.noleft1") || die "err $!";
#open(INPUT, "../analyze/allcgh.sort.2.matlab") || die "err $!";
while(<INPUT>){
	chomp; next if /^#/;
	# skip the Y chrom
	next if $. > 226360; 
	push @matrix, [  split(/\t/) ];
}

## which cell ines are Male/Female X chrom
open(INPUT, "../analyze_final/fem.idx") || die "err $!";
while(<INPUT>){
	chomp; next if /^#/; my(undef, $idx) = split(/\t/);
 	$females{$idx-1} = 1;
}

bitThreshold();
sumAcrossRows();
print "\nchecking 2 consecutive 1's on autosomes\n";
bitThreshold2();
sumAcrossRows();
