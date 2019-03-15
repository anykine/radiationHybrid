#!/usr/bin/perl -w
#
# Add the block number to the beginning of "_occupancy" files
# to make it easier to search for overlap between mouse/human
#
use strict;
use Data::Dumper;

# the simualation file is the final index (all gene deserts in human/mouse)
sub load_index{
	my ($species) = shift;
	my %index=();
	if ($species eq 'h') {
		#open(INPUT, '/media/G3data/fdr18/trans/zero_gene_peaks/NEW/simulation/zero_gene_cgh_ranges300kb.txt') || die "cannot open zero gene simulation";
		open(INPUT, '/media/G3data/fdr18/trans/zero_gene_peaks/NEW/simulation/zero_gene_cgh_ucsc+miRNA_ranges300kb.txt') || die "cannot open zero gene simulation";
	} elsif ($species eq 'm') {
		open(INPUT, '/media/G3data/fdr18/trans/zero_gene_peaks/mouse/simulation/mouse_zero_gene_cgh_markers_ranges300kb.txt') || die "cannot open zero gene simulation";
	} else {
		return -1;
	}
	my $counter=1;
	while(<INPUT>){
		next if /^#/;chomp; 
		my @d = split(/\t/);
		#make our key: startmarker|endmarker
		$index{ join("\t", $d[0],$d[3]) } = $counter++;
	}
	return \%index;
}

# want to label the _occupancy files
# format: 
#  zero gene region chrom
#  zero gene region start marker (gene desert)
#  zero gene region end marker 
#  separator
#  zero gene block start marker  (eqtl)
#  zero gene block end marker 
#
# use cols 2 and 3 as key
sub label_occup_file{
	my ($index,$file) = @_;
	open(INPUT, $file) || die "cannot open occupancy file";
	while(<INPUT>){
		next if /^#/;chomp; 
		my @d = split(/\t/);
		my $key = join("\t", $d[1], $d[2]);
		if (defined $index->{$key}) {
			print join("\t",$index->{$key},	@d),"\n";
		}
	}
}

############ MAIN ##################
# label the human FDR 20 occupancy file
#--------------------------------------
#my $index = load_index('h');

#label_occup_file($index, 
#'/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks2_FDR20_ranges300k_occupancy.txt');

#label_occup_file($index, 
#'/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks2_FDR30_ranges300k_occupancy.txt');

# label the mouse FDR 10 occupancy file
#--------------------------------------
#my $index = load_index('m');
#label_occup_file($index, 
#'/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks2_ranges300k_FDR10_occupancy.txt');

#label_occup_file($index, 
#'/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks2_ranges300k_FDR20_occupancy.txt');

#modified to accept arguments
unless (@ARGV==2){
	print "usage $0 <[m]ouse/[h]uman> <file>\n";
	exit(1);
}

my $index = load_index($ARGV[0]);
label_occup_file($index,$ARGV[1]);
