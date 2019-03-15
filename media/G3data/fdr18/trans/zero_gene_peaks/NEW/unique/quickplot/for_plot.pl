#!/usr/bin/perl -w
#
# extract the data from G3 binary file for a 
# zero-gene eqtl and the multiple genes it regulates
# See if those peaks are coincident.
#
use lib '/home/rwang/lib';
use g3datamanip;
use hummarkerpos;
use humgenepos;
use Data::Dumper;


#store everything as hash of arrays
my %data = ();

# pass in list of genes to extract,
# returns nlp or alphas for gene-markers in hash of arrays
sub extract_g3data{
	my @genes = @_;

	foreach $gene (@genes){
		for (my $i=1; $i<=235829; $i++){
			my %rec= get_g3record($gene, $i);
			push @{$data{$gene}}, $rec{nlp};
		}
	}
	#print Dumper(\%data);
}

# nicely format the data, rows=markers, cols=genes
sub nice_output{
	my @keys = (sort {$a<=>$b} keys %data	);
	my $numkeys = scalar @keys;


	for (my $i=1; $i<235829; $i++){
		#print position
		print $hummarkerpos_by_index{$i}{chrom},"\t";
		print $hummarkerpos_by_index{$i}{pos},"\t";

		my $count=1;
		foreach my $k (@keys) {
			print $data{$k}[$i-1], "\t";
			if ($count == $numkeys){
				print "\n";
			} else {
				print "\t";
			}
			$count++;
		}
		#print "\n";
	}
}

sub init{
	#get human markers, expose %hummarkerpos_by_index
	load_markerpos_by_index("g3data");
	
	#get human genes, expose %
}
########### MAIN ################
init();

# checking marker 488
#extract_g3data((14266, 17180, 2001, 271, 2884, 3081));

# checking marker 190098
extract_g3data((12924,14203,16228,18842,18851));
nice_output();
