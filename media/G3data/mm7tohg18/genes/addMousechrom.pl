#!/usr/bin/perl -w

# add the mouse chrom to the human coords for each probe

use strict;
use Data::Dumper;

unless (@ARGV==2){
	print <<EOH;
usage $0 <marker/gene coordinate file> <converted coord file>
 eg $0 mouse_gene_coordonly.bed mouse_hg18_coordonly.bed
 
 Adds the mouse source mouse chrom to the converted human
 coords for each gene/probe. Useful for generating graphs in syntenyPlot.
EOH
exit(1);
}
my %probe = ();

#store mouse chrom
#open(INPUT, "mouse_gene_coordonly.bed") || die "cannot open file1\n";
open(INPUT, $ARGV[0]) || die "cannot open file1\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	$line[0] =~ s/chrX/20/;
	$line[0] =~ s/chrY/21/;
	$line[0] =~ s/chr//;
	#filter our _unknown, chrM
	if ($line[0] =~ /^\d{1,2}$/){ 
		$probe{$line[3]} = $line[0];
	}
}
#print Dumper(\%probe);
close(INPUT);

#open(INPUT1, "mouse_hg18_coordonly.bed") || die "cannot open file2\n";
open(INPUT1, $ARGV[1]) || die "cannot open file2\n";
while(<INPUT1>){
	chomp;
	my @line = split(/\t/);
	#print moue chrom | human chrom | start | stop | name
	$line[0] =~ s/chrX/23/;
	$line[0] =~ s/chrY/24/;
	$line[0] =~ s/chr//;
	if ($line[0] =~ /^\d{1,2}$/ && defined $probe{$line[3]}) {
		print $probe{ $line[3] }, "\t";
		print join("\t", @line), "\n";
	}
}
close(INPUT1);
