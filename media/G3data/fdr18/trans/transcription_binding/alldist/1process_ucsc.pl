#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Tie::IxHash;

# merge the duplicate genes, ge the longest distance
# pretty the ucsc file
my %data =();
tie %data, "Tie::IxHash";

sub load_genes_into_hash{
	my $filename = shift;
	open(INPUT, "$filename")|| die "cannot open $filename";
	while(<INPUT>){ next if /^#/; chomp;
		my ($name,$chrom,$start,$stop,$symbol) = split(/\t/);
		next if $chrom =~ /_/;
		next if $chrom =~ /chrM/;
		next if $chrom =~ /random/;
		$chrom =~ s/chrX/chr23/;
		$chrom =~ s/chrY/chr24/;
		$chrom =~ s/chr//;
		if (defined $data{$symbol}{$start}){
			# following josh's lead
			if (abs ($start-$stop) > abs($data{$symbol}{start}-$data{$symbol}{stop})){
				$data{$symbol}{chrom} = $chrom;
				$data{$symbol}{start} = $start;
				$data{$symbol}{stop} = $stop
			}
			#if ($start < $data{$symbol}{$start}){
			#	$data{$symbol}{start} = $start;
			#}
			#if ($stop > $data{$symbol}{$stop}){
			#	$data{$symbol}{stop} = $stop;
			#}
		} else {
			$data{$symbol}{chrom}=$chrom;
			$data{$symbol}{start}=$start;
			$data{$symbol}{stop}=$stop;
		}
	}
}

sub output{
	foreach  my $k (keys %data){
		print join("\t", $data{$k}{chrom}, $data{$k}{start}, $data{$k}{stop}, $k),"\n";
	}

}
######### MAIN #####################
load_genes_into_hash("ucschg18_genes.txt");
#print Dumper(\%data);
load_genes_into_hash("ucschg18_miRna.txt");
output();

