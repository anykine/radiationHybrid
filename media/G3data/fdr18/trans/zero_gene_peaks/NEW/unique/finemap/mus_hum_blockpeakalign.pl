#!/usr/bin/perl -w
#
# Fine map of the zero gene eqtls
#
# Find the peak marker in mouse and human zero gene blocks
# Look at distribution of distanes between human/mouse blocks (using LiftOver)
#
# Takes as input the human and mouse zero gene ranges file and the -logp vals file.
# 1/5/2009
# Adapted this code to find the peak in each block of zero-gene markers
# in mouse and human. Then calc the distance between the peaks in each
# block. Assess significance of the matching block-peaks by permutation.

# 3/24/09 - moved load_M2H_markers to OLD_load_M2H_markers
# 				- updated load_M2Hmarkers to use hum2mus_closests (or nonimputed version)

use strict;
use Data::Dumper;
use Devel::Size qw(size total_size);
use lib '/home/rwang/lib';
use hummarkerpos;

my @mus_block=();
my %mus_pvals=();

my @hum_block=();
my %hum_pvals=();

my %M2Hblocks=(); #matching blocks
my %hum_pos=();   #human positions

#store mouse->hum marker mapping
my %markersM2H=();
my %commongeneM2H=();
my %commongeneH2M=();

# constants
use constant INF => 1000000000;

#####################################
# MOUSE routines
#####################################

#store mouse blocks : AoH
sub load_mus_blocks{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k.txt") || die "cannot open mus block";
	my $count=0;
	while(<INPUT>){
		my @data = split(/\t/);
		$mus_block[$count++] = {
			markerstart => $data[0],
			markerend  => $data[3],
			markerpeak => undef 
		}
	}
	close(INPUT);
}

# store the max zero gene eqtl peak markers, by -logp
sub load_mus_pvals{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/0_gene_300k_trans_4.0.txt")||die "cannot open peaks file";
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		if (defined $mus_pvals{$data[2]} ) {
			$mus_pvals{$data[2]} = $data[4] if $data[4] > $mus_pvals{$data[2]};
		} else {
			$mus_pvals{$data[2]} = $data[4];
		}
	}
}

# find the highest peak markers in each block;
sub find_mus_peak_per_block{
	my ($arg) = shift;
	foreach my $k ( @mus_block) {
		#print $k->{markerstart}, "\t";
		#print $k->{markerend}, "\n";

		for (my $i=$k->{markerstart}; $i <= $k->{markerend}; $i++){
			if (defined $k->{markerpeak}){
				$k->{markerpeak} = $i if (defined $mus_pvals{$i}) && $mus_pvals{$i} > $mus_pvals{$k->{markerpeak}};
			} else {
				$k->{markerpeak} = $i;
			}
		}
		if (defined $arg && $arg eq 'write'){
			#let's print out the mouse block w/ new column for peak marker
			print join("\t", $k->{markerstart}, $k->{markerend}, $k->{markerpeak}),"\n";
		}
	}
}

#####################################
# HUMAN routines
#####################################
sub load_hum_blocks{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt") || die "cannot open mus block";
	my $count=0;
	while(<INPUT>){
		my @data = split(/\t/);
		$hum_block[$count++] = {
			markerstart => $data[0],
			markerend  => $data[3],
			markerpeak => undef 
		}
	}
	close(INPUT);
}

sub load_hum_pvals{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks_ucschg18.txt")||die "cannot open peaks file";
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		if (defined $hum_pvals{$data[1]} ) {
			$hum_pvals{$data[1]} = $data[3] if $data[3] > $hum_pvals{$data[1]};
		} else {
			$hum_pvals{$data[1]} = $data[3];
		}
	}
}
sub find_hum_peak_per_block{
	my ($arg) = shift;
	foreach my $k ( @hum_block) {
		my $maxpeak=0;
		for (my $i=$k->{markerstart}; $i <= $k->{markerend}; $i++){
			if (defined $k->{markerpeak}){
				$k->{markerpeak} = $i if (defined $hum_pvals{$i}) && $hum_pvals{$i} > $hum_pvals{$k->{markerpeak}};
			} else {
				$k->{markerpeak} = $i;
			}
		}
		#write to file
		if (defined $arg && $arg eq 'write'){
			print join("\t", $k->{markerstart}, $k->{markerend}, $k->{markerpeak}), "\n";
		}
	}
}

# these are the matching blocks M to H at 300k
sub load_matching_blocks{
	my ($arg) = shift;
	my %H2Mblocks=();
	# mouse | human | dist
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/blocks_MH_300k1.txt") || die "cannot open matching blocks";
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		# should i remove multiple mappings mus->hum?
		$M2Hblocks{$data[0]} = $data[1];
	}
	#cheat to get unique mappings m2h
	if ( defined $arg && $arg eq 'unique'){
		%H2Mblocks = map {$M2Hblocks{$_}, $_} (keys %M2Hblocks);
		%M2Hblocks = map {$H2Mblocks{$_}, $_} (keys %H2Mblocks);
	}
}

# try and match highest peak marker between human/mouse ortho blocks
sub peakalign{
	# blocks are numbered 0...n-1
	# for every ortholog block
	foreach my $mblock (sort{$a<=>$b} keys %M2Hblocks){
		my $mpeak = $mus_block[$mblock]{markerpeak};
		my $hpeak = $hum_block[$M2Hblocks{$mblock}]{markerpeak};
	
		if (defined $markersM2H{$mpeak} ) {
			my $m2hpeak = $markersM2H{$mpeak};
			if (defined $hum_pos{$m2hpeak}){
				#get dist, subtract
				my @m2hpos = split(/\t/, $hum_pos{$m2hpeak});
				my @hpos = split(/\t/, $hum_pos{$hpeak});
				my $diff = $hpos[1] - $m2hpos[1];
				print "mus=$mpeak\thum=$hpeak\t";
				print $diff,"\n";
			} else {
				print "no pos for this marker mouse $mpeak trans $m2hpeak\n";
			}
		} else {
			print "mouse peak $mpeak has no matching human peak\n";
		}
	}
}

# peakalign() uses human 0-gene positions, let's try using all marker positions
# using database g3data hummarkerpos
sub peakalign2{

	foreach my $mblock (sort{$a<=>$b} keys %M2Hblocks){
		my $mpeak = $mus_block[$mblock]{markerpeak};
		my $hpeak = $hum_block[$M2Hblocks{$mblock}]{markerpeak};
	
		if (defined $markersM2H{$mpeak} ) {
			my $m2hpeak = $markersM2H{$mpeak};
			if (defined $hummarkerpos_by_index{$m2hpeak}){
				#check the chrom is the same
				if ($hummarkerpos_by_index{$m2hpeak}{chrom} == $hummarkerpos_by_index{$hpeak}{chrom}){
					my $hpos = $hummarkerpos_by_index{$hpeak}{start};
					my $m2hpos = $hummarkerpos_by_index{$m2hpeak}{start};
					my $diff = $hpos - $m2hpos;
					print "mus=$mpeak($mblock)\thum=$hpeak($M2Hblocks{$mblock})\t";
					print $diff,"\n";
				}
				#get dist, subtract
				#my @m2hpos = split(/\t/, $hum_pos{$m2hpeak});
				#my @hpos = split(/\t/, $hum_pos{$hpeak});
				#my $diff = $hpos[1] - $m2hpos[1];
				#print "mus=$mpeak\thum=$hpeak\t";
				#print $diff,"\n";
				} else {
					#print "no pos for this marker mouse $mpeak trans $m2hpeak\n";
				}
			} else {
				#print "mouse peak $mpeak has no matching human peak\n";
			}
	}
}

# get the position of all human zero gene peaks
sub load_hum_zgmarker_pos{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/uniq_markers300k_zerog_pos.txt") || die "cannot open human zero gene pos";
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		$hum_pos{$data[3]} = join("\t", @data[0,1,2]);
	}
}

# this is the Liftover10 mus2hum marker equivalents (closest hum marker
# for mus marker)
# many mus markers map to the same hum markers
sub OLD_load_M2H_markers{
	open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/mus2human_closest.txt")
	#open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/mus2human_noimpute_closest.txt")
	  || die "cannot open mus2hum markers\n";
	#format: converted_mus_chr/start/stop|musID | hum pos|hum id
	while(<INPUT>){
		chomp;
		my @line = split(/\t/);
		$markersM2H{$line[3]} = $line[5];
	}
}

# this is the liftover mouse:human equiv markers
# using imputed or nonimputed data
sub load_M2H_markers{
	open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/hum2mus_noimpute_closest_uniq.txt");
	%markersM2H = map{chomp; (split(/\t/))[1], (split(/\t/))[0]} <INPUT>;
	#print Dumper(\%h);
}

#for debugging
sub print_data_sizes{
	print "-----------\n";
	print total_size(\@mus_block), "\n";
	print total_size(\%mus_pvals), "\n";
	print total_size(\@hum_block), "\n";
	print total_size(\%hum_pvals), "\n";
	print total_size(\%M2Hblocks), "\n"; #matching blocks
	print total_size(\%hum_pos), "\n";   #human positions
	print "-----------\n";
}

sub init{
	load_markerpos_by_index("g3data");
	#print Dumper(\%hummarkerpos_by_index);
}

########## MAIN #############
init();
load_M2H_markers();
load_mus_blocks();
load_mus_pvals();
# can pass 'write'
find_mus_peak_per_block();
load_hum_blocks();
load_hum_pvals();
# can pass 'write'
find_hum_peak_per_block();
# can pass 'unique'
load_matching_blocks('unique');
load_hum_zgmarker_pos();
peakalign2();

exit(1);
