#!/usr/bin/perl -w
#
# Extract data from MOUSE binary file
#  and output alphas, nlp associated with a specified marker

#constants
use Fcntl ":seek";
use strict ;
use lib '/home/rwang/lib/';
use Data::Dumper;

my $headersize = 32;
my $num_genes=0;
my $num_markers=0;
my $buffer;
my $address=0;
#seek(INPUT, $address, SEEK_SET) or die "Seeking $!";
#read(INPUT, $buffer, 32);

# goto loc and get the header
sub read_header{
	my $buffer;
	#header is 32 bytes
	# - uint headersize
	# - char[8]
	# - uint num genes
	# - uint num markers
	# - u long int num entries (8bytes), but this doesn't work well, so i use 2 ints
	my $headerFORMAT = "I A8 I2 I2";
	#position at beg of file
	seek(INPUT, 0, SEEK_SET) or die "Seeking $!";
	read(INPUT, $buffer, $headersize);
	my @fields = unpack($headerFORMAT, $buffer);
	#dump
	#foreach my $i (@fields){ 
	#	print $i,"\n";
	#}
	$num_genes = $fields[2];
	$num_markers= $fields[3];
}

# obtain a gene-marker pair of data
sub get_record{
	my $recsize = 4;
	my ($gene,$marker) = @_;
	# record is 20 bytes
	# -int gene id
	# -int marker id
	# -float mu
	# -float alpha
	# -float neg log pval
	my $recFORMAT = "f";
	#comute the linear address of marker-gene
	my $address = $recsize*(($marker-1)*20145+$gene-1);
	seek(INPUT, $address, SEEK_SET) or die "Seeking $!";
	read(INPUT, $buffer, $recsize);
	my $value = unpack($recFORMAT, $buffer);
	#foreach my $i (@fields){
	#	print $i,"\n";
	#}
	#print join("\t", @fields), "\n";
	return ($value);
}

##### MAIN ##############
unless (@ARGV== 2){
	print <<EOH;
	usage $0 <binary file> <marker to extract>
	$0 alp_grid_scaled.bin 100
	Extract the alphas/nlps for a specific marker from binary files
EOH
exit(1);
}

open(INPUT, "$ARGV[0]") || die "cannot open binary file\n";
#read_header();
#get_record(1, 100);

for (my $i=1; $i<=20145; $i++){
	my $val = get_record($i, $ARGV[1]);
	print $val,"\n";
}

#my $buff;
#seek(INPUT, 8, SEEK_SET);
#read(INPUT, $buff, 4);
#my $val = unpack("f", $buff);
#print $val,"\n";
