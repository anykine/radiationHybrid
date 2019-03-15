#!/usr/bin/perl -w

# subset the overlap150k.txt file for only those in humFDR30.
# read the dataNNN.txt files and build file for correlation
use strict;
use Data::Dumper;

my %humFDR30=();
my %overlap =();

sub subset_overlap150k{
	#first ID noncoding	markers at humFDR30
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/peaks3/zero_gene_peaks3_ucschg18_FDR30_markersonly.txt") || die "err $!";
	%humFDR30 = map { chomp;$_ => 1} <INPUT>;
	#print Dumper(\%humFDR30);

	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/overlap150k.txt") || die "err $!";

	my $counter=0;
	#overlap150k.txt file mouse|human|dist
	while(<INPUT>){
		chomp; next if /^#/;
		my ($mus, $hum, $dist) = split(/\t/);
		#store only those nc overlaps in humFDR30
		if (defined $humFDR30{$hum}){
			$overlap{$counter} = {
				mus=>$mus,
				hum=>$hum
			};
		}
		$counter++;
	}
	#my @tmp= sort { $a<=>$b} (keys %overlap);
	#print scalar @tmp;
	#exit(1);
	#print Dumper(\%overlap);
}

# build a long file of alpha values
# from the humFDR30-mouse noncoding dataNNN.txt files.
# dataNNN.txt files format:
# 	humAlpha | humNLP | musAlpha | musNLP
sub build_subset_alphas{
	open(OUTPUT, ">>all_alpha_humFDR30.txt") || die "err $!";
	my $path = "/media/G3data/fdr18/trans/zero_gene_peaks/top2002/data/data/";
	for my $k (sort {$a<=>$b} keys %overlap){
		print STDERR $k,"\n";
		#if ($k == 22){
		#	exit(1);
		#}
		my $fname = $path."data".$k.".txt";
		
		if ( -e "$fname"){
			open(INPUT, $fname) || die "err $!";
			while(<INPUT>){
				print OUTPUT;
			}
			close(INPUT);
		} else {
			die;
		}
	}
}

######### MAIN #####################
subset_overlap150k();
build_subset_alphas();
