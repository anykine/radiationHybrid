package g3datamanipT;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&read_g3headerT &get_g3recordT &get_g3records_by_markerT);
use strict;
use warnings;

#constants
use Fcntl ":seek";
use Data::Dumper;

#open our binary file
open(G3DATAFILET, "/media/G3data/invert/g3alpha_model_resultsT.bin") || die "cannot open G3data binary file\n";

# get the header, return a hash
sub read_g3headerT{
	my $buffer;
	my $headersize = 32;
	my %header=();
	#header is 32 bytes
	# - uint headersize
	# - char[8]
	# - uint num genes
	# - uint num markers
	# - u long int num entries (8bytes), but this doesn't work well, so i use 2 ints
	my $headerFORMAT = "I A8 I2 I2";
	#position at beg of file
	seek(G3DATAFILET, 0, SEEK_SET) or die "Seeking $!";
	read(G3DATAFILET, $buffer, $headersize);
	my @fields = unpack($headerFORMAT, $buffer);
	#dump
	$header{headersize} = $fields[0];
	$header{filetype} = $fields[1];
	$header{num_genes} = $fields[2];
	$header{num_markers} = $fields[3];

	return(%header);	
}

# obtain a gene-marker pair of data
# return a hash
sub get_g3recordT{
	my ($gene,$marker) = @_;
	my %record=();
	my $buffer;
	my $recsize = 20;
	# record is 20 bytes
	# -int gene id
	# -int marker id
	# -float mu
	# -float alpha
	# -float neg log pval
	my $recFORMAT = "I2 f3";
	#comute the linear address of marker-gene
	#my $address = 32+$recsize*(($gene-1)*235829+$marker-1);
	my $address = 32+$recsize*(($marker-1)*20996+$gene-1);
	seek(G3DATAFILET, $address, SEEK_SET) or die "Seeking $!";
	read(G3DATAFILET, $buffer, 20);
	my @fields = unpack($recFORMAT, $buffer);
	#foreach my $i (@fields){
	#	print $i,"\n";
	#}
	#print join("\t", @fields), "\n";
	$record{gene_id} = $fields[0];
	$record{marker_id} = $fields[1];
	$record{mu} = $fields[2];
	$record{alpha} = $fields[3];
	$record{nlp} = $fields[4];
	return (%record);
}


# get all genes' data for one specified CGH marker
# return as array ref
sub get_g3records_by_markerT{
	my ($marker) = @_;
	my $buffer;
	my $recsize = 20;
	# record is 20 bytes
	# -int gene id
	# -int marker id
	# -float mu
	# -float alpha
	# -float neg log pval
	my $NUMGENES = 20996;
	my @records=();
	#preallocate records
	$#records = $NUMGENES;
	my $recFORMAT = "I2 f3";
	#comute the linear address of marker-gene
	#my $address = 32+$recsize*(($gene-1)*235829+$marker-1);
	my $address = 32+$recsize*(($marker-1)*20996);
	seek(G3DATAFILET, $address, SEEK_SET) or die "Seeking $!";
	for (my $i=0; $i<$NUMGENES; $i++){
		read(G3DATAFILET, $buffer, 20);
		my @fields = unpack($recFORMAT, $buffer);
		$records[$i] = {
			gene_id => $fields[0],
			marker_id => $fields[1],
			mu => $fields[2],
			alpha => $fields[3],
			nlp => $fields[4]
		};
	}
	return (\@records);
}
1;

=head1 NAME

g3datamanipT - get data out of the binary version of I<g3alpha_model_resultsT.bin> file which
is the raw data from the linear model sorted by marker (not gene number)!

=head1 SYNOPSIS

There are 235829 markers and 20996 genes. However, this set is sorted
as (transposed):
 gene1 marker1
 gene2 marker1
 ...   ...
 gene20996 marker235828
 gene20996 marker235829

Think of it as 235829 rows and 20996 cols. 

 # read the 32 byte header, returns hash 
 
 my %header = read_g3header();

 $header{headersize} ;
 $header{filetype} ;
 $header{num_genes} ;
 $header{num_markers} ;

 # get a record, returns a hash

 my %record = get_g3recordT($gene, $marker);

 $record{gene_id} = $fields[0];
 $record{marker_id} = $fields[1];
 $record{mu} = $fields[2];
 $record{alpha} = $fields[3];
 $record{nlp} = $fields[4];

 # get all data for all genes for a given CGH marker.
 # Returns a reference to an array of hashes that is 20996 long.

 $aref = get_g3records_by_markerT($marker);
 $aref->[0]{gene_id}
 $aref->[0]{marker_id}
 $aref->[0]{alpha}
 $aref->[0]{nlp}

=head1 AUTHOR

Richard Wang

