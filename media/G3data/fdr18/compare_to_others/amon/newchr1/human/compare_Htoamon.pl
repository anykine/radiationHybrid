#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

# Generate the lists to compare Angelika's cis data with 
# Human RH cis data....
#

#alphas
my %human_alphas=();
my %amon_data=();

#gene symbols
my %ilmn_genes=();
my %amon_genes=();


# store alphas for human, FDR40
sub store_human_alphas{
	# FDR40
	#open(INPUT, "/media/G3data/fdr18/cis/cis_FDR40.txt") || die "cannot open human cis\n";
	#open(INPUT, "cis_all.txt") || die "cannot open human cis\n";
	open(INPUT, "/media/G3data/fdr18/cis/cis_2mb/cis_FDR30.txt") || die "cannot open human cis\n";
	# no threshold
	#open(INPUT, "/media/usbdisk/mouse_data/split_cis_trans/mouse_all_cis_peaks.txt") || die "cannot open mouse cis peaks\n";
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		# store the alpha, key is gene number
		$human_alphas{$data[0]} = $data[2];
	}
	close(INPUT);
}


# build talbe of Amon gene symbols and their alphas;
# averge the alphas of multiple instances
# Amon uses Affy arrays
# this file has one less number of columns than previous chr_amon.txt
sub build_amon_genes{
	my $counter=0;
	# make sure this file has no header on it (probe|symbol|mu|alpha)
	open(INPUT, "../chr_amon_new.txt") || die "cannot open amon data\n";
	while(<INPUT>){
		chomp; next if /^#/;
		my @data = split(/\t/);
		next if $data[5] > 0.05;
		# chr1/19 have only one observation
		#next if $data[3] == 1;
		#next if $data[3] == 19;

		my @symbols = split(/ \/\/\/ /, $data[1]);
		$counter = $counter + scalar @symbols;
		# some genes have synonyms...
		# i define an entry for every gene symbol/synonym
		foreach my $k (@symbols){
			$k = uc($k);
			if (defined $amon_genes{$k} ){
				#print "$k exists!\n";
				my $runavg = ($amon_genes{$k}{count} * $amon_genes{$k}{alpha} + $data[4])/($amon_genes{$k}{count} +1);
				$amon_genes{$k}{alpha} = $runavg;
				$amon_genes{$k}{count}++;
			} else {
				#key = symbol, val=gene number
				$amon_genes{$k}{alpha} = $data[4];
				$amon_genes{$k}{count} = 1;
				$amon_genes{$k}{chrom} = $data[2];
			}
		}
	}
	print STDERR "counter = $counter\n";
	close(INPUT);
}

# build table of human genes and their alphas
# we used ILMN arrays
sub build_ilmn_genes{
	open(INPUT, "gene_index.txt") || die "cannot open ILMN genes\n";
	while(<INPUT>){
		chomp;
		next if /^#/;
		#my @data = split(/\t/);
		my ($genenum, $symbol) = split(/\t/);
		$symbol = uc($symbol);
		# get alphas from another table, defined above
		if (defined $human_alphas{$genenum}){
			# set the human gene = cis alpha
			$ilmn_genes{$symbol}{alpha} = $human_alphas{$genenum};
		}
	}
}

# compare cis FDR40 against amon, make the list,
# feed into R for correlation
sub compare_cis{
	# for each gene symbol in agilent, look for it in affy
	# we lose some overlap here....
	foreach my $k (keys %ilmn_genes){
		if (defined $amon_genes{$k} ){
			print "$k\t$amon_genes{$k}{alpha}\t$ilmn_genes{$k}{alpha}\n";
			#print "$k\t$amon_genes{$k}{alpha}\t$agil_genes{$k}{alpha}\t$amon_genes{$k}{chrom}\n";
		} else {
			print STDERR "cannot find $k\n";
		}
	}
}
########### RUN ###########
store_human_alphas();
#store_amon();
build_amon_genes();
#print Dumper(\%amon_genes);
build_ilmn_genes();
#print Dumper(\%ilmn_genes);
compare_cis();
