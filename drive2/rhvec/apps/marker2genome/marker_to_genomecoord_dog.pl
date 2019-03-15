#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use lib '/home/rwang/lib/';
use util;

unless(@ARGV==3){
	print <<EOH;
	usage $0 <pvals file> <chrom size file> <marker positions>
		ex. $0 dog_vec_vectors_inorder.txt.out.pval.e06 dog_chrom_sizes.txt dog_vec_markers_positions.txt

	Take the pvals file which is "marker1 marker2 pval" and convert it to
	marker1_pos marker2_pos pval using genome coordinates (to be computed)
EOH
exit(0);
}

my %chromlength=(); #hash of chrom and its length note(chrX=chr96)
my %markerIndex = (); #hash of marker index->name,position

#-----MAIN-----
buildChromLengthHash($ARGV[1]);
#print Dumper(\%chromlength);

buildMarkerIndex($ARGV[2]);
#print Dumper(\%markerIndex);
#dumpHash(\%markerIndex);

translateFile($ARGV[0]);

#------SUBS---------
sub translateFile{
	my ($pvalFile) = @_;
	open(INPUT, $pvalFile) or die "cannot open pval file\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		#file order is marker1, marker2, pval
		my @line = split(/\t/);
		#output marker1, pos1, marker2, pos2, pval
		print "$line[0]\t", makeGenomeCoord($line[0]), "\t";
		print "$line[1]\t", makeGenomeCoord($line[1]), "\t";
		#print all else
		shift @line; shift @line;
		print join("\t", @line), "\n";
		#print "$line[2]\n";
	}
}
#given marker, look up chrom/pos and create genome coord
sub makeGenomeCoord{
	my ($marker) = @_;
	my $chrom = $markerIndex{$marker}{chrom};
	my $genomeCoord = 0;
	my $chromSum = 0;
	if ($chrom == 1){
		$genomeCoord = $markerIndex{$marker}{start};
	} elsif ($chrom == 96){
		#get the cumulative sum
		for(my $i=1; $i<=38; $i++){
			$chromSum += $chromlength{"chr$i"};
		}
		$genomeCoord = $markerIndex{$marker}{start} + $chromSum;
	} else {
		$chrom = $chrom-1;
		#get the cumulative sum
		for(my $i=1; $i<=$chrom; $i++){
			$chromSum += $chromlength{"chr$i"};
		}
		$genomeCoord = $markerIndex{$marker}{start} + $chromSum;
		#$genomeCoord = $markerIndex{$marker}{start} + $chromlength{"chr$chrom"};
	}
	return $genomeCoord;
}

#create a hash of marker index->chrom/start/end positions
sub buildMarkerIndex{
	my($markerPosFile) = @_;
	my $index = 1;
	open(INPUT, $markerPosFile) or die "cannot open marker file\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		$markerIndex{$index} = {
			name=>(split(/\t/))[0],  #first array element returned from split
			chrom=>(split(/\t/))[1],
			start=>(split(/\t/))[2],
			end=>(split(/\t/))[3]
			};
		$index++;
	}
}

#build chromlength index
sub buildChromLengthHash {
	my $chromLenFile = shift;
	open(INPUT1, $chromLenFile) or die "cannot open file for read\n";
	while(<INPUT1>){
		next if /^#/;
		chomp;
		$chromlength{(split(/\t/))[0]} = (split(/\t/))[1]; 
	}
}

sub dumpHash{
	my ($hashref) = @_;
	my @hashkeys = sort keys %{$hashref};
	foreach my $i (@hashkeys){
		print "k=$i\tv=${$hashref}{$i}{name}\n";
	}
}
