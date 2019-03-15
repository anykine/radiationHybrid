#!/usr/bin/perl -w
use strict;
use Data::Dumper;
#
# add position information to CGH file
#
my %agilpos=(); #store positions
my @agilprobelist=(); #store list of probes in order of file
sub load_pos{
	open(INPUT, "index/agilcgh/common_cgh1.txt") || die "cannot open pos";
	while(<INPUT>){
		next if /^#/; chomp;
		my ($index, $chrom, $start, $stop, $probe, $sym) = split(/\t/);
		$agilpos{$probe} = {
			chrom=> $chrom,
			start=> $start,
			stop=> $stop,
			index=>$index,
			sym=>$sym
		};
	}
}

# add position to cgh
sub addpos_cgh{
	# use this CGH file as template for probes, all other files have
	# probes in same order
	open(INPUT, "allcgh/TCGA-02-0001-01C-01D-0185-02_S01_CGH-v4_95_Feb07_lowess_normalized.tsv")
		|| die "cannot open template";
	while(<INPUT>){
		next if /^#/; chomp;
		next if /^[^A]/; #probes begin A_
		my($probe, undef) = split(/\t/);
		#push(@agilprobelist, (split(/\t/))[0]);
		print join("\t", $probe,
			$agilpos{$probe}->{chrom},
			$agilpos{$probe}->{start},
			$agilpos{$probe}->{stop}
		),"\n";
	}

}

####### MAIN #######################
load_pos();
addpos_cgh();
#print Dumper(\@agilprobelist);
