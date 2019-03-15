#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

# Generate the lists to compare Angelika's cis data with 
# mouse RH cis data....
#
# 7/24/09 - updated to work on new chr1 regression data

#alphas
my %mouse_alphas=();
my %amon_data=();

#gene symbols
my %agil_genes=();
my %amon_genes=();


# store alphas for mus, FDR40
sub store_mouse_alphas{
	# FDR40
	open(INPUT, "/media/G3data/fdr18/cis/comp_MH_cis_alphas/mouse_cis_peaks_FDR40.txt") || die "cannot open mouse cis\n";
	# no threshold
	#open(INPUT, "/media/usbdisk/mouse_data/split_cis_trans/mouse_all_cis_peaks.txt") || die "cannot open mouse cis peaks\n";
	#open(INPUT, "/media/G3data/mouse_data/split_cis_trans/mouse_all_cis_peaks.txt") || die "cannot open mouse cis peaks\n";
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		# store the alpha, key is gene number
		$mouse_alphas{$data[0]} = $data[2];
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
	open(INPUT, "chr_amon_new.txt") || die "cannot open among data\n";
	while(<INPUT>){
		chomp; next if /^#/;
		my @data = split(/\t/);
		# only signif alphas please
		next if $data[5] > 0.05; 
		# this gene name is "####..." which fucks things up, so drop it
		#next if $data[0] eq "1448235_s_at";
		#filter based on which chroms

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

# build table of mouse genes and their alphas
# we used Agilent arrays
sub build_agil_genes{
	open(INPUT, "/media/G3data/fdr18/compare_to_others/amon/mouse_probenames_agil.txt") || die "cannot open agil genes\n";
	while(<INPUT>){
		next if /^#/;
		my @data = split(/\t/);
		$data[2] = uc($data[2]);
		# get alphas from another table, defined above
		if (defined $mouse_alphas{$data[0]}){
			# set the mouse gene = cis alpha
			$agil_genes{$data[2]}{alpha} = $mouse_alphas{$data[0] };
		}
	}
}

# compare cis FDR40 against amon, make the list,
# feed into R for correlation
sub compare_cis{
	# for each gene symbol in agilent, look for it in affy
	# we lose some overlap here....
	foreach my $k (keys %agil_genes){
		if (defined $amon_genes{$k} ){
			print "$k\t$amon_genes{$k}{alpha}\t$agil_genes{$k}{alpha}\n";
			#print "$k\t$amon_genes{$k}{alpha}\t$agil_genes{$k}{alpha}\t$amon_genes{$k}{chrom}\n";
		} else {
			print STDERR "cannot find $k\n";
		}
	}
}
########### RUN ###########
store_mouse_alphas();
#store_amon();
build_amon_genes();
#print Dumper(\%amon_genes);
build_agil_genes();
#print Dumper(\%agil_genes);
compare_cis();
