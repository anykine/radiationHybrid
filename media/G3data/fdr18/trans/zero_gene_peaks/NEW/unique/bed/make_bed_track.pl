#!/usr/bin/perl -w
#
# Make a bed file for UCSC browser,
#  one for human zero gene blocks
#  one for mouse zero gene blocks
#
# with the same name for orthologous blocks. That is, if a block is 
# orthologous in mouse and human, it has the same name(number)
# 
# 7/20/09 modified to use 1-based block file instead of 0-based
#         Think I broke something. 
# 7/21/09 created new sub to generate blocks directly from file of
#         zero gene blocks 
use strict;
use Data::Dumper;

my %M2Hblocks=();  # ortho blocks mouse-hum
my @Hblocks=();    # human blocks in order

# this gives orthologous blocks the same name
sub load_MH_blocks{
	# this is a zero-based file
	#open(INPUT, "../blocks_MH_300k1.txt") || die "cannot open ortho blocks file";
	# this is a one-based file; code changed to handle this case
	#open(INPUT, "../peaks3/blocks_MH3_300k_simulation.txt") || die "cannot open ortho blocks file";
	open(INPUT, "../peaks3/blocks_MH3_300k_simulation1based_1to1_final.txt") || die "cannot open ortho blocks file";
	# ignore the last column from file
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		$M2Hblocks{$data[0]} = $data[1]-1 ;
	}
}

sub load_Hblocks{
	my ($file) = @_;
	open(INPUT, $file)|| die "cannot open $file";
	@Hblocks = <INPUT>;
}

sub make_hg18_bed{
	print <<__track__;
browser full knownGene affyTxnPhase3Super wgEncodeYaleChIPseq encodeRna
browser dense wgRna rgdQtl jaxQtlMapped
browser squish chainMm9 encodeRegions tfbsConsSites
track name="HG18 zero gene" description="zero gene ceQTLs" visibility=2 db=hg18 useScore=1 color=255,0,0
__track__
	foreach my $mblock (sort {$a<=>$b} keys %M2Hblocks){
		my $id = $M2Hblocks{$mblock} 	;
		print $id,"\n";
		my @data =split(/\t/, $Hblocks[$id]);
		
		my $chrom = $data[1]; 
		if ($chrom == 23) { 
			$chrom = 'X' ;
		} elsif ($chrom == 24) {
			$chrom = 'Y';
		}
		$chrom =~ s/^/chr/;
		
		my $chromStart = $data[2];
		my $chromEnd = $data[5];
		my $name = $mblock;
		my $score = $data[7]*10;

		print join("\t", $chrom,$chromStart,$chromEnd,$name,$score),"\n";
	}
}

#given a blocks file, generate a BED file 
#file format: markerstart|chrom|start|markerend|chrom|end|dist|-logpval
# the name is the linenumber in the file 
sub make_hg18_bed_from_file{
	my $file = shift;
	print <<__track__;
browser full knownGene affyTxnPhase3Super wgEncodeYaleChIPseq encodeRna
browser dense wgRna rgdQtl jaxQtlMapped
browser squish chainMm9 encodeRegions tfbsConsSites
track name="HG18 zero gene" description="zero gene ceQTLs" visibility=2 db=hg18 useScore=1 color=255,0,0
__track__

	open(INPUT, $file) || die "cannot open blocks file";
	my $counter = 1;
	while(<INPUT>){
		my $chrom;
		next if /^#/; chomp;
		my @d= split(/\t/);
		#check on same chrom
		if ($d[1] == $d[4]){
			$chrom = $d[1];
			if ($chrom == 23){
				$chrom = 'X';
			} elsif ($chrom == 24){
				$chrom = 'Y';
			}
			$chrom =~ s/^/chr/;	
			my $name = $counter;
			my $score = $d[7] * 10;
			print join("\t",$chrom, $d[2],$d[5],$name, $score),"\n";
		} else {
			die "zero gene block spans multiple chromosomes";
		}
		$counter++;
	}
}
######## MAIN ##########
# Older code: gives each block the same name using MH block overlap
#load_MH_blocks();
##load_Hblocks("../zero_gene_peaks_ranges300k_size_pval.txt");
#load_Hblocks("../peaks3/zero_gene_peaks3_ranges300k_size_pval.txt");
#make_hg18_bed();


# just make the BED file from block file
make_hg18_bed_from_file("../peaks3/zero_gene_peaks3_ranges300k_size_pval.txt");
