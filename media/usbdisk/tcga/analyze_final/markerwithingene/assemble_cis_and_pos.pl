#!/usr/bin/perl -w
#
# add all the position info the cis file
use strict;
use Data::Dumper;

our %genepos=();

# add the position info to the cis 
# cancer ceqtls
sub assemble_cis_pos{
	#open(INPUT, "../simple_cis.txt") || die "cannot open cis";
	#open(INPUT, "../simple_cis_nothresh.txt") || die "cannot open cis";
	#open(INPUT, "simple_female_cis.txt") || die "cannot open cis";
	#open(INPUT, "simple_male_cis.txt") || die "cannot open cis";
	#open(INPUT, "unique/regress_results1_female.txt") || die "err $!";
	#open(INPUT, "unique/regress_results1_male.txt") || die "err $!";
	open(INPUT, "regress_results1_all.txt") || die "err $!";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		if (defined $genepos{$d[0]}){
			print join("\t", 
				$genepos{$d[0]}{chrom}, 
				$genepos{$d[0]}{start}, 
				$genepos{$d[0]}{stop}, 
				$genepos{$d[0]}{symbol}, 
				@d) ,"\n";
		}
	}

}
# pos of affy expr genes
# load from EXPR file
sub load_gene_index{
	open(INPUT, "../allexpr.txt") || die "cannot open expr pos";
	my $counter = 1;
	while(<INPUT>){
		chomp; next if /^#/; next if /^Chr/;
		my @d = split(/\t/);
		$genepos{$counter++} = {
				chrom=>$d[1],
				start=>$d[2],
				stop=>$d[3],
				symbol=>$d[0]
		}
	}
}


######### MAIN #####################
load_gene_index();
#print Dumper(\%genepos);
assemble_cis_pos();
