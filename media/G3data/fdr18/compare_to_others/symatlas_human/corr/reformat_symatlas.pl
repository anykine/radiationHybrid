#!/usr/bin/perl -w
#
# -Invert GNF1Hdata
# -Un-invert the data
# -Add gene symbol to beginning;
# -Filter gene symbol
#
use strict;
use Data::Dumper;
use DBI;

my %affy=();
my %gnf=();
my %alldata = (); # all probes, no AFFX or duplicates probe_ids


# filter cols of replicate-merged, gene merged
# with 
sub filter_gene_symbol_by_affy{
	open(INPUT, "../affy_gnf_hugo_ilmn_final_index.txt") || die "cannot open affy2ilmn";
	# store the mapping
	while(<INPUT>){
		next if /^#/; chomp;
		my ($index, $affygene, $ilmngene) = split(/\t/);
		$affy{$affygene} = $index;
	}
	close(INPUT);
	open(INPUT, "GNF1Hdata_replicate_symbol.txt") || die "cannot open final merged";
	my $header = <INPUT>;
	print join("\t", "map_id", $header);
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		if (defined $affy{$d[0]}){
			print join("\t", $affy{$d[0]}, @d),"\n";
		}
	}
}


# add the genesymbol to the GNFdata
sub add_gene_symbol{
	load_affy_id();
	load_gnf_id();
	open(INPUT, "GNF1Hdata_replicate_avg.txt")||die "cannot open file";
	my %allprobe = (%affy, %gnf);
	#print Dumper(\%allprobe);exit(1);
	my $header = <INPUT>;
	print join("\t", "symbol", $header);
	while(<INPUT>){
		next if /^#/; chomp; next if /^NM_/;
		my @d = split(/\t/);
		# does the gene symbol exist?
		if (defined $allprobe{$d[0]}) {
			print $allprobe{$d[0]},"\t";		
			print join("\t", @d),"\n";
		} 
	}
}

# hash of affyid to symbol, ignore AFFX probes
sub load_affy_id{
	my $dbh = DBI->connect('dbi:mysql:database=symatlas;host=localhost', 'root', 'smith1', {RaiseError=>1});
	my $results = $dbh->selectall_arrayref("select probe_id,symbol from affy_id_symbol where probe_id not like 'AFFX%' and symbol !=''");
	%affy = map { $_->[0] => $_->[1] } @$results;
	#print Dumper(\%affy);
}

# hash of gnfid to symbol, ignore affy probes
sub load_gnf_id{
	my $dbh = DBI->connect('dbi:mysql:database=symatlas;host=localhost', 'root', 'smith1', {RaiseError=>1});
	my $results = $dbh->selectall_arrayref("select probe_id,symbol from gnf1h_id_symbol where probe_id like 'gnf%' and symbol!='' and symbol not like 'obsoleted%'");
	%gnf= map { $_->[0] => $_->[1] } @$results;
}

# do gnf and affy have overlapping keys?
# not if you use onnly gnf_ids (ignore affy on same chip)
sub test_overlapping_keys{
	foreach my $k (keys %gnf){
		if (defined $affy{$k}){
			print "$k overlaps\n";
		}
	}
}

# takes the inverted, replicate-averaged file and returns
# it to probes x tissue
sub uninvert_gnf{
	my @data = ();
	open(INPUT, "GNF1Hdata_invert_replicate_avg.txt") || die "cannot open replicate avg file";
	my $header = <INPUT>;
	chomp $header;
	my @header = split(/\t/, $header);
	while(<INPUT>){
		chomp; next if /^#/;	
		push @data, [ split(/\t/) ];
	}
	#invert the array
	for (my $i=0; $i< scalar @{$data[0]}; $i++){
		print $header[$i],"\t";
		for(my $j=0; $j< scalar @data; $j++) {
			print $data[$j]->[$i];
			if ($j != $#data){
				print "\t";
			}
		}
		print "\n";
	}
}


my %header2id=();
# convert raw data to rows=conditions, cols=genes
sub invert_gnf{
	my @data=();
	open(INPUT, "../GNF1Hdata.txt") || die "cannot open GNF1hdata";
	#open(INPUT, "../GNF1Hdata_subset.txt") || die "cannot open GNF1hdata";
	# get the header, bump off the file desc
	my $header = <INPUT>;
	chomp $header;
	$header =~ s/#//;
	my @header = split(/\t/, $header);
	shift @header;
	convert_header(\@header);
	# read into AoA
	while(<INPUT>){
		chomp;
		push @data,  [ split(/\t/) ];
	}
	#print Dumper(\@data);
	# invert, assign a number to each tissue
	for (my $i=0; $i< scalar @{$data[0]}; $i++){
		if ($i==0){
			print "probe\t";
		} else {
			#print $header[$i-1],"\t";
			print $header2id{$header[$i-1]},"\t";
		}
		for(my $j=0; $j< scalar @data; $j++) {
			print $data[$j]->[$i];
			if ($j != $#data){
				print "\t";
			}
		}
		print "\n";
	}
}

# create hash of GNF header
sub convert_header{
	my ($headerref) = @_;
	my $counter=1;
	foreach my $k (@$headerref){
		if (defined $header2id{$k}){
		} else {
			$header2id{$k} = $counter++;
		}
	}
	#print Dumper(\%header2id);
}

########## MAIN ####################

## invert the GNF1Hdata.txt file
#invert_gnf();

## univert the inverted, replicate_avg file
#uninvert_gnf();

## add the gene symbol the beginning
#add_gene_symbol();

## filter only the affy<->ilmn gene symbols
filter_gene_symbol_by_affy();
