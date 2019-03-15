#!/usr/bin/perl -w
#
# Convert num genes regulated by marker to nearest-gene-to-marker
#
use strict;
use Data::Dumper;

my %marker2gene=();
# closest-gene => array of num genes regulated
# using this, can vote, average, take max 
my %numregulators=();

#########################3
load_conversion();
#print Dumper(\%marker2gene);
conv_file();
#print Dumper(\%numregulators);
process_data();
#########################3


sub process_data{
	for my $k (sort {$a<=>$b}  keys %numregulators) {
		# pass the array to find_max
		my $val = find_max( @{$numregulators{$k}});
		print "$k\t$val\n";
	}
}

sub find_max{
	my @data = @_;
	my $winner;
	$winner = $data[0];
	foreach my $j (@data){
		if ($j > $winner){
			$winner = $j;
		}
	}
	return $winner;
}

# convert file with marker to closest gene
# input file: markerID [1,232626] | num genes regulated
sub conv_file{
	open(INPUT, "x_marg.txt") || die "cannot open mouse data\n";
	while(<INPUT>){
		chomp;
		my @line = split(/\t/);
		#print $line[0], "\t",$marker2gene{$line[0]},"\t", $line[1], "\n";
		# hashkey= marker
		push @{$numregulators{$marker2gene{$line[0]}}}, $line[1];
	}
}

# load file that maps marker -> gene
# store in hash
sub load_conversion{
	open(INPUT, "nearest_gene_all_markers.txt") || die "cannot open marker2gene\n";
	my $i=1;
	while(<INPUT>){
		chomp;
		$marker2gene{$i} = $_;	
		$i++;
	}
	close(INPUT);
}
