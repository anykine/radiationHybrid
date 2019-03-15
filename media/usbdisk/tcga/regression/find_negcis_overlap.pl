#!/usr/bin/perl -w
#
# Find the over lap of neg cis between hum/mus and tcga.
# Find matchup based on gene symbol
use strict;
use Data::Dumper;

our %rhMnegcis=(); #mouse rh to alpha
our %rhHnegcis=(); #human rh to alpha
our %tcgasym=(); #tcga gene num to symbol
our %simplecis=(); #tcga symbol to alpha

# load RH cis ceqtls (pos and neg)
sub load_hum_mus{
	open(INPUT, "/media/G3data/fdr18/cis/comp_MH_cis_alphas/comp_hum_mouse_FDR40_symbol.txt") || die "erorr $!";	
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		$d[4] = uc($d[4]);
		if (defined $rhMnegcis{$d[4]}){
			$rhMnegcis{$d[4]} = $d[1] if $d[1] < $rhMnegcis{$d[4]};
		} else {
			$rhMnegcis{$d[4]} = $d[1];	
		}
		if (defined $rhHnegcis{$d[4]}){
			$rhHnegcis{$d[4]} = $d[3] if $d[3] < $rhHnegcis{$d[4]};
		} else {
			$rhHnegcis{$d[4]} = $d[3];	
		}
	}
	print "size of human RH neg hash is ", scalar keys %rhHnegcis, "\n";
	print "size of mouse RH neg hash is ", scalar keys %rhMnegcis, "\n";
}

# read in simple_cis.txt file and key symbol to alpha
# format: gene | marker | alpha | r | nlp
sub simple_cis{
	open(INPUT, "simple_cis.txt") || die "cannot open simple cis";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d= split(/\t/);
		# convert to a symbol => alpha
		$simplecis{ $tcgasym{$d[0]} } = $d[2];
	}
}

#map the TCGA genenum to a symbol
sub map_tcga_sym{
	open(INPUT, "../index/affyexpr/affypos_common_final.txt") || die "error $!";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d =split(/\t/);
		$tcgasym{$d[0]} = uc($d[4]);
	}
}

# create a table, for each gene list the
# alphas for musRH, humRH, tcga
sub output_for_correlation{
	foreach my $g (keys %simplecis){
		if (defined $rhMnegcis{$g} && defined $rhHnegcis{$g} ){
			print join("\t", $g, $simplecis{$g}, $rhMnegcis{$g}, $rhHnegcis{$g}),"\n";

		} 
	}
}

# not sure if this is the right thing to do
#iterate over names of genes sub are_neg_conserved
sub test_for_conservation{ 
	my $conserv_rhMneg=0;
	my $conserv_rhHneg=0;
	my $conserv_rhMHneg=0;
	my $neg=0;
	foreach my $g (keys %simplecis){
		if ($simplecis{$g} < 0){
			$neg++;
			if (defined $rhMnegcis{$g} && $rhMnegcis{$g} < 0){
				$conserv_rhMneg++;	
			}
			if (defined $rhHnegcis{$g} && $rhHnegcis{$g} < 0) {
				$conserv_rhHneg++;	
			}
			if (defined $rhMnegcis{$g} && defined $rhHnegcis{$g} && $rhHnegcis{$g} < 0 && $rhMnegcis{$g} < 0){
				$conserv_rhMHneg++;
			}
		}
	}
	print "out of ", scalar keys %simplecis,"\n";
	print "$neg are negative\n";
	print "$conserv_rhMneg are common with mouse RH\n";
	print "$conserv_rhHneg are common with human RH\n";
	print "$conserv_rhMHneg are common with mouse and human RH\n";
}
######## MAIN ######################
load_hum_mus();
map_tcga_sym();
simple_cis();
#print Dumper(\%tcgasym);
#test_for_conservation();
output_for_correlation();
