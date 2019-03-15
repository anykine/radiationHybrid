#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

my %common=(); #the genes on both gnf and human arrays

# need to find those genes in COMMON between
# GNF1H and human expression (some are in one
# but not the other)
sub build_ids_in_common{
	open(INPUT, "human_final_idonly.txt") || die "cannot open human ids";
	my %human = map{ chomp; $_ => 1} <INPUT>;
	close(INPUT);
	#print Dumper(\%human);

	open(INPUT, "../gnf_final_idonly.txt") || die "cannot open gnf ids";
	my %gnf = map { chomp; $_ => 1} <INPUT>;
	close(INPUT);

	# check human and GNF1h against the affy2ilmn common table
	open(INPUT,"../../affy_gnf_hugo_ilmn_final_index.txt") || die "cannot open affy2ilmn";
	while(<INPUT>){
		next if /^#/; chomp;
		my ($index, $affy, $ilmn) = split(/\t/);
		if (defined $human{$index} && defined $gnf{$index}){
			# store this guy
			$common{$index} = 1;
			#print join("\t", $index, $affy, $ilmn),"\n";
		}
	}
}

sub filter_on_common_gnf{
	open(INPUT,"/media/G3data/fdr18/compare_to_others/symatlas_human/corr/GNF1Hdata_final_merged_sortby_id.txt") || die "cannot open gnf";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		if (defined $common{ $d[0] }) {
			print join("\t", @d),"\n";
		}
	}
}

sub filter_on_common_human{
	open(INPUT,"human_expr_final_merged.txt") || die "cannot open human";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		if (defined $common{ $d[0] }) {
			print join("\t", @d),"\n";
		}
	}
}
########## MAIN #####################
# get the affy2ilmn IDs that are on BOTH arrays
build_ids_in_common();

# filter human
#filter_on_common_human();

filter_on_common_gnf();
