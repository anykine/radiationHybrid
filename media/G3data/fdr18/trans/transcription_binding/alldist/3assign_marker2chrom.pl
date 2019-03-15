#!/usr/bin/perl -w
# the TF GO analysis done by sangtae assigns a marker to its nearest
# gene and no marker can be assigned to > 1 gene
# 
#
use strict;
use Data::Dumper;

my %probes_per_chrom=();
my %genes_per_chrom=();

# load the number of genes/probes per chrom;
sub load_indexes{
	open(INPUT, "num_probes_per_chrom.txt") || die;
	%probes_per_chrom = map { chomp;my @d = split(/\t/); $d[0]=>$d[1]} <INPUT>;
	close(INPUT);
	open(INPUT, "num_ucscgenes_per_chrom.txt") || die;
	%genes_per_chrom = map { chomp;my @d = split(/\t/); $d[0]=>$d[1]} <INPUT>;
	close(INPUT);
}
#compute the actual marker index
#the index passed in is 0-based, so add 1
sub get_marker_index{
	my ($chrom, $index) = @_;
	my $result = 0;
	if ($chrom ==1){
		return $index+1;
	} else {
		for (my $i=1; $i<$chrom; $i++){
			$result += $probes_per_chrom{$i};	
		}
		$result = $result+$index+1;
		return $result;
	}
}

# compute the actual gene index 
sub get_gene_index{
	my ($chrom, $index) = @_;
	my $result = 0;
	if ($chrom ==1){
		return $index+1;
	} else {
		for (my $i=1; $i<$chrom; $i++){
			$result += $genes_per_chrom{$i};	
		}
		$result = $result+$index+1;
		return $result;
	}
}
# load one of the distance files
# numrows = genes; numcols = markers
sub load_file{
	my $chrom = shift;
	my $data = [];
	open(INPUT, "diffs".$chrom.".txt") || die "cannot open diffs $chrom";
	my $counter = 0;
	while(<INPUT>){
		chomp; next if /^#/;
		$data->[$counter] =  [ split(/\t/) ];
		$counter++;
	}
	return $data;
}

# assign markers unique to a gene
# 1. <1mb
# 2. no markers to more than one gene
sub assign{
	my ($aref, $chrom) = @_;
	my %results = ();
	# these are the marker indexes for this chrom
	my @row1idx = 0..(scalar @{$aref->[0]}-1);

	# we always look at two rows at a time;
	for (my $row1=0; $row1< scalar @{$aref}; $row1++){
		#sort markers indices in order of decres dist to gene 
		my @sort1idx = sort { $aref->[$row1][$a] <=> $aref->[$row1][$b] } @row1idx;

		# handle boundary case, assign closest marker to the gene
		if ($row1 == (scalar @{$aref} - 1)){
			my $marker1 = $sort1idx[0];
			my $geneidx = $row1+1;
			my $markeridx = $marker1+1;
			push @{$results{$geneidx}{markers}}, $marker1;
			last;
		}

		#iter over row1 sorted indexes til you find stopping point	
		for (my $i=0; $i< scalar @row1idx; $i++){
			my $marker1 = $sort1idx[$i];
			# add the marker to gene's neighborhood
			if ($aref->[$row1][$marker1] <= $aref->[$row1+1][$marker1]){
			
				my $geneidx = $row1+1;
				my $markeridx = $marker1+1;
				#my $geneidx = get_marker_index($chrom, $row1);
				#my $markeridx = get_marker_index($chrom, $marker1);
				push @{$results{$geneidx}{markers}}, $markeridx;
			} else {
				last;
			}
		}
	}
	#print Dumper(\%results);
	return (\%results);
}

# simpler method, for a col(marker), look across all rows
# find min, assign to gene
sub col_sweep{
	my ($aref, $chrom) = @_;
	my %marker2gene= ();
	my $LIMIT=1000000;
	#sweep cols/markers
	for (my $marker = 0; $marker< scalar @{$aref->[0]}; $marker++){
		# key = marker, val = dist
		#sweep genes/rows
		for (my $gene = 0; $gene < scalar @{$aref}; $gene++){
			my $markeridx = get_marker_index($chrom, $marker);
			if (defined $marker2gene{$markeridx}){
				if ($aref->[$gene][$marker] < $marker2gene{$markeridx}{dist} && $aref->[$gene][$marker] < $LIMIT){
					$marker2gene{$markeridx}{dist} = $aref->[$gene][$marker];
					$marker2gene{$markeridx}{gene} = get_gene_index($chrom,$gene);
				}
			} else {
				if ($aref->[$gene][$marker] < $LIMIT){
					$marker2gene{$markeridx}{dist} = $aref->[$gene][$marker];
					$marker2gene{$markeridx}{gene} = get_gene_index($chrom, $gene);
				}
			}
		}
	}
	return (\%marker2gene);
}

sub output_sweep{
	my $hashref = shift;
	foreach my $k (sort {$a<=>$b} keys %$hashref){
		print "$k\t$hashref->{$k}{gene}\t$hashref->{$k}{dist}\n";
	}
}

sub output{
	my $hashref=shift;
	#print Dumper($hashref);
	foreach my $k (sort {$a<=>$b} keys %$hashref){
		for (my $i=0; $i < scalar @{$hashref->{$k}{markers}}; $i++){
			print "$k\t${$hashref->{$k}{markers}}[$i]\n";
		}
	}
}
############# MAIN #################
unless (@ARGV==1){
	print "usage $0 <chrom 1-24>\n";
	exit(1);
}
load_indexes();
my $chr = $ARGV[0];
my $data = load_file($chr);
my $res = col_sweep($data, $chr);
#my $res = assign($data,21);
output_sweep($res);
