#!/usr/bin/perl -w
#
# Using my normalized gene expression from analyze2, get the columns
# from the file that have matching CGH data. The analyze2 normalized data
# has 240 cell lines, but the CGH has 219, so we have to match them up again
# to get only those cell lines in common between CGH and EXPR
use strict;
use Data::Dumper;

my %matchlist = (); #store the TCGA ID's

# Need a list of CGH files (self normalized)
#just read it in from CGH header
sub get_match_samples{
	open(INPUT, "/media/usbdisk/tcga/cgh/level1/cghcall/header") || die "err $!";
	%matchlist = map { chomp; s/\./-/g;  $_ => 1;	} 
									grep { /TCGA/ }
									split(/\t/, <INPUT>);
	#print Dumper(\%matchlist);
}

# Need to find those columns of EXPR which match CGH files
# extract the relevant columns
sub extractEXPR{
	# read the first line to determine which columns to keep, add chrom/start/end/symbol cols
	my @cols = ();
	push @cols, 0..3;
	open(INPUT, "/media/usbdisk/tcga/analyze2/all.expr.merged.sorted.txt") || die "err $!";
	#my @header = grep { s/\.CEL//g } split(/\t/, <INPUT>);
	# why you have the local/lexical variable is complex
	# see: http://www.perlmonks.org/index.pl?node_id=613280
	my @header = map { my $s = $_; $s  =~ s/.CEL//; $s } split(/\t/, <INPUT>);
	for (my $i=0; $i<=$#header; $i++){
		if (exists $matchlist{ $header[$i] }  ){
			push @cols, $i;
		}
	}
	#foreach my $k (@cols) { print $k,"\n"; }
	
	# Extract the relevant columns
	print join("\t", @header[ @cols ]),"\n";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		print join("\t", @d[ @cols ]),"\n";
	}
}

############ MAIN ############3
get_match_samples();
extractEXPR();
