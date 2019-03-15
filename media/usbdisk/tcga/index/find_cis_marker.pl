#!/usr/bin/perl -w
use strict;
use Data::Dumper;

# For the TCGA, we consider only cis ceQTLs
# with a radius of 2MB. For each gene, this finds the
# start/end markers that define the cis region.
# Use this as input for the regression.

our %genelist=();
our %cgh=();

sub load_gene{
	# TCGA affypos pre-normalized level1 data
	#open(INPUT, "affyexpr/affypos_common_final.txt") || die "error open expr";
	# self-normalized TCGA data
	open(INPUT, "../analyze2/affypos.norm.txt") || die "error open norm expr";
	while(<INPUT>){
		chomp;
		my($index, $chrom, $start, $stop, $sym) = split(/\t/);
		$genelist{$index}= {
				chrom => $chrom,
				start => $start,
				stop => $stop,
				symbol => $sym
		};
	}
}

sub load_cgh{
	open(INPUT, "agilcgh/common_cgh1.txt") || die "error cgh";
	while(<INPUT>){
		chomp;
		my($index, $chrom, $start, $stop, $probe, $sym) = split(/\t/);
		push @{$cgh{$chrom}{index}}, $index;
		push @{$cgh{$chrom}{start}}, $start;
		push @{$cgh{$chrom}{stop}}, $stop;
		push @{$cgh{$chrom}{symbol}}, $sym;
	}
}

sub find_cis_markers_to_gene{
	my $numgenes = keys(%genelist)."\n";
	#print $numgenes;
	my $radius = 2000000;
	# iter over all genes
	for (my $i=1; $i<=$numgenes; $i++){
		my @cis=();
		my($gchrom, $gstart, $gstop) = ($genelist{$i}{chrom}, $genelist{$i}{start}, $genelist{$i}{stop});
		#search over markers on the same chrom
		for (my $m=0; $m < scalar @{$cgh{$gchrom}{start}}; $m++){
			#find cis begin/end marker
			if ( abs($gstart - ${$cgh{$gchrom}{start}}[$m]) < $radius) {
				#push @cis, $m;
				push @cis, ${cgh{$gchrom}{index}}[$m];
			} elsif ( abs($gstop - ${$cgh{$gchrom}{stop}}[$m]) < $radius) {
				#push @cis, $m;
				push @cis, ${cgh{$gchrom}{index}}[$m];
			}
		}
		@cis = sort {$a<=>$b} @cis;
		# print gene | start marker | stop marker
		print "$i\t".$cis[0] . "\t" . $cis[$#cis] ."\n";
	}
}

############# MAIN ###################
load_gene();
load_cgh();
#print Dumper(\%cgh);
find_cis_markers_to_gene();
