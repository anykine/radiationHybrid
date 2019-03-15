package g3datamanip;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&read_g3header &get_g3record &get_g3records_by_gene);
use strict;
use warnings;

#constants
use Fcntl ":seek";
use Data::Dumper;

#open our binary file
open(G3DATAFILE, "/media/G3data/g3alpha_model_results1.bin") || die "cannot open G3data binary file\n";

# get the header, return a hash
sub read_g3header{
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
	seek(G3DATAFILE, 0, SEEK_SET) or die "Seeking $!";
	read(G3DATAFILE, $buffer, $headersize);
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
sub get_g3record{
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
	my $address = 32+$recsize*(($gene-1)*235829+$marker-1);
	seek(G3DATAFILE, $address, SEEK_SET) or die "Seeking $!";
	read(G3DATAFILE, $buffer, 20);
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

# get all cgh markers' data for one gene
# and return as array ref
sub get_g3records_by_gene{
	my ($gene) = @_;
	my $buffer;
	my $recsize = 20;
	# record is 20 bytes
	# -int gene id
	# -int marker id
	# -float mu
	# -float alpha
	# -float neg log pval
	my $NUMMARKERS= 235829;
	# use an array of hashes
	my @records=();
	# preallocate size of array
	$#records = $NUMMARKERS;
	my $recFORMAT = "I2 f3";
	#comute the linear address of marker-gene
	my $address = 32+$recsize*(($gene-1)*235829);
	seek(G3DATAFILE, $address, SEEK_SET) or die "Seeking $!";
	for (my $i = 0; $i< $NUMMARKERS; $i++){
		read(G3DATAFILE, $buffer, 20);
		my @fields = unpack($recFORMAT, $buffer);
		$records[$i] = {
			gene_id => $fields[0],
			marker_id => $fields[1],
			mu => $fields[2],
			alpha => $fields[3],
			nlp => $fields[4]
		};
	}
	# return reference to array of hashes
	return (\@records);
}
1;

=head1 NAME

g3datamanip - get data out of the binary version of I<g3alpha_model_results1.bin> file which
is the raw data from the linear model

=head1 SYNOPSIS

There are 235829 markers and 20996 genes. Logically, the data is laid out
as 20996 rows and 235829 columns.

 # read the 32 byte header, returns hash 
 
 my %header = read_g3header();

 $header{headersize} ;
 $header{filetype} ;
 $header{num_genes} ;
 $header{num_markers} ;

 # get a record, returns a hash

 my %record = get_g3record($gene, $marker);

 $record{gene_id} = $fields[0];
 $record{marker_id} = $fields[1];
 $record{mu} = $fields[2];
 $record{alpha} = $fields[3];
 $record{nlp} = $fields[4];

 # get all CGH alphas, -log p, etc for a given gene.
 # returns a reference to array of hashes that is 235829 long.

 my $aref = get_g3records_by_gene($gene);
 $aref->[0]{gene_id}
 $aref->[0]{marker_id}
 $aref->[0]{alpha}
 $aref->[0]{nlp}

=head1 AUTHOR

Richard Wang

