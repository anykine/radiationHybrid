#!/usr/bin/perl -w
#
# Create two groups:
#  genes with ceqtls <fdr40
#  genes without ceqtls < 40
use strict;
use Data::Dumper;

my %gene_index=();
# read in the UCSC indexs and gene symbols 
sub load_gene_index{
	open(INPUT, "ucsc_gene_symbols_idx.txt") || die ;
	%gene_index = map{ chomp;my @d=split(/\t/); $d[0] => $d[1]} <INPUT>;
}

my %genes_with_FDR=();
# read in a gene with FDR < 40 file
sub load_genes_with_fdr{
	my ($dir, $fileprefix) = @_;
	for my $i (1..24){
		open(INPUT, "$dir/$fileprefix".$i.".txt")|| die "cannot open genes with FDR chr $i";
		#open(INPUT, "genes_withFDR40_chr".$i.".txt")|| die "cannot open genes with FDR chr $i";
		while(<INPUT>){
			chomp; next if /^#/;
			$genes_with_FDR{$_} = 1;
		}
		close(INPUT);
	}
}

# taking the genes with FDR < 40, create two files
# one with trans ceQTLs with FDR <40,
# one without trans ceQTLs < FDR40
sub create_categories{
	#iter over every UCSC gene
	foreach my $k(sort {$a<=>$b}keys %gene_index){
		if (defined $genes_with_FDR{$k} && $genes_with_FDR{$k}==1 ){
			#print those with trans ceQTL fdr < 40
			print "IN\t$k\t$gene_index{$k}\n";	
		} else {
			#print those without ceQTL fdr < 40	
			print "OUT\t$k\t$gene_index{$k}\n";	
		}
	}
}
######### MAIN #####################
unless (@ARGV==2){
	print "usage $0 <directory> <file prefix>\n";
	exit(1);
}
load_gene_index();
load_genes_with_fdr($ARGV[0], $ARGV[1]);
#print Dumper(\@genes_with_FDR);
create_categories();
