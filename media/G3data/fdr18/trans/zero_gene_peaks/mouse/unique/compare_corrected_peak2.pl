#!/usr/bin/perl -w
#
# Modified to search for differences between "corrected" zero gene blocks
# and "corrected" zero gene regions (deserts)
#
# These use markers instead of positions, but algorithm should work.
#
# a slick implemntation would use red-black trees but for the 
# small number of segments (i hope) brute force is fine.

# Reference organism is mouse or human zero gene blocks, key is blocknum
#    %hash={ 
#    			 0=>{ chrom=>1 , start=>100 , stop=>200},
#          1=>{ chrom=>1, start=>150000, stop=>200000}
#          100=>{ chrom=>9 , start=>100 , stop=>200}
#          }
#
# Comp organism is external dataset lincRNA, Wold next gen sequencing
# 	%hash={
#				1={start=array(1, 24, 100...),
#				   stop = array(10, 35, 150..),
#					},
#				23={start=array(),
#					 stop = array(),
#					}
# 	}

use strict;
use Data::Dumper;
use Carp;

# sort intervals on start, s1 is the smaller
sub overlap{
	my($s1low, $s1high, $s2low, $s2high) = @_;
	#an overlap must satisfy this constraint
	return 1 if ($s1low <= $s2high && $s2low <= $s1high);
}

# GENERIC function to load (mouse/human data) block data
# pass in hash to fill, name of file, hash descript of file struct 
sub load_ref_blocks{
	my ($aref, $file, $filestruct) = @_;
	open(INPUT, $file) || die "cannot open block file $file";
	my $counter=0;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		$aref->{$counter}{chrom} = $d[$filestruct->{startchrom}];
		$aref->{$counter}{start} = $d[$filestruct->{startpos}];
		$aref->{$counter}{stop} = $d[$filestruct->{endpos}];
		$counter++;
	}
}

# GENERIC function to load (mouse/human data) block data
# pass in hash to fill, name of file, hash descript of file struct 
# Takes marker number, not base pair position
sub load_ref_blocks2{
	my ($aref, $file, $filestruct) = @_;
	open(INPUT, $file) || die "cannot open block file $file";
	my $counter=0;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		$aref->{$counter}{chrom} = $d[$filestruct->{startchrom}];
		$aref->{$counter}{start} = $d[$filestruct->{startmarker}];
		$aref->{$counter}{stop} = $d[$filestruct->{endmarker}];
		$counter++;
	}
}

# GENERIC LOAD DATA ROUTINE.
# data format MUST BE  chrom(noX,noY) | start | stop
sub load_comp_data{
	my ($aref, $file)=@_;
	open(INPUT, $file) || die "cannot open file";
	my $counter=0;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		push @{$aref->{$d[0]}{start}}, $d[1];
		push @{$aref->{$d[0]}{stop}}, $d[2];
		push @{$aref->{$d[0]}{index}}, $counter++;
	}
	close(INPUT);
}


# GENERIC LOAD DATA ROUTINE.
# data format MUST BE markersstart|chrom|pos|markerend|chrom|pos
# here, start/stop are markers not basepair positions
sub load_comp_data2{
	my ($aref, $file)=@_;
	open(INPUT, $file) || die "cannot open file";
	my $counter=0;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		push @{$aref->{$d[1]}{start}}, $d[0];
		push @{$aref->{$d[1]}{stop}}, $d[3];
		push @{$aref->{$d[1]}{index}}, $counter++;
	}
	close(INPUT);
}

# GENERIC COMPARISON FUNCTION
# find interval overlap between reference (mouse zero gene, human zero gene)
# and comparison (wold, lincRNA)
# $ref = reference genome (mus mm7, hum)
# $comp = dataset to compare to (wold, lincRNA)
sub overlap_ref_comp{
	my ($ref, $comp) = @_;
	#iter over reference (mouse/human zero) blocks 
	foreach my $i (sort {$a<=>$b} keys %$ref){
		my $chr = $ref->{$i}{chrom};
		my $start = $ref->{$i}{start};
		my $stop = $ref->{$i}{stop};

		my $res = 999;
		#search over all comparison data (RNAFAR/lincRNA) on this chrom
		next if (!defined $comp->{$chr});
		for (my $j=0; $j < scalar @{$comp->{$chr}{start}}; $j++){

			#pass in intervals sorted on start key to overlap()
			if ($comp->{$chr}{start}[$j] < $start) {
				$res = overlap($comp->{$chr}{start}[$j],
								$comp->{$chr}{stop}[$j],
								$start,
								$stop);
			} else {
				$res = overlap($start,
								$stop,
								$comp->{$chr}{start}[$j],
								$comp->{$chr}{stop}[$j]);
			}
			if ($res){
				# print reference data
				print join("\t", $chr, $start,$stop),"\t";
				# print comparison data
				print join("\t", $comp->{$chr}{start}[$j],
													$comp->{$chr}{stop}[$j]), "\n";
			}
			$res = 999;
		}
	}
}

# comparison function, modified output for markers, not basepairs
sub overlap_ref_comp2{
	my ($ref, $comp) = @_;
	#iter over reference (mouse/human zero) blocks 
	foreach my $i (sort {$a<=>$b} keys %$ref){
		my $chr = $ref->{$i}{chrom};
		my $start = $ref->{$i}{start};
		my $stop = $ref->{$i}{stop};

		my $res = 999;
		#search over all comparison data (RNAFAR/lincRNA) on this chrom
		next if (!defined $comp->{$chr});
		for (my $j=0; $j < scalar @{$comp->{$chr}{start}}; $j++){

			#pass in intervals sorted on start key to overlap()
			if ($comp->{$chr}{start}[$j] < $start) {
				$res = overlap($comp->{$chr}{start}[$j],
								$comp->{$chr}{stop}[$j],
								$start,
								$stop);
			} else {
				$res = overlap($start,
								$stop,
								$comp->{$chr}{start}[$j],
								$comp->{$chr}{stop}[$j]);
			}
			if ($res){
				# print reference data
				print join("\t", $chr, $start,$stop),"\t";
				print " --- ";
				# print comparison data
				print join("\t", $comp->{$chr}{start}[$j],
													$comp->{$chr}{stop}[$j]), "\n";
			}
			$res = 999;
		}
	}
}
## t31 zero gene versus wold next gen seq
sub run_comp_mus_wold{
	my %rnafar=(); #comparison data saved here
	load_comp_data(\%rnafar, "wold/RNAFAR/mm9tomm7/RNAFAR_mm7.txt") ;
	my %musblocks=();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%musblocks,
								"/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k.txt", 
							 \%filestruct);
	overlap_ref_comp(\%musblocks, \%rnafar);
}

## t31 zero gene versus lander linc
sub run_comp_mus_lincRNA{
	my %lincRNA=();

	## use tiling array confirmed, LOD>2
	load_comp_data(\%lincRNA, "lander_linc/mm8tomm7/table2.gt2.mm7.txt") ;
	## use tiling array confirmed, top70 (aobut 850 regions)
	#load_comp_data(\%lincRNA, "lander_linc/mm8tomm7/table2.top70pct.mm7.txt") ;
	## use raw k4-k36
	#load_comp_data(\%lincRNA, "lander_linc/mm8tomm7/lincRNA_mm8tomm7_95.txt") ;

	my %musblocks=();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%musblocks,
								"/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k.txt", 
							 \%filestruct);
	overlap_ref_comp(\%musblocks, \%lincRNA);	
}

## t31 versus ucsc microRNA track
sub run_comp_mus_miRNA{
	my %miRNA=();
	load_comp_data(\%miRNA, "./microRNA/miRNA_mm7a.txt");
	my %musblocks=();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%musblocks,
								"/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k.txt", 
							 \%filestruct);
	overlap_ref_comp(\%musblocks, \%miRNA);
}

## t31 versus mirBase
sub run_comp_mus_mirbase{
	my %mirbase=();
	load_comp_data(\%mirbase, "./microRNA/mirbase_mmu_mm7.txt");
	my %musblocks=();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%musblocks,
								"/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k.txt", 
							 \%filestruct);
	overlap_ref_comp(\%musblocks, \%mirbase);
}

# lincRNA versus Wold next gen sequencing
sub run_comp_rnafar_lincRNA{
	# comp = Wold data
	my %comp=();
	load_comp_data(\%comp, "./wold/RNAFAR/mm9tomm7/RNAFAR_mm7.txt");
	# ref= lincRNA
	my %ref=();
	my %filestruct=(startchrom=>0,startpos=>1,endpos=>2);
	load_ref_blocks(\%ref,
	             "./lander_linc/mm8tomm7/lincRNA_mm8tomm7_95.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# lincRNA-mus versus Wold-mus
# look at output of overlaps with t31 to see if there is intersection
# note: i'm using mus 0gene coords
sub run_lincRNAmus_Woldmus{
	my %comp = ();
	load_comp_data(\%comp, "./20090330mus_wold_overlap.txt");
	my %ref = ();
	my %filestruct=(startchrom=>0,startpos=>1,endpos=>2);
	load_ref_blocks(\%ref,
	             "./20090330mus_lincRNA_overlap.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# are David Haussler's ultra conserved regions overlapping
# with human zero gene regions
sub run_comp_hum_ultraCons{
	my %comp=();
	load_comp_data(\%comp, "./ultraCons/ultra.hg18.txt");
	my %ref = ();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%ref,
	             "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# are those SVM predicted microRNAs in human zero gene regions?
sub run_comp_hum_svmmicroRNA{
	my %comp=();
	load_comp_data(\%comp, "./svmmicroRNA/human_candidate_premiRNA_hg18.txt");
	my %ref = ();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%ref,
	             "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# does mus2hum liftover zerogene overlap with human zero gene?
# ref=human, comp=mus2hum
sub run_comp_m2h_hum{
	my %comp=();
	load_comp_data(\%comp, "/media/G3data/mm7tohg18/markers/liftover10ranges300k/mm7tohg18web_zero_peak_ranges300k.txt");
	my %ref = ();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%ref,
	             "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# compare hum zero gene blocks (corrected) with 
# hum zero gene regions (deserts, corrected)
sub run_comp_corrected_peaks2{
	my %comp=();
	# corrected zero gene blocks
	#load_comp_data2(\%comp, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks2_ranges300k.txt");
	#load_comp_data2(\%comp, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks2_FDR30_ranges300k.txt");
	load_comp_data2(\%comp, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks2_FDR20_ranges300k.txt");
	my %ref=();
	my %filestruct=( startmarker=>0,startchrom=>1,
	   startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	# gene deserts
	load_ref_blocks2(\%ref,
		"/media/G3data/fdr18/trans/zero_gene_peaks/NEW/simulation/zero_gene_cgh_ranges300kb.txt",
		\%filestruct);
	overlap_ref_comp2(\%ref, \%comp);

}
# mouse
sub run_comp_corrected_peaks2mus{
	my ($file) = @_;
	my %comp=();
	# corrected zero gene blocks
	#load_comp_data2(\%comp, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks2_ranges300k.txt");
	load_comp_data2(\%comp, $file) || die "cannot open mouse peaks2 ranges file";
	#load_comp_data2(\%comp, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks2_ranges300k_FDR30.txt");
	#load_comp_data2(\%comp, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks2_ranges300k_FDR20.txt");
	#load_comp_data2(\%comp, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks2_ranges300k_FDR10.txt");
	my %ref=();
	my %filestruct=( startmarker=>0,startchrom=>1,
	   startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	# gene deserts
	load_ref_blocks2(\%ref,
		"/media/G3data/fdr18/trans/zero_gene_peaks/mouse/simulation/mouse_zero_gene_cgh_markers_ranges300kb.txt",
		\%filestruct);
	overlap_ref_comp2(\%ref, \%comp);

}
####### MAIN #############

# 6/15/09
# check if human zero-gene-blocks(corrected) overlap with 
# zero-gene-markers(deserts).
#run_comp_corrected_peaks2();

# mouse
#run_comp_corrected_peaks2mus();
run_comp_corrected_peaks2mus($ARGV[0]);

## compare wold sequencing to mus 0gene
#run_comp_mus_wold();

## compare lander lincRNA to mus 0gene
#run_comp_mus_lincRNA();

## compare mouse to human

## compare mouse microRNA to mus 0gene
#run_comp_mus_miRNA();
#run_comp_mus_mirbase();

## compare lincRNA to Wold next gen seq in mouse
#run_comp_rnafar_lincRNA();

## compare lincRNA-mus versus Wold-mus for overlap
#run_lincRNAmus_Woldmus();

## compare human 0-gene versus hassuler ultraCons overlap 
#run_comp_hum_ultraCons(); 

## compare mus->hum 0gene versus hum 0gene
#run_comp_m2h_hum();

## compare human 0-gene versus SVM predicted microRNA
#run_comp_hum_svmmicroRNA();
