#!/usr/bin/perl -w
#
# put the affy2ilmn id number in place of symbol in ILMN expr data
use strict;

my %ilmn=();
sub filter_gene_symbol_by_ilmn{
	open(INPUT, "../../affy_gnf_hugo_ilmn_final_index.txt") || die "cannot open affy2ilmn";
	while(<INPUT>){
		next if /^#/; chomp;
		my ($index, $affygene, $ilmngene) = split(/\t/);
		$ilmn{$ilmngene} = $index;
	} 
	close(INPUT);
	open(INPUT, "hum_expr_symbol.txt") || die "cannot open final expr";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		if (defined $ilmn{$d[0]}){
			print join("\t", $ilmn{$d[0]}, @d[1 .. $#d]),"\n";
		}
	}
}


########## MAIN ###################
## filter the human expr data by affy2ilmn ID
filter_gene_symbol_by_ilmn();
