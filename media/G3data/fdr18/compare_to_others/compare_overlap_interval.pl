#!/usr/bin/perl -w
#
# Brute force search for overlapping intervals such as 
# betweeen Lander lincRNAs and my human zero gene intervals
# or between Wolds ncRNAs and my zero genes

# a slick implemntation would use red-black trees but for the 
# small number of segments (i hope) brute force is fine.
#
# To count number of unique blocks, do cut -f2 <output> |sort -n|uniq | wc -l.
# To count number of unique lincRNA/etc, do cut -f4 <output> ...
#
# Reference organism is mouse or human zero gene blocks
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

# 9/15/2009 
#  added 300kb to start/stop of each zero gene block
#  to overlap_ref_comp()
# 9/17/2009 - added parameter for +300kb to overlap_ref_comp()
use strict;
use Data::Dumper;
use Carp;

# sort intervals on start, s1 is the smaller
sub overlap{
	my($s1low, $s1high, $s2low, $s2high) = @_;
	#an overlap must satisfy this constraint
	return 1 if ($s1low <= $s2high && $s2low <= $s1high);
}

# OBSOLETE - T31 mm7 0 gene blocks
sub load_mus_blocks{
	my $aref= shift;
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k.txt") || die "cannot open mouse blocks";
	my $counter=0;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		$aref->{$counter}{chrom} = $d[1];
		$aref->{$counter}{start} = $d[2];
		$aref->{$counter}{stop} = $d[5];
		$counter++;
	}
}

# GENERIC function to load (mouse/human data) block data
# pass in hash to fill, name of file, hash descript of file struct 
sub load_ref_blocks{
	my ($aref, $file, $filestruct) = @_;
	#open(INPUT, $file) || die "cannot open block file $file";
	open(INPUT, $file) || croak "cannot open block file $file";
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


# GENERIC LOAD DATA ROUTINE.
# data format MUST BE  chrom(noX,noY) | start | stop 
# for the first 3 columns
sub load_comp_data{
	my ($aref, $file)=@_;
	#open(INPUT, $file) || die "cannot open file";
	open(INPUT, $file) || croak "cannot open file";
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

#find closest
#based on start positions
#sub matchup{
#	my $aref= shift;
#	my $j;
#
#	#for each mouse block
#	foreach my $i (sort {$a<=>$b} keys %musblocks){
#		my %best=(dist=>100000000,index=>undef );
#
#		my $chr = $musblocks{$i}{chrom};
#		my $start = $musblocks{$i}{start};
#		my $stop = $musblocks{$i}{stop};
#
#		#search over all RNAFAR 
#		foreach my $j ($aref->{$chr}{start}){
#			for (my $i=0; $i< scalar @$j; $i++){
#				my $sdist = abs($j->[$i] - $start);
#				if ($sdist < $best{dist}){
#					$best{dist} = $sdist;
#					$best{index} = $i;
#				}
#			}
#		}
#		#mouse stuff
#		print join("\t", $chr, $start, $stop), "\t";
#		#rnafar stuff
#		print join("\t", $aref->{$chr}{start}[$best{index}], 
#											$aref->{$chr}{stop}[$best{index}]
#								), "\t";
#		print $best{dist},"\n";
#	}
#}

# GENERIC COMPARISON FUNCTION
# find interval overlap between reference (mouse zero gene, human zero gene)
# and comparison (wold, lincRNA)
# $ref = reference genome (mus mm7, hum)
# $comp = dataset to compare to (wold, lincRNA)
# 9/15/2009 - modification, adding 300kb to start/stop of zero gene blocks
# 9/17/2009 - made an parameter for the adding 300kb to start/stop
sub overlap_ref_comp{
	my ($ref, $comp, $flag300) = @_;
	#iter over reference (mouse/human zero) blocks 
	foreach my $i (sort {$a<=>$b} keys %$ref){
		my $chr = $ref->{$i}{chrom};
		my ($start,$stop);
		if (defined $flag300 && $flag300==1){
			$start = ($ref->{$i}{start}-300000 < 0) ? 0 : $ref->{$i}{start}-300000;
			$stop = $ref->{$i}{stop}+300000;
		} else {
			$start = $ref->{$i}{start};
			$stop = $ref->{$i}{stop};
		}

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

## human zero gene versus wold
## 9/11/2009
sub run_comp_hum_wold{
	my %rnafar=(); #comparison data saved here
	load_comp_data(\%rnafar, "wold/RNAFAR/mm9tohg18/RNAFAR_hg18.txt") ;
	my %ref=();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%ref,
	             "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_ranges300k.txt",
	             #"/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%rnafar,1);
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

# human zero gene versus liftover lincRNA
# 9/11/2009
sub run_comp_hum_lincRNA{
	my %lincRNA=();

	## use tiling array confirmed, LOD>2
	load_comp_data(\%lincRNA, "lander_linc/mm8tohg18/lincRNA_mm8tohg18_10.txt") ;

	my %ref=();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%ref,
	             "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_ranges300k.txt",
	             #"/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%lincRNA);	
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
	             "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_ranges300k.txt",
	             #"/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt",
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
	             "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_ranges300k.txt",
	             #"/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# test overlap of human zero genes (uncorrected) against microRNA
sub run_comp_hum_mirbase{
	my %comp=();
	#load_comp_data(\%comp, "./microRNA/mirbase_hsa_hg18.txt");
	load_comp_data(\%comp, "./microRNA/miRNA_hg18.txt");
	my %ref = ();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%ref,
	             "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_ranges300k.txt",
	             #"/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt",
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

# overlap of (overlap linc & hum ) & (overlap wold & hum)
sub run_lincRNAhum_Woldhum{
	my %comp = ();
	load_comp_data(\%comp, "./20090911humpeak3_lincRNA_overlap.txt");
	my %ref = ();
	my %filestruct=(startchrom=>0,startpos=>1,endpos=>2);
	load_ref_blocks(\%ref,
	             "./20090911humpeak3_wold_overlap.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# overlap of (overlap linc & hum ) & (overlap ultracons & hum)
sub run_lincRNAhum_ultraconshum{
	my %comp = ();
	load_comp_data(\%comp, "./20090911humpeak3_lincRNA_overlap.txt");
	my %ref = ();
	my %filestruct=(startchrom=>0,startpos=>1,endpos=>2);
	load_ref_blocks(\%ref,
	             "./20090810humpeak3_ultracons_overlap.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# overlap of (overlap wold & hum ) & (overlap ultracons & hum)
sub run_woldhum_ultraconshum{
	my %comp = ();
	load_comp_data(\%comp, "./20090911humpeak3_wold_overlap.txt");
	my %ref = ();
	my %filestruct=(startchrom=>0,startpos=>1,endpos=>2);
	load_ref_blocks(\%ref,
	             "./20090810humpeak3_ultracons_overlap.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# overlap of (overlap linchum & woldhum ) & (overlap linchum & ultraconshum)
sub run_lincRNAhum_Woldhum_lincRNAhum_ultraconshum{
	my %comp = ();
	load_comp_data(\%comp, "20090918linchum_woldhum_overlap.txt");
	my %ref = ();
	my %filestruct=(startchrom=>0,startpos=>1,endpos=>2);
	load_ref_blocks(\%ref,
							"./20090918linchum_ultraconshum_overlap.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# compare T31 with ultracons
sub run_comp_mus_ultraCons{
	my %comp=();
	load_comp_data(\%comp, "./ultraCons/hg17tomm7/ultra.mm7.txt");
	my %ref = ();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%ref,
								"/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k.txt", 
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# compare overlap (lincRNA & mus) & (ultracons & mus)
sub run_lincRNAmus_ultraConsmus{
	my %comp = ();
	load_comp_data(\%comp, "./20090330mus_lincRNA_overlap.txt");
	my %ref = ();
	my %filestruct=(startchrom=>0,startpos=>1,endpos=>2);
	load_ref_blocks(\%ref,
	             "./20090918mus_ultracons_overlap.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# overlap of (overlap wold & mus) & (overlap ultracons & mus)
sub run_woldmus_ultraconsmus{
	my %comp = ();
	load_comp_data(\%comp, "20090330mus_wold_overlap.txt");
	my %ref = ();
	my %filestruct=(startchrom=>0,startpos=>1,endpos=>2);
	load_ref_blocks(\%ref,
	             "./20090918mus_ultracons_overlap.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# overlap of (overlap lincmus & woldmus ) & (overlap lincmus & ultraconsmus)
sub run_lincRNAmus_Woldmus_lincRNAmus_ultraconsmus{
	my %comp = ();
	load_comp_data(\%comp, "20090403lincmus_woldmus_overlap.txt");
	my %ref = ();
	my %filestruct=(startchrom=>0,startpos=>1,endpos=>2);
	load_ref_blocks(\%ref,
							"./20090918lincmus_ultraconsmus_overlap.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# compare vista hum enhancer db against hum 0-gene blocks
sub run_comp_hum_vista{
	my %comp=();
	#load_comp_data(\%comp, "./vista/vista_colOrderhg18.txt"); 
	#extremeCons noncoding Gumby 2008 visel, they use R=50
	load_comp_data(\%comp, "./vista/extremeCons/h18_UL_R50.pbed.txt");
	my %ref = ();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%ref,
	             #"/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_ranges300k.txt",
	             "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_FDR30_ranges300k.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# compare renlab hum enhancer db against hum 0-gene blocks
sub run_comp_hum_ren{
	my %comp=();
	#load_comp_data(\%comp, "./vista/vista_colOrderhg18.txt"); 
	#extremeCons noncoding Gumby 2008 visel, they use R=50
	load_comp_data(\%comp, "./renlab/36589_enh_2500bp.txt");
	my %ref = ();
	my %filestruct=( startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%ref,
	             #"/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_ranges300k.txt",
	             "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_FDR30_ranges300k.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}
####### MAIN #############

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

## compare human 0-gene (uncorrected) versus microRNA
#run_comp_hum_mirbase();

## compare human 0-gene (peaks3) versus lincRNA
#run_comp_hum_lincRNA();

## compare human 0-gene (peaks3) versus Wold next gen
#run_comp_hum_wold();

## Using human domain compare to create pie graph of how many noncoding blocks are
#  explained by lincRNA, Wold and Ultracons
# -lincRNA & Wold
# -lincRNA & UltraCons
# -Wold & UltraCons
# Remeber we're using human blocks, so output are human 0-gene blocks
#run_lincRNAhum_Woldhum();
#run_lincRNAhum_ultraconshum();
#run_woldhum_ultraconshum();
#run_lincRNAhum_Woldhum_lincRNAhum_ultraconshum()

## Let's look at mouse and create same pie chart
#run_lincRNAmus_Woldmus(); # already done
#run_comp_mus_ultraCons();
#run_lincRNAmus_ultraConsmus();
#run_woldmus_ultraconsmus();
#run_lincRNAmus_Woldmus_lincRNAmus_ultraconsmus()

## Compare vista hum enhancer against human 0-gene blocks
run_comp_hum_vista();
#run_comp_hum_ren();
