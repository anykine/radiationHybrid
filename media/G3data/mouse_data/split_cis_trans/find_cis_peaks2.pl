#!/usr/bin/perl -w
use strict;
use Math::Round;
use Data::Dumper;

# 10/17/2008 
# peak finder for cis, run on mouse data
# modified by Richard for reanalysis mouse
# radius 10MB
#

open (OUTFILE, ">mouse_all_cis_peaks.txt") || die "cannot open output\n";

my %mgc=(); 
# build hash of marker genome coordinates
sub load_mouse_marker_pos{
	my $index=1;
	# genome coords
	open (MARKERFILE, "../index/marker_gc_coords.txt") or die "cannot open marker file\n";
	# chrom/start/stop coords
	#open (MARKERFILE, "mouse_cgh_pos.txt") or die "cannot open marker file\n";
	while (<MARKERFILE>){
		chomp ;
		my @data = split(/\t/);
#		$mgc{$data[0]}{chr} =$data[1];
#		$mgc{$data[0]}{pos} = round(($data[2]+$data[3])/2);
		$mgc{$index++} = $data[0];
	}
	close (MARKERFILE);
}

#build hash of probe genome coordinates
my %pgc=();
sub load_mouse_gene_pos{
	my $index=1;
	open (PROBEFILE, "../index/probe_gc_coords.txt") or die "cannot open probe file\n";
	#open (PROBEFILE, "mouse_probe_pos.txt") or die "cannot open probe file\n";
	while (<PROBEFILE>){
		chomp ;
		my @data = split(/\t/);
#		$pgc{$data[0]}{chr} =$data[1];
#		$pgc{$data[0]}{pos} =round(($data[2]+$data[3])/2);
		$pgc{$index++} = $data[0];
	}
	close (PROBEFILE);
}

# UNUSED
# read in list of gene marker pairs and nlps that have been selected b y FDR critera (q<0.2) 
my %gash=();
sub load_gene_data{
	my $nlps_past_thresh="mouse_cis_alpha_nothresh.txt";
	open (HANDLE, $nlps_past_thresh);
	while (<HANDLE>) {
		chomp ;
		my ($gene, $marker, $alpha, $nlp) = split ("\t");

# cis search: for efficiency only store markers on same chrom as gene
		if ($mgc{$marker}{chr} == $pgc{$gene}{chr}) {
			push @{$gash{$gene}{marker}}, $marker;
			push @{$gash{$gene}{alpha}}, $alpha;
			push @{$gash{$gene}{nlp}}, $nlp;
		}
	}
	close (HANDLE);
}

# reads from a gene-sorted file all the markers assoc with that gene.
# scans until gene id changes and sends to find_cis_peak()
sub scan_file_for_gene{
	
	my %data=();
	# this file is sorted by gene, then marker
	my $file = "mouse_cis_alpha_nothresh_sorted.txt";
	open(INPUT, $file) || die "cannot open sorted file\n";
	my $curgene=1;
	while(<INPUT>){
		chomp;
		my ($gene, $marker, $alpha, $nlp) = split(/\t/);
		if ($gene == $curgene){
			push @{$data{$gene}{marker}}, $marker;
			push @{$data{$gene}{alpha}}, $alpha;
			push @{$data{$gene}{nlp}}, $nlp;
			print "$gene\t$marker\n";
		#gene number changed
		} else {
			$curgene = $gene;
			#send hash to process function
			find_cis_peak(\%data);
			#clear hash
			%data=();
			#store first instance here
			push @{$data{$gene}{marker}}, $marker;
			push @{$data{$gene}{alpha}}, $alpha;
			push @{$data{$gene}{nlp}}, $nlp;
		}
	}
}


# cis
# now find peaks for each gene
# The cis peak for a gene is just the highest -logP marker for a gene
# within RADIUS=5MB. Some of this code is a little unnecessary.
sub find_cis_peak{
	my($hashref) = @_;

	#silly, there should be only one gene per hash
	foreach my $gene (sort { $a<=> $b} keys %$hashref) {

		my @indexarray=();
		my $mc = scalar @{$hashref->{$gene}{marker}};
		for (my $i=0; $i<$mc; $i++) { 
			$indexarray[$i]=$i; 
		}

		# special sort to return indices of sorted array in descending order 
		# ie sort the markers (indexarray) by -logp in descending order
		my @nlpsortindex= sort { ${$hashref->{$gene}{nlp}}[$b] <=> ${$hashref->{$gene}{nlp}}[$a]} @indexarray;
		my @bin=();
		my @nlp=();
		my @alp=();

		# for each marker (sorted by pval), see if there is another marker <10mb away.
		# This is actually unncessary, since there's only one peak marker per gene.
		foreach my $idx (@nlpsortindex) {
			my $flag=0;

# if a potential peak marker is not within 10mb of regulated gene and is within 10mb of a
# previously found peak marker then don't bother adding it to 
			foreach my $peak (@bin) {
# if a marker is neither within ten mb of a flagged peak  nor a cis then flag it as a peak
				if( abs($mgc{ ${$hashref->{$gene}{marker}}[$idx] }-$mgc{$peak})<10000000 ) {
					$flag++;
				}
			}

			if ($flag>0) {
				#do nothing
			} else { 
				push @bin, ${$hashref->{$gene}{marker}}[$idx];
				push @nlp, ${$hashref->{$gene}{nlp}}[$idx];
				push @alp, ${$hashref->{$gene}{alpha}}[$idx];
			}
		}

		# output the cis peak for the gene	
		# I don't need to iterate, I just want the top marker per gene
		#for (my $i=0; $i<scalar @bin; $i++ ){
		#	print OUTFILE "$gene\t$bin[$i]\t$alp[$i]\t$nlp[$i]\n";
		#}
		print OUTFILE "$gene\t$bin[0]\t$alp[0]\t$nlp[0]\n";
	}
}

############ MAIN ###############3

load_mouse_marker_pos();
load_mouse_gene_pos();
scan_file_for_gene();
