#!/usr/bin/perl -w
#
# parse the Affy annotation files
use strict;
use Data::Dumper;

# get the id and the gene symbols
sub parse_tabsep{
	my ($file) = @_;
	open(INPUT, "GPL96-39578.txt") || die "cannot open affy file $file";
	# skip the header
	<INPUT> for 1.. 17;
	while(<INPUT>){
		chomp; next if /^#/;	
		my @d = split(/\t/);
		my @genes = split(/\s+\/\/\/\s+/, $d[10]);
		print join("\t", $d[0], @genes),"\n";
	}

}

sub parse_commasep{
	open(INPUT, "HG-U133A.na29.annot.csv") || die "cannot open affy file";
	<INPUT> for 1..27;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/","/);
		$d[0] =~ s/"//g;
		$d[14] =~ s/"//g;
		my @genes = split(/\s+\/\/\/\s+/, $d[14]);
		print join("\t", $d[0], @genes), "\n";

	}
}
########### MAIN ###################
parse_tabsep();
#parse_commasep();
