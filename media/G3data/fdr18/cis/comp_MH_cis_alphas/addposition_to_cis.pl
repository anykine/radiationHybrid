#!/usr/bin/perl -w
# 8/20/10
#Add the hg18 human position information to the file
# comp_hum_mouse_FDR40_symbol.txt
use strict;
use Data::Dumper;

#store the gene pos
my %genepos = ();
open(INPUT, "/home3/rwang/expr/phase2/conv_pos_hg18/ilmn_genepos_hg18.txt") || die "err $!";
my $counter = 1;
while(<INPUT>){
	chomp;
	my(undef, $chrom, $start, $stop, undef) = split(/\t/);	
	$genepos{$counter++} = {
		chrom => $chrom,
		start => $start,
		stop => $stop
	};
}
close(INPUT);


#open(INPUT, "comp_hum_mouse_FDR40_symbol.txt") || die "err $!";
open(INPUT, "comp_hum_mouse_FDR20_symbol.txt") || die "err $!";
while(<INPUT>){
	chomp;
	my ($humgene, $humalpha, $musgene, $musalpha, $symbol) = split(/\t/);
	if (defined $genepos{$humgene} ){
		print join("\t", 
			$genepos{$humgene}{chrom}, 	
			$genepos{$humgene}{start}, 	
			$genepos{$humgene}{stop}, 	
			$humgene,
			$humalpha,
			$musgene,
			$musalpha,
			uc($symbol)
		), "\n";
	}
}
