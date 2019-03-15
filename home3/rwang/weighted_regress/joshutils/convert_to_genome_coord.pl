#!/usr/bin/perl -w

$t="\t";
$n="\n";
use Data::Dumper;
#RW edits, changed input to argv
#relocated utility files 
unless(@ARGV==1){
	print <<EOH;
	usage $0 <input file to convert>
	
	this takes a file with chromosome/basepair coords in the first 2 cols
	and converts to genome coords
EOH
exit(1);
}
# (to be don) : need to add a switch to plot position of gene being regulated
#$usage="usage: plot.pl <input_genefile> <G (for genome), C (for chromosome), or P (for peak)> <chr(opt.)> <bp_pos(opt.)> <radius(opt.)>\n ";
$gctable="genome_conversion_table_mm7.txt";
$cghtable="new_cgh_index.txt";
$exptable = "mm7_probes_bed.txt"; 

$genefile = $ARGV[0];
$tempfile = $genefile."converted";


%gc=(); %cgh=(); %exp=();
build_genome_conversion_hash (\%gc, $gctable);
build_cgh_index 			 (\%cgh, $cghtable);
build_exp_index 			 (\%exp, $exptable);
convert_to_genome_coord 	 ($genefile, $tempfile); #takes inputfile and outputfile

sub build_genome_conversion_hash {
	print "Building Genome Conversion Table...\n";
	$href=shift;
	# This reads in chromosome to genome conversion table for mm7
	$file=shift;
	open(HANDLE, $file) or die "can't open $file \n $usage";
	while( <HANDLE> ) {
		chomp $_;	
		($chr, $correct	)= split ("\t", $_);	
		$href->{$chr}=$correct;
	}
	close HANDLE;
}

sub build_cgh_index { 
	print "Building index of CGH probe locations...\n";
	$href=shift;
	$file=shift;
	open(HANDLE,$file) or die "can't open file \n $usage";
	$index=1;
	while(<HANDLE>) {
		chomp $_;
		($chr, $start, $stop )=split( "\t", $_);
		$href->{$index}{chr}=$chr;
		$href->{$index}{start}=$start;
		$href->{$index}{gc}=$start+$gc{$chr};
		$index++;
	}
	close(HANDLE);
}

sub build_exp_index {
	print "Building index of gene expression probe locations...\n";
	$href=shift;
	$file=shift;
	open(HANDLE, $file) or die "can't open $file \n $usage ";
	$index=1;
	while (<HANDLE> ) {
		chomp $_;
		($chr, $start, $stop, $oldindex) = split("\t" , $_);
		$href->{$index}{chr}=$chr;
		$href->{$index}{start}=$start;
		$href->{$index}{gc}=$gc{$chr}+$start;
		$index++;
	}
	close (HANDLE);
}




sub convert_to_genome_coord {
	print "Converting Marker index to chromosome and genome positions...\n";
	$infile=shift;
	$outfile=shift;
	open(OUTPUT, ">$outfile") or die "can't open $outfile \n $usage";
		open(HANDLE, $infile) or die "can't open $infile \n $usage";
		while(<HANDLE>) {
		chomp $_;
		#for reading in refseq data
		#	($gene, $chr, $s, $e)= split("\t", $_);
		#	$start=$gc{$chr}+$s;
		#$end=$gc{$chr}+$e;
		#		print OUTPUT $gene.$t.$start.$t.$end.$n;
		#
		($gene, $marker, $alpha,$nlp) = split ("\t" , $_);
		print OUTPUT $cgh{$marker}{gc}.$n;
	
		}
	close HANDLE;
	close OUTPUT;
}





