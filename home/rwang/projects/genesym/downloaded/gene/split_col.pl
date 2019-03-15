#!/usr/bin/perl -w

unless (@ARGV == 2){
	print <<EOH;
	usage: $0 <file to split> <column of synonyms to split>
	 e.g. $0 gene_info.9606.synonym 4 
	
	Split the gene_info synonym file into one synonym per line.
	Column 3 contains a dash. Column number is 0-based.
EOH
exit(0);
}
use strict;
open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @data = split(/\t/);
	my @splitcol = split(/\|/,$data[$ARGV[1]]);
	foreach my $i(@splitcol){
		#skip if no synonym
		next if $i eq '-';
		#syns are the last col
		# get rid of the dash column (#3,locus tag value?)
		print join("\t",@data[0..$ARGV[1]-2] );
		print "\t$i\n";
	}
}
