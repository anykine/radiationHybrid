#!/usr/bin/perl -w

# some of the gene names have spaces/etc that confuse R
unless (@ARGV==1){
	print "usage $0 <ucscgene_FDRNN_groups.txt>\n";
	exit(1);
}
open(INPUT, $ARGV[0]) || die ;
while(<INPUT>){
	chomp; next if /^#/;
	my @d = split(/\t/);
	#print $_,"\n" if (scalar @d != 3);
	#special cases i changed
	$d[2] =~ s/BAI 2/BAI2/g ;
	$d[2] =~ s/ABCA4 variant protein/ABCA4/g ;
	$d[2] =~ s/ARID4B variant protein/ARID4B/g ;
	$d[2] =~ s/eIF2B delta subunit/eIF2B/g ;
	$d[2] =~ s/ $//g;
	$d[2] =~ s/ /_/g;
	#upper case all gene names
	$d[2] = uc($d[2]);
	print join("\t", @d),"\n";
	#print $d[2],"\n";
}
