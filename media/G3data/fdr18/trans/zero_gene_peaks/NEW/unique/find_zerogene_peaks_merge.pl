#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use lib '/home/rwang/lib';
use hummarkerpos;
use Math::Round;
#
# peak finding for zero-gene eqtls. Merge peaks that are spatially close together.
# this is different than peak finding for gene-eqtls


#marker genome coords
my %mgc=(); 

# build hash of cgh probe coordinates
sub load_hum_cgh_gc_coords{
	my $markerfile="/home3/rwang/QTL_comp/g3probe_gc_coords.txt";
	open (HANDLE, $markerfile) or die "cannot open $markerfile\n";
	my $index=1;
	while (<HANDLE>){
		chomp ;
		$mgc{$index}=$_;
		$index++;
	}
	close (HANDLE);
	#print Dumper(\%mgc);
}

# this uses Josh/Sangtae algorithm for peak finding peak. Starts with highest peak
# and finds peaks > RADIUS away. A better way to do group non-gene eqtls is
# using a different sub.
sub filter_hum_zerogene{
	# read in the sorted zero-gene eqtl file (already thresholded)
	# format: gene | marker | alpha | nlp
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/new/zero_gene_peaks_ucschg18_sortbypval2.txt")
		|| die "cannot open zero gene peaks\n";
	#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/new/t.in")
	#	|| die "cannot open zero gene peaks\n";
	my @bin=();
	my @alp=();
	my @nlp=();
	my @gene=();
	
	# read in first line and add to bin
	my $t = <INPUT>;
	chomp $t;
	my($gene, $marker, $alpha, $nlp) = split(/\t/,$t);
	push @bin, $marker;
	push @gene, $gene;
	push @alp, $alpha;
	push @nlp, $nlp;
	
	my $counter=0;
	# for each line of file
	while(<INPUT>){
		chomp;
		#print STDERR ++$counter,"\n";
		my($gene, $marker, $alpha, $nlp) = split(/\t/);
		my $flag=0;
		# check cur marker against all markers in bin; is it within RADIUS or
		# already within bin?
		foreach my $m (@bin){
			#print "testing marker=$marker with bin $m\t$mgc{$m}\n";
			#if a new 0-gene peak is more than 1MB away, add it to bin
			if (abs( $mgc{$m} - $mgc{$marker}) > 1000000 ){
				#print "flagging\n";
				$flag=1;
			} else {
				#print "less than radius\n";
				$flag=0;
				last;
			}
			# already in list?
			if ($marker == $m){
				#print "already in list\n";
				$flag =0;
				last;
			}
		}
		if ($flag){
			push @bin, $marker;
			push @gene, $gene;
			push @alp, $alpha;
			push @nlp, $nlp;
		}
	#print Dumper(\@bin);	
	#exit(1) if $counter==10;
	}
	# output the markers are RADIUS away
	for (my $i=0; $i<=$#bin; $i++){
		print "$gene[$i]\t$bin[$i]\t$alp[$i]\t$nlp[$i]\n";	
	}
}

# segment "groups" of zero gene markers based on distance
# between adjacent markers. ie if 2 markers are 1mb away,
# classify prev markers as one group and next set of markers
# as another group. below are two groups
#
#  m  m m <----- 1mb ------> m   m  m 
sub filter_hum_zerogene2{
	my ($radius) = @_;
	#read in file sorted by MARKER
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks_ucschg18_sortbymarker.txt")
		|| die "cannot open zero gene peaks2\n";

	my $prevmarker = 0;
	$_ = <INPUT>;
	$prevmarker = (split(/\t/, $_))[1];
	print_hum_pos($prevmarker, 't');
	# format: gene| marker| alpha | nlp
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		#only on same chrom	
		if ($hummarkerpos_by_index{$data[1]}{chrom} == $hummarkerpos_by_index{$prevmarker}{chrom}){
			if (abs($hummarkerpos_by_index{$data[1]}{start}-$hummarkerpos_by_index{$prevmarker}{start}) < $radius){
				$prevmarker = $data[1];
				next;
			} else {
				print_hum_pos($prevmarker, 'n');
				$prevmarker = $data[1];
				print_hum_pos($data[1], 't');
			}
		} else {
			print_hum_pos($prevmarker, 'n');
			$prevmarker = $data[1];
			print_hum_pos($data[1], 't');
		}
	}
	#output the last thing
	print_hum_pos($prevmarker, 'n');
}


# same as above, but takes a single-column file as input
sub filter_hum_zerogene3{
	my ($radius,$file) = @_;
	#read in file sorted by MARKER
	#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/simulation/zerocgh_refseq.txt")
	#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks2_ucschg18_markersonly.txt")
	#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks2_ucschg18_FDR30_markersonly.txt")
	#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks2_ucschg18_FDR20_markersonly.txt")
	#	|| die "cannot open zero gene peaks2\n";

	open(INPUT,$file) || die "cannot open zero gene peaks2\n";
	my $prevmarker = 0;
	$_ = <INPUT>;
	chomp $_;
	$prevmarker = $_;
	print_hum_pos($prevmarker, 't');
	# format: gene| marker| alpha | nlp
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
	
		#only on same chrom	
		if ($hummarkerpos_by_index{$data[0]}{chrom} == $hummarkerpos_by_index{$prevmarker}{chrom}){
			if (abs($hummarkerpos_by_index{$data[0]}{start}-$hummarkerpos_by_index{$prevmarker}{start}) < $radius){
				$prevmarker = $data[0];
				next;
			} else {
				print_hum_pos($prevmarker, 'n');
				$prevmarker = $data[0];
				print_hum_pos($data[0], 't');
			}
		} else {
			print_hum_pos($prevmarker, 'n');
			$prevmarker = $data[0];
			print_hum_pos($data[0], 't');
		}
	}
	#output the last thing
	print_hum_pos($prevmarker, 'n');
}

# utility to print out position
sub print_hum_pos{
	my ($marker, $nlswitch) = @_;
	print $marker,"\t";
	print $hummarkerpos_by_index{$marker}{chrom}, "\t";
	print $hummarkerpos_by_index{$marker}{pos} ;
	if ($nlswitch eq 'n'){
		print "\n";
	} else {
		print "\t";
	}
}

########### MOUSE ################################

# hold mouse markers
my %musmarker=();

sub print_mus_pos{
	my ($marker, $nlswitch) = @_;
	print $marker,"\t";
	print $musmarker{$marker}{chrom}, "\t";
	print $musmarker{$marker}{pos} ;
	if ($nlswitch eq 'n'){
		print "\n";
	} else {
		print "\t";
	}
}
# load mouse positions
sub load_mus_cgh_gc_coords{
	my $markerfile="/media/G3data/fdr18/trans/zero_gene_peaks/mouse/cgh_pos.txt";
	open (HANDLE, $markerfile) or die "cannot open $markerfile\n";
	my $index=1;
	while (<HANDLE>){
		chomp ;
		$mgc{$index}=$_;
		$index++;
	}
	close (HANDLE);
	#print Dumper(\%mgc);
}

# load mouse by index
sub load_mus_markerpos_by_index{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/mouse/unique/mouse_cgh_pos.txt")|| die "cannot open mus pos\n";
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		$musmarker{$data[3]}{chrom} = $data[0];
		$musmarker{$data[3]}{pos} = round(($data[1]+$data[2])/2);
	}
	#print Dumper(\%musmarker);
}

# filter based on highest peak. try next the zerogene2 function
sub filter_mus_zerogene{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/0_gene_300k_trans_4.0_sortbynlp2.txt")
	  || die "cannot open mouse 0-gene\n";
	my @bin=();
	my @alp=();
	my @nlp=();
	my @gene=();
	my $t=<INPUT>;
	chomp $t;
	my(undef, $gene, $marker, $alpha, $nlp) = split(/\t/,$t);
	push @bin, $marker;
	push @gene, $gene;
	push @alp, $alpha;
	push @nlp, $nlp;

	my $counter=0;
	# for each line of file
	while(<INPUT>){
		chomp;
		#print STDERR ++$counter,"\n";
		my(undef, $gene, $marker, $alpha, $nlp) = split(/\t/);
		my $flag=0;
		# check cur marker against all markers in bin; is it within RADIUS or
		# already within bin?
		foreach my $m (@bin){
			#print "testing marker=$marker with bin $m\t$mgc{$m}\n";
			#if a new 0-gene peak is more than 1MB away, add it to bin
			if (abs( $mgc{$m} - $mgc{$marker}) > 1000000 ){
				#print "flagging\n";
				$flag=1;
			} else {
				#print "less than radius\n";
				$flag=0;
				last;
			}
			# already in list?
			if ($marker == $m){
				#print "already in list\n";
				$flag =0;
				last;
			}
		}
		if ($flag){
			push @bin, $marker;
			push @gene, $gene;
			push @alp, $alpha;
			push @nlp, $nlp;
		}
	#print Dumper(\@bin);	
	#exit(1) if $counter==10;
	}
	# output the markers are RADIUS away
	for (my $i=0; $i<=$#bin; $i++){
		print "$gene[$i]\t$bin[$i]\t$alp[$i]\t$nlp[$i]\n";	
	}
}

# filter moue genes based on distance between adjacent markers
sub filter_mus_zerogene2{
	my ($radius) = @_;
	#read in file sorted by MARKER
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/uniq_markers300k_zerog_pos.txt")
		|| die "cannot open zero gene peaks2\n";

	my $prevmarker = 0;
	$_ = <INPUT>;
	chomp $_;
	$prevmarker = (split(/\t/, $_))[3];
	
	print_mus_pos($prevmarker, 't');
	# format: chrom| start| stop| 
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		#only on same chrom	
		if ($musmarker{$data[3]}{chrom} == $musmarker{$prevmarker}{chrom}){
			if (abs($musmarker{$data[3]}{pos}-$musmarker{$prevmarker}{pos}) < $radius){
				$prevmarker = $data[3];
				next;
			} else {
				print_mus_pos($prevmarker, 'n');
				$prevmarker = $data[3];
				print_mus_pos($data[3], 't');
			}
		} else {
			print_mus_pos($prevmarker, 'n');
			$prevmarker = $data[3];
			print_mus_pos($data[3], 't');
		}
	}
	#output the last thing
	print_mus_pos($prevmarker, 'n');
}

#uses just a single list of markerids
sub filter_mus_zerogene3{
	my ($radius, $file) = @_;
	#read in file sorted by MARKER
	#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/mouse/simulation/mouse_zero_gene_cgh_markers.txt")
	#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/mouse/uniq_markers300k_zerog_peak2_FDR30.txt")
	#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/mouse/uniq_markers300k_zerog_peak2_FDR10.txt")
	#	|| die "cannot open zero gene peaks2\n";
	open(INPUT, $file) || die "cannot open zero gene peaks2";

	my $prevmarker = 0;
	$_ = <INPUT>;
	chomp $_;
	$prevmarker = $_;
	
	print_mus_pos($prevmarker, 't');
	# format: chrom| start| stop| 
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		#only on same chrom	
		if ($musmarker{$data[0]}{chrom} == $musmarker{$prevmarker}{chrom}){
			if (abs($musmarker{$data[0]}{pos}-$musmarker{$prevmarker}{pos}) < $radius){
				$prevmarker = $data[0];
				next;
			} else {
				print_mus_pos($prevmarker, 'n');
				$prevmarker = $data[0];
				print_mus_pos($data[0], 't');
			}
		} else {
			print_mus_pos($prevmarker, 'n');
			$prevmarker = $data[0];
			print_mus_pos($data[0], 't');
		}
	}
	#output the last thing
	print_mus_pos($prevmarker, 'n');
}
####### MAIN ##########

# Uses peak-finding algorithm to mark no-gene blocks. not as good.
#human
#load_hum_cgh_gc_coords();
#filter_hum_zerogene();

#mouse
#load_mus_cgh_gc_coords();
#filter_mus_zerogene();

# 11/24/2008
# Uses adjacent marker distance to mark no-gene blocks. better.
# human
#load_markerpos_by_index("g3data");
# %hummarkerpos_by_index() created by perl module
#filter_hum_zerogene2(200000);
#filter_hum_zerogene2(200000);
# mouse
#load_mus_markerpos_by_index();
#filter_mus_zerogene2(1000000);

#12/4/2008
# cgh markers in desert regions
#load_markerpos_by_index("g3data");
#filter_hum_zerogene3(200000);
#
#12/9/2008
#load_markerpos_by_index("g3data");
#filter_hum_zerogene3(300000);
# mouse
#load_mus_markerpos_by_index();
#filter_mus_zerogene2(300000);

# 6/12/09 using "corrected" list of zerogene peaks, get a new list(peaks2)
# of zero gene blocks. Modified function to take filename as arg.
#load_markerpos_by_index("g3data");
#my $file = "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks2_ucschg18_FDR20_markersonly.txt";
#filter_hum_zerogene3(300000, $file);
load_markerpos_by_index("g3data");
#filter_hum_zerogene3(300000, $ARGV[0]);
filter_hum_zerogene3(500000, $ARGV[0]);

# mouse thresholded fdrs 30,20,10
#load_mus_markerpos_by_index();
#filter_mus_zerogene3(300000);
#load_mus_markerpos_by_index();
#filter_mus_zerogene3(300000, $ARGV[0]);
