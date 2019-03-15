#!/usr/bin/perl -w
# Richard Wang 10/21/05
# this thing takes list of matrices and calculates chisq pval for each
# based on matrix.pl script in RSPerl in examples/
# match, convert is the match and conversion functions
# for R <-> Perl, which we do not use here but might
# be useful in the future

use R;
use RReferences;
use lib '/home/rwang/lib';
use strict;
use warnings;
use util;
use Data::Dumper;

sub convert {
    my $obj = shift;
    my $type = R::call("typeof", $obj);
    my @dim = R::call("dim", $obj);
    my @values = R::call("as.vector", $obj);
		print "Converted matrix: ", $dim[0], ", ", $dim[1], " ", $#values, "\n";

    return(@values);
    #return($values);
}


#********************start here************************
unless($ARGV[0]) {
	print "usage $0 <rhvector file>\n";
	exit;
}


open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
my $outfile = $ARGV[0] . ".chisq";
open(OUTPUT, ">$outfile") or die "cannot open file or ouput\n";
#my @raw = get_file_data($ARGV[0]);

##start R##
&R::startR("--silent", "--vanilla");
R::library("RSPerl");

##pass in parm
#my $end = $#raw;
while(<INPUT>) {
#for (my $i=0; $i<=$end; $i++) {
	my @ar = split(/\s+/, $_);
	my @input = ($ar[0]*1,$ar[1]*1,$ar[2]*1,$ar[3]*1) ;
	#my @input=(58,28,71,92);
	#print "@ar\n";
	#print "@input\n";
	my $var = &R::matrix(\@input,2,2);
	#chisq.test(matrix, null, correct=false)
	my $res = &R::call("chisq.test",$var,0,0);
	print OUTPUT "m1=$ar[4] m2=$ar[5] :". $res->getEl('p.value')."\n";
}

close INPUT;
close OUTPUT;

