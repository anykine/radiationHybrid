#!/usr/bin/perl -w
use strict;

unless (@ARGV == 1){
	print <<EOH;
	usage: $0 <thresholded file>
		ex $0 nlps_and_alphas_gt3.99.txt";
	
	Find the number of trans peaks for every gene.
	Since there were so many trans, I broke the trans into 4 files
	and called this script on each file, hence it takes ARGV as input.
EOH
exit(1);
}

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
my $genefile="/home3/rwang/QTL_comp/g3gene_gc_coords.txt";
my %pgc=(); 
open (HANDLE, $genefile) or die "cannot open $genefile\n";
$index=1;
while (<HANDLE>){
	chomp ;
	$pgc{$index}=$_;
	$index++;
}
close (HANDLE);



# read in list of gene marker pairs and nlps that have been selected b y FDR critera (q<0.2) 
my %gash=();
#my $nlps_past_thresh="/home3/rwang/QTL_comp/output1/g3alpha_model_results1_trans.txt";
#my $nlps_past_thresh="/media/G3data/fdr/trans/g3alpha_model_results1_gt2.4trans_pt1.txt";
my $nlps_past_thresh=$ARGV[0];
open (HANDLE, $nlps_past_thresh) or die "cannot open $nlps_past_thresh\n";
while (<HANDLE>) {
	chomp ;
	my($geneid, $marker,undef, $alpha, $nlp) = split ("\t", $_);
	
	#define my threshold
	if ($nlp >= 8.46 || $nlp eq "inf"){
	#if ($nlp >= 3.20 || $nlp eq "inf"){
		push @{$gash{$geneid}{marker}}, $marker;
		push @{$gash{$geneid}{alpha}}, $alpha;
		push @{$gash{$geneid}{nlp}}, $nlp;
	}
}
close (HANDLE);



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


#=cut

=comment
#for cis
foreach $gene (sort { $a<=> $b} keys %gash ) {

	@indexarray=();
	$mc = scalar @{$gash{$gene}{marker}};
	for ($i=0; $i<$mc; $i++) { $indexarray[$i]=$i; }

	# special sort to return indices of sorted array in descending order 
	@nlpsortindex= sort { ${$gash{$gene}{nlp}}[$b] <=> ${$gash{$gene}{nlp}}[$a]} @indexarray;
	
		$peakmarker=0;
		$peaknlp=0;
		$peakalpha=0;

	foreach $idx (@nlpsortindex) {
	
		#if potential peak marker is with 10mb of regulated gene then probable cis
 		if ( abs($mgc{${$gash{$gene}{marker}}[$idx]}-$pgc{$gene})<10000000) {
			if (  ${$gash{$gene}{nlp}}[$idx] > $peaknlp ) { 
					$peakmarker= ${$gash{$gene}{marker}}[$idx];
					$peaknlp=${$gash{$gene}{nlp}}[$idx]; 
					$peakalpha=${$gash{$gene}{alpha}}[$idx]; 
			}
		}
	}
		print $gene.$t.$peakmarker.$t.$peakalpha.$t.$peaknlp.$n;
}

=cut
