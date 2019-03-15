#!/usr/bin/perl -w
#
# get only the genename and pvalue from microRNA target file
# for further analysis in R
use strict;
use Data::Dumper;

sub filter_sanger_miRNA_genename{
	my ($file) = @_;
	open(INPUT, $file) || die "cannot open $file";
	while(<INPUT>){
		chomp; next if /^#/;
		next if /^$/;	
		my @data = split(/\t/);
		#output genename & pval
		if (defined $data[12] ){
			print join("\t", $data[10], $data[12]),"\n";
		}
	}

}


############ MAIN ##################
filter_sanger_miRNA_genename($ARGV[0]);
