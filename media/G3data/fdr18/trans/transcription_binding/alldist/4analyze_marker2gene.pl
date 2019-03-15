#!/usr/bin/perl -w

# take the markers2gene_chrNN.txt files and filter then
# against the trans FDR40 markers to get only
# those genes with trans FDR40 markers

use strict;
use Data::Dumper;

my %genes=();
# read the data into data struct
sub store_data{
	my ($file) = @_;	
	# marker2gene_chr1.txt
	open(INPUT, $file) || die;
	while(<INPUT>){
		chomp; next if /^#/;
		my ($marker,$gene,$dist) = split(/\t/);
		push @{$genes{$gene}}, $marker;
	}
}

my %trans40=();
sub load_trans40{
	my $fdr = shift;
	my $file =  join("", "/media/G3data/fdr18/trans/trans_peaks_FDR", $fdr,".txt");
	open(INPUT, $file) || die "cannot open file FDR $fdr";
	while(<INPUT>){
		chomp; next if /^#/;
		my(undef, $marker, undef, undef) = split(/\t/);
		$trans40{$marker} = 1;
	}
}

my @genes_with=();
# filter %genes for those with markers < FDR40
sub separate{
	foreach my $g (sort {$a<=>$b} keys %genes){
		foreach my $m (@{$genes{$g}}){
			# those genes with a marker <fdr40
			if (defined $trans40{$m} && $trans40{$m} ==1 ){
				push @genes_with, $g;
				last;
			}
		}
	}
}

# output the separated genes
sub output{
	foreach my $k (@genes_with){
		print $k,"\n";
	}
}

# output the raw data: gene | markerX markerY markerZ
sub output_data{
	foreach my $k (sort {$a<=>$b} keys %genes){
		for (my $i=0; $i<scalar @{$genes{$k}}; $i++){
			print $k;
			if ($i== (scalar @{$genes{$k}}-1) ){
				print "\n";
			} else {
				print "\t";
			}
		}
	}
}

######### MAIN #####################
unless (@ARGV==1){
	print "usage $0 <marker2gene_chrNN.txt>\n";
	exit(1);
}
load_trans40(10);
#store_data("marker2gene_chr21.txt");
store_data($ARGV[0]);
separate();
output();
#output_data();
