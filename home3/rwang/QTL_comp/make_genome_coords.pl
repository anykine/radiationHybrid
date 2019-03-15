#!/usr/bin/perl -w
# 6/10/2008 - take UCSC BED format and convert to genome coords
use strict;
use Data::Dumper;
use POSIX qw(ceil floor);

# 23 = chrX; 24=chrY;
my %chromlength=();
my %genepos = ();
my %markerpos = ();

buildChromLengthHash();
buildMarkerHash();
buildGeneHash();

# output
#print_marker_gc();
print_gene_gc();

sub print_gene_gc{
	foreach my $g ( sort {$a <=> $b} keys %genepos){
		print $genepos{$g},"\n";
	}
}

sub print_marker_gc{
	foreach my $p ( sort {$a <=> $b} keys %markerpos){
		print $markerpos{$p},"\n";
	}
}

sub buildGeneHash{
	open(INPUT, '/home3/rwang/expr/phase2/conv_pos_hg18/ilmn_goodpos_hg18.txt') || die "cannot open gene pos\n";
	my $counter=1;
	while(<INPUT>){
		next if /^#/;
		chomp;
		my(undef, $chr,$start,$stop) = split(/\t/);
		$genepos{$counter} = makegc($chr,$start,$stop);
		$counter++;
	}
}

sub buildMarkerHash{
	# load cgh markerpos
	open(INPUT, '/home3/rwang/cgh/final_cgh/g3matrix_pos_sorted_nodup_smoothed_posonly') || die "cannot open cgh pos\n";
	my $counter=1;
	while(<INPUT>){
		chomp;
		my($chr,$start,$stop) = split(/\t/);
		$chr =~ s/chr//;
		$chr =~ s/^0//;
		$start =~ s/^0*//ig;
		$stop  =~ s/^0*//ig;
		#print "$chr $start $stop ", makegc($chr, $start, $stop), "\n";
		$markerpos{$counter} = 	makegc($chr,$start,$stop);
		$counter++;
	}
}

# size of each chrom: ncbi build 36, ucsc hg18
sub buildChromLengthHash{
	open(INPUT, '/home3/rwang/rhvec/chrom_size_human_36.txt') || die "cannot open INPUT";
	while(<INPUT>){
		next if /^#/;
		chomp;
		my @data = split(/\t/);
		$chromlength{$data[0]} = $data[1];
	}
}

#-------------------------
# Make genome coords using "middle of gene"
# ------------------------
sub makegc{
	my($chr,$start,$stop) = @_;	
	my $chromSum=0;
	$chr = 23 if $chr eq 'X';
	$chr = 24 if $chr eq 'Y';
	if (1==$chr) {
		return floor(($start+$stop)/2);
	} else{
		for (my $i=1; $i < $chr; $i++){
			$chromSum += $chromlength{$i};
		}
		return floor(($start+$stop)/2) + $chromSum;
	}
}
		

