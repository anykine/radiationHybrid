#!/usr/bin/perl -w
#
# stitch together the g3outputN.txt files into a giant list
#
use strict "vars";
use Data::Dumper;

my @files=();
my @filehandles=();

# create array of file handles
for (my $i=1; $i<= 70; $i++){
	# localize file to inner loop
	local *FILE;
	open(FILE, "g3output$i.txt") || die "cannot open file $i\n";
	# push typeglob onto array
	push @filehandles, *FILE;
}

# do this for every marker
for (my $m = 0; $m < 235829; $m++){
	# for each file, except the last
	for (my $j=0; $j<$#filehandles; $j++){
		my $fh = $filehandles[$j];
		#print 300 lines from each file
		for (my $c=1; $c<=300; $c++){
			my $line = <$fh>	;
			print $line;
		}
	}
	# do last chunk separately
	my $fh = $filehandles[$#filehandles];
	for (my $c=1; $c<=296; $c++){
		my $line = <$fh>;
		print $line;
	}
}
