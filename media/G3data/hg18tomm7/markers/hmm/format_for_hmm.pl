#!/usr/bin/perl -w
#
# format the mouse orig and mouse pseudomarker chrom position data for HMM
#

# these are the mouse pseudomarkers that will be filled in by HMM
# chrom | start | stop | index
open(INPUT, "../hum2mus_markers_imputed.bed") || die "cannot open file1\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	# chrom | cp | 1=psuedo or 0=orig | index
	next if $line[0] =~ /M|random/;
	print join("\t", $line[0], $line[1], 1, $line[3]), "\n";
}
close(INPUT);

# these are the moues orig markers
# this is training data to HMM
open(INPUT, "/media/G3data/mm7tohg18/markers/mouse_cgh_pos.bed") || die "cannot open file2\n";
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	# chrom | cp | 1=psuedo or 0=orig | index
	next if $line[0] =~ /M|random/;
	print join("\t", $line[0], $line[1], 0, $line[3]), "\n";
}
