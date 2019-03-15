#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

#use the human gene_association.goa_human file which has
#one to one mapping of GO-term to Gene Symbol
#to create a .GMT file http://www.broadinstitute.org/cancer/software/gsea/wiki/index.php/Data_formats#GMT:_Gene_Matrix_Transposed_file_format_.28.2A.gmt.29
#to feed into my analysis.R

my %go_cat=();
# create hash with keys {GOid} {genesymbol}
sub parse_GOA{
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/gsea/goslim/GOA/gene_association.goa_human")||die;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		#2=gene, 4=goID
		$go_cat{$d[4]}{uc($d[2])} = 1;
	}
	#print Dumper(\%go_cat);
}

my %go2term=();
# parse the GeneOntology source file for all GO terms/id/namespaces
sub parse_GO_obo{
	{
		open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/gsea/goslim/gene_ontology.1_2.obo")|| die;
		local $/ = '[Term]';
		while(<INPUT>){
			next if $_ !~ /name:/;
			my ($goid,$goterm) = $_ =~ (/id: (GO:\d+)\nname: (.*?)\nnamespace:/);
			my ($namespace) = $_ =~ (/namespace: (\w+)\n/);
			$goterm =~ s/ /_/g;
			$goterm = uc($goterm);
			#print "$goid\t$goterm\n";
			#print "$goid\t$goterm\t$namespace\n";
			$go2term{$goid}{term} = $goterm;
			$go2term{$goid}{namespace} = $namespace;
			#print Dumper(\%go2term);
		}
	}
}

sub test{
	#print Dumper(\%term2namespace);
		#print "$term2namespace{$k}\n";
}

# load the GO:000 to Category mapping using Josh's file
# DO NOT RUN THIS AND THE parse_GO_obo() routine
sub load_GO2term{
	open(INPUT, "/media/bishop/Sangtae_Calc/Sangtae_GO/GO_categories_key.txt")||die;
	while(<INPUT>){
		chomp; next if /^#/;
		my ($id,$goterm) = split(/\t/);
		$go2term{$id} = $goterm;
	}
}
# output the gmt file
# col1=category, col2=descrip(go cat), col3...N=genes
sub output_as_gmt{
	my $thresh = shift;
	foreach my $k (sort keys %go_cat){
		my $size = scalar (keys %{$go_cat{$k}});
		#print $size,"\n";
		next if $size < $thresh;
		print $go2term{$k}{term},"\t";
		print $go2term{$k}{namespace},"\t";
		print join("\t", (sort keys %{$go_cat{$k}})),"\n";
	}
}

#output the counts per category
sub output_as_counts{
	my $thresh = shift;
	foreach my $k (sort keys %go_cat){
		my $size = scalar (keys %{$go_cat{$k}});
		next if $size < $thresh;
		print "$go2term{$k}{term}\t";
		print $size,"\n";
	}
}
######### MAIN #####################
parse_GOA();
parse_GO_obo();
output_as_gmt(70);
#test();
#output_as_counts(70);
