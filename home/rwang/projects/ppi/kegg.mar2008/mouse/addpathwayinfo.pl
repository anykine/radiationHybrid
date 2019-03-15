#!/usr/bin/perl -w
use strict;

#quick and dirty. Sangtae asked to append the pathway file number
#into a 4th column of the KEGG pathways output I provided.
my @files = <*.xml.out>;
my $prefix ;
#print "@files\n";exit(1);
foreach my $f (@files){
	$prefix = substr($f, 0, 3);
	print $prefix, "\n";
	(my $pathway) = ($f =~ /\w{3}(\d+)\.xml\.out/);
	print "f=$f path=$pathway\n";
	open(INPUT, $f) || die "cannot open file $f\n";
	open(OUTPUT, ">$f.new") || die "cannot open file $f.new\n";
	while(<INPUT>){
			chomp;
			print OUTPUT "$_\t$pathway\n";
	}
	close(INPUT);
	close(OUTPUT);
}

