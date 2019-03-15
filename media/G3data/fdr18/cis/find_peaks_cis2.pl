#!/usr/bin/perl -w
use strict;
use Data::Dumper;

# this used to be called find_peaks_and_cis.pl
# several version of file exist; useful for 
# 1) finding trans peaks (for each gene, get peak marker, peak alpha...)
# 2) finding cis peak
# 3) making sure peaks are > 5MB away
# You need to specify the FDR value
# 8/31/10 - changed radius to 2mb
unless (@ARGV == 2){
	print <<EOH;
	usage: $0 <thresholded file> <pval threshold>
		ex $0 g3alpha_model_results1_cis.txt 0.75;
	
	For CIS, find the max gene-marker pair for every gene
	which is equivalent to determining number of peaks
EOH
exit(1);
}

my $fdr_thresh = $ARGV[1];
# build hash of cgh probe coordinates
my $markerfile="/home3/rwang/QTL_comp/g3probe_gc_coords.txt";
my %mgc=(); 
open (HANDLE, $markerfile) or die "cannot open $markerfile\n";
my $index=1;
while (<HANDLE>){
	chomp ;
	$mgc{$index}=$_;
	$index++;
}
close (HANDLE);

#build hash of gene coordinates
#my $genefile="/home3/rwang/QTL_comp/g3gene_gc_coords.txt";
my $genefile="/home3/rwang/QTL_comp/g3gene_gc_coordshg18.txt";
my %pgc=(); 
open (HANDLE, $genefile) or die "cannot open $genefile\n";
$index=1;
while (<HANDLE>){
	chomp ;
	$pgc{$index}=$_;
	$index++;
}
close (HANDLE);



# read in list of gene marker pairs and nlps that have been selected by FDR critera (q<0.2) 
# expects data: gene | marker | mu | alpha | -logp
my %gash=();
#my $nlps_past_thresh="/home3/rwang/QTL_comp/output1/g3alpha_model_results1_trans.txt";
#my $nlps_past_thresh="/media/G3data/fdr/trans/g3alpha_model_results1_gt2.4trans_pt1.txt";
my $nlps_past_thresh=$ARGV[0];
open (HANDLE, $nlps_past_thresh) or die "cannot open $nlps_past_thresh\n";
while (<HANDLE>) {
	chomp ;
	my($geneid, $marker,undef, $alpha, $nlp) = split ("\t", $_);
	
	#define my threshold for FDR40
	#if ($nlp >= 0.75 || $nlp eq "inf"){
	if ($nlp >= $fdr_thresh || $nlp eq "inf"){
		push @{$gash{$geneid}{marker}}, $marker;
		push @{$gash{$geneid}{alpha}}, $alpha;
		push @{$gash{$geneid}{nlp}}, $nlp;
	}
}
close (HANDLE);


=comment
# code for trans
# now find peaks for each gene
foreach my $gene (sort { $a<=> $b} keys %gash ) {

	my @indexarray=();
	my $mc = scalar @{$gash{$gene}{marker}};
	for (my $i=0; $i<$mc; $i++) { $indexarray[$i]=$i; }

	# special sort to return indices of sorted array in descending order 
	my @nlpsortindex = sort { ${$gash{$gene}{nlp}}[$b] <=> ${$gash{$gene}{nlp}}[$a]} @indexarray;
	
	my @bin=();
	my @nlp=();
	my @alp=();
	foreach my $idx (@nlpsortindex) {
		my $flag=0;
		
		#if potential peak marker is with 10mb of regulated gene then don't bother working with it
 		unless ( abs($mgc{${$gash{$gene}{marker}}[$idx]}-$pgc{$gene})<5000000) {
		
			# if a potential peak marker is not within 10mb of regulated gene and is within 10mb of a
			# previously found peak marker then don't bother adding it to 
			foreach my $peak (@bin) {
				# if a marker is neither within ten mb of a flagged peak  nor a cis then flag it as a peak
				if( abs($mgc{${$gash{$gene}{marker}}[$idx]}-$mgc{$peak})<10000000 ) {
					$flag++;
				}
			}

			if ($flag>0) { 
				#do nothing if less than min_dist
			} else { 
				push @bin, ${$gash{$gene}{marker}}[$idx];
				push @nlp, ${$gash{$gene}{nlp}}[$idx];
				push @alp, ${$gash{$gene}{alpha}}[$idx];
			}
		}
	}

	my $peakcnt=scalar @bin;
	
	for (my $i=0; $i<$peakcnt; $i++ ){
		print "$gene\t$bin[$i]\t$alp[$i]\t$nlp[$i]\n";
	}
}


=cut

#=comment
#for cis
# sort by gene ID, for every gene, find max cis nlp marker
foreach my $gene (sort { $a<=> $b} keys %gash ) {

	my @indexarray=();
	
	my $mc = scalar @{$gash{$gene}{marker}};
	for (my $i=0; $i<$mc; $i++) { $indexarray[$i]=$i; }

	# special sort to return indices of sorted array in descending order 
	my @nlpsortindex= sort { ${$gash{$gene}{nlp}}[$b] <=> ${$gash{$gene}{nlp}}[$a]} @indexarray;
	
	my	$peakmarker=0;
	my	$peaknlp=0;
	my	$peakalpha=0;

	# for every marker, starting with the highest nlp
	foreach my $idx (@nlpsortindex) {
	
		#if potential peak marker is with 5mb of regulated gene then probable cis
 		if ( abs($mgc{${$gash{$gene}{marker}}[$idx]}-$pgc{$gene})<2000000) {
			if (  ${$gash{$gene}{nlp}}[$idx] > $peaknlp ) { 
					$peakmarker = ${$gash{$gene}{marker}}[$idx];
					$peaknlp =${$gash{$gene}{nlp}}[$idx]; 
					$peakalpha =${$gash{$gene}{alpha}}[$idx]; 
			}
		}
	}
	# some genes do not have a regulating marker above threshold
	if ($peakmarker != 0 && $peaknlp !=0 && $peakalpha !=0){
	print "$gene\t$peakmarker\t$peakalpha\t$peaknlp\n";
	}
}

