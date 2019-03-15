#!/usr/bin/perl -w
use strict;
use Data::Dumper;

# For G3 cis permutation, we consider only cis ceQTLs
# with a radius of 5MB. For each gene, this finds the
# start/end markers that define the cis region.
# Use this as input for the permuation regression.

our %genelist=();
our %cgh=();

sub load_gene{
	#open(INPUT, "affyexpr/affypos_common_final.txt") || die "error open expr";
	open(INPUT, "expr_pos.txt") || die "error open expr";
	while(<INPUT>){
		chomp; next if /^#/;
		my($index, $name, $chrom, $start, $stop, undef) = split(/\t/);
		$genelist{$index}= {
				chrom => $chrom,
				start => $start,
				stop => $stop
		};
	}
}

sub load_cgh{
	#open(INPUT, "agilcgh/common_cgh1.txt") || die "error cgh";
	open(INPUT, "cgh_pos.txt") || die "error cgh";
	while(<INPUT>){
		chomp; next if /^#/;
		my($index, $chrom, $start, $stop, undef) = split(/\t/);
		push @{$cgh{$chrom}{index}}, $index;
		push @{$cgh{$chrom}{start}}, $start;
		push @{$cgh{$chrom}{stop}}, $stop;
	}
}

sub find_cis_markers_to_gene{
	my $numgenes = keys(%genelist)."\n";
	#print $numgenes;
	#my $radius = 2000000;
	my $radius = 5000000;
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
#print Dumper(\%genelist);
#print Dumper(\%cgh);
find_cis_markers_to_gene();
