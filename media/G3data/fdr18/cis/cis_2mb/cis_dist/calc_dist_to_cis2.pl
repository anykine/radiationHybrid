#!/usr/bin/perl -w
use strict;
use Data::Dumper;

# Find the distance from gene to cis marker using cis_FDR40.txt file

my %pgc=();
my %mgc=();

# build hash of cgh probe coordinates
sub load_probepos{
	my $markerfile="/home3/rwang/QTL_comp/g3probe_gc_coords.txt";
	open (HANDLE, $markerfile) or die "cannot open $markerfile\n";
	my $index=1;
	while (<HANDLE>){
		chomp ;
		$mgc{$index}=$_;
		$index++;
	}
	close (HANDLE);
}

#build hash of gene coordinates
#my %pgc=();
sub load_genepos{
	#my $genefile="/home3/rwang/QTL_comp/g3gene_gc_coords.txt";
	my $genefile="/home3/rwang/QTL_comp/g3gene_gc_coordshg18.txt";
	open (HANDLE, $genefile) or die "cannot open $genefile\n";
	my $index=1;
	while (<HANDLE>){
		chomp ;
		$pgc{$index}=$_;
		$index++;
	}
	close (HANDLE);
}

sub find_closest_cis{
	open(INPUT, "../cis_FDR40.txt") || die "cannot open FDR40";
	while(<INPUT>){
		next if /^#/; chomp;
		my ($gene, $marker, $alpha, $nlp) = split(/\t/);
		print join("\t",
						$gene,
						$pgc{$gene},
						$marker,
						$mgc{$marker},
						$alpha,
						$nlp
						), "\n";
	}
}


##############################
load_probepos();
load_genepos();
find_closest_cis();
