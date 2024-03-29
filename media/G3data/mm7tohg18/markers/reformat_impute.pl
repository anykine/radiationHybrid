#!/usr/bin/perl -w
#
use strict;

# reformat the mouse_revlo95_impute.txt file into the same
# format as generated by liftover ie mus2hum_markers_imputed.bed
#
unless (@ARGV==1){
	print <<EOH;
	usage $0 <mouse_revlo95_match.txt>
	 Formats a file nicely. Orig marker (eg mouse) and its new liftover/imputed
	 position (eg onto human). 
	 Format: liftover/imputed chr|start|stop|orig CGH markerID

EOH
exit(1);
}
open(INPUT, $ARGV[0]) || die "cannot open impute file\n";
my $id=1;
while(<INPUT>){
	chomp;
	my @line = split(/\t/);
	#ea line is at least 8 long
	if (scalar @line > 7){
		print "$line[7]\t$line[8]\t";
		# liftovered
		if (scalar @line == 11){
			print "$line[9]\t";
		#imputed
		} else {
			print "$line[8]\t";
		}
		#marker id
		print "$id\n";
		#print $.,"\n";
	#we should never get here
	} else {
		#print "skipping\n";
	}
	$id++;
}
