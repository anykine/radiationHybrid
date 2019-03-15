package t31datamanip;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(&open_t31file &get_t31record);
use strict;
use warnings;

#constants
use Fcntl ":seek";
use Data::Dumper;

#open our binary file
sub open_t31file{
	my ($type) = @_;
	my $fh;
	if ($type eq 'nlp'){
		open($fh, "/media/G3data/mouse_data/nlp_perm_grid.bin") || die "cannot open nlp binary file\n";
	} elsif ($type eq 'alpha'){
		open($fh, "/media/G3data/mouse_data/alp_grid_scaled.bin") || die "cannot open alpha binary file\n";
	}
	return $fh;
}
 
# currently UNUSED, no header in file
# get the header, return a hash
sub read_t31header{
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
sub get_t31record{
	my ($gene,$marker, $fh) = @_;
	my $recsize = 4;
	my $buffer;
	# record is 20 bytes
	# -int gene id
	# -int marker id
	# -float mu
	# -float alpha
	# -float neg log pval
	my $recFORMAT = "f";
	#comute the linear address of marker-gene
	my $address = $recsize*(($marker-1)*20145+$gene-1);
	seek($fh, $address, SEEK_SET) or die "Seeking $!";
	read($fh, $buffer, $recsize);
	my $value = unpack($recFORMAT, $buffer);
	#foreach my $i (@fields){
	#	print $i,"\n";
	#}
	#print join("\t", @fields), "\n";
	return ($value);
}

1;

=head1 NAME

t31datamanip - get data out of the binary version of I<nlp_perm_grid.bin> or I<alp_grid_scaled.bin> file 
of T31 mouse data

=head1 SYNOPSIS

There are 232626 markers and 20145 genes. 

 # first open file, determine file type, get a filehandle
 
 my $filehandle = open_t31file('alpha');
 my $filehandle = open_t31file('nlp');

 # get a value based on gene, marker, filehandle
 # the value is the float nlp/alpha of interest
 my $record = get_t31record($gene, $marker, $filehandle);


=head1 AUTHOR

Richard Wang

