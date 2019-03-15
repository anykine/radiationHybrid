#!/usr/bin/perl


# -*-Perl-*-
# Last changed Time-stamp: <1998-06-27 21:46:25 ivo>
# reads the output from alidot or pfrali and edits an _ss.ps file as produced
# by RNAplot to include circles around bases with complentary mutations and
# gray letter for bases that are incompatible in some sequences. The original
# .ps file is renamed to .ps.bak (does not read from stdin!)
# The last argument should be the offset of the substructure in the _ss.ps file
# offset =  start_of_sequence-1

sub usage {
    die "Usage: $0 aln.out rna_ss.ps offset\n";
}

open(ALIOUT, "<$ARGV[0]") || &usage;
system("mv $ARGV[1] $ARGV[1].bak");   # backup the xrna.ss file
open(SSPS, "<$ARGV[1].bak") || &usage;
open(NSSPS, ">$ARGV[1]") || die("can't append to .ss file");

$offset = $ARGV[2];

while (<SSPS>) {
    last if (/^showpage/);
    print NSSPS $_; 
    if (/^\/pairs \[/) {$rpairs =1; next};
    if ((/^\] def/)&&($rpairs)) { # add definition for marks now
       $rpairs = 0;
       print NSSPS
	   "% extra definitions for anotations\n",
	   "/cmark {\n",
	   "   newpath 1 sub coor exch get aload pop\n",
	   "   fsize 2 div 0 360 arc stroke\n",
	   "} def\n",
	   "/gmark {\n",
	   "   1000000 div setgray 1 sub dup coor exch get aload pop moveto\n",
	   "   sequence exch 1 getinterval cshow\n",
	   "} def\n\n";
    }
    next unless ($rpairs);
    $_ =~ /^\[(\d+) (\d+)\]/;
    $pair[$1] = $2;
}

print NSSPS "[] 0 setdash\n";  # make sure dashs are not active

$_ = <ALIOUT>;
$_ = <ALIOUT>; # skip two lines
while (<ALIOUT>) {
    chomp;
    s/\*$//;  # remove trailing '*'
    ($i, $j, $nc, $p, $s, @pp) = split;
    next unless ($i>$offset && $j>0);
    $i -= $offset; $j -= $offset;
    next unless ($pair[$i]==$j);

    $ppair = shift @pp; # first element of @pp
    ($c01,$c02,$dummy) =  split(//,$ppair,3);
    $m1=$m2=0;
    foreach $ppair (@pp) {
	($c1,$c2,$dummy) =  split(//,$ppair,3);
	next if ($c1 eq '-');
	$m1=1 if ($c1 ne $c01);  # first base changes
	$m2=1 if ($c2 ne $c02);  # second base changes
    }
    # draw circles
    print NSSPS "$i cmark\n" if ($m1);
    print NSSPS "$j cmark\n" if ($m2);
    # use grayscale to imply nocompatible sequences
    if ($nc>0) {
	$gray = "333333";
	$gray = "666666" if ($nc>=2);
	$gray = "999999" if ($nc>=3);
	print NSSPS "$i $gray gmark\n";
	print NSSPS "$j $gray gmark\n";
    }
}
print NSSPS "showpage\nend\n%%EOF\n";
