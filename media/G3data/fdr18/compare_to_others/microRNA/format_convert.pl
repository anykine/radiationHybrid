#!/usr/bin/perl -w
#
# Convert one txt format to another
#
use strict;

sub mirBase_gff2bed{
	my ($file, $species) = @_;
	open(INPUT, $file) || die "cannot open $file";
	while(<INPUT>){
		chomp; next if /^#/;
		my @data = split(/\t/);
		if ($data[0] eq 'X'){
			$data[0] = "chrX";
		} elsif ($data[0] eq 'Y'){
			$data[0] = "chrY";
		} else {
			$data[0] = "chr".$data[0];
		}
		print join("\t", $data[0], $data[3], $data[4]),"\n";
	}
}



######### MAIN #############3
unless (@ARGV ==1 ){
	print "Usage $0 <file>\n";
	exit(1);
}

mirBase_gff2bed($ARGV[0]);
