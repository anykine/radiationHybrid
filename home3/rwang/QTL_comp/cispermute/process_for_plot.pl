#!/usr/bin/perl -w
# 
# process the histogram files for comparison
# of null to experimental distributions
use strict;

sub sum_distribution{
	my $file = shift;
	open(INPUT, $file) || die "cannot open file";
	my $tot = 0;
	while(<INPUT>){
		chomp;
		$tot = $tot + $_;
	}
	return $tot;
}

# shrink 100M bins to 1000 bins
sub normalize{
	my ($file, $bw, $sum) = @_;
	open(INPUT, $file) || die "cannot open flie";
	open(OUTPUT, ">$file.norm") || die "cannot open output";
	my $tot = 0;
	#my $num = $bw/$sum;
	while(<INPUT>){
		chomp;
		if ($. % $bw == 0) {
			print OUTPUT $tot/$sum,"\n";
			$tot = 0;
		} else {
			$tot = $tot + $_;
		}
	}
	#print last
	print OUTPUT $tot,"\n";
}

# sample from the null correlation
sub compress_corr{
	my($file, $stride) = @_;
	open(INPUT, $file) || die "cannot open file";
	while(<INPUT>){
		if ($. % $stride == 0){
			print $_;
		}
	}
}
######### MAIN #####################
#my $nullsum = sum_distribution("cis_null_distrib.txt");
#my $obssum = sum_distribution("cis_obs_distrib.txt");
#normalize("cis_null_distrib.txt", 10000, $nullsum);
#normalize("cis_obs_distrib.txt", 10000, $obssum);
#
compress_corr("cis_null_corr.txt", 1000);
