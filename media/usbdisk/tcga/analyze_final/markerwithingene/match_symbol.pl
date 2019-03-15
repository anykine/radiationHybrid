#!/usr/bin/perl -w
#
# Match RH alphas against Hapmap/TCGA alphas based on symbol
use strict;
use Data::Dumper;

my %data = ();


# load RH data
open(RH, "/media/G3data/fdr18/cis/comp_MH_cis_alphas/comp_hum_mouse_FDR40_symbol.txt" ) || die "err $!";
while(<RH>){
	next if /^#/; chomp;
	my ($humgene, $humalpha, $musgene, $musalpha, $symbol) = split(/\t/);
	$data{uc($symbol)}{RH} = {
		humgene=> $humgene,
		humalpha => $humalpha,
		musgene => $musgene,
		musalpha => $musalpha
	};
}

open(INPUT, $ARGV[0]) || die "err $!";
while(<INPUT>){
	next if /^#/; chomp;
	my ($chr, $start, $stop, $symbol, $gene, $marker, $mu, $alpha, $r, $nlp) = split(/\t/);
	if (defined $data{ uc($symbol)}){
		$data{$symbol}{Hapmap} = {
			alpha => $alpha,
			nlp => $nlp
		};
	}
}

### OUTPUT
foreach my $k (keys %data){
	if (defined $data{$k}{RH}{humalpha} & defined $data{$k}{Hapmap}{alpha}){
		# threshold FDR > 0.4
		# looked this up in fdrGO.R
		if ($data{$k}{Hapmap}{nlp} > 1.4680){
			print join("\t", $k, $data{$k}{RH}{humalpha}, $data{$k}{Hapmap}{alpha}), "\n";
		}
		
	}
}
#print Dumper(\%data);
