#!/usr/bin/perl

unless (@ARGV == 1) {
	print <<EOH;
	usage $0 <line to count>

	this counts line that are not blank
EOH
exit(1);
}
open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
$count =0;
while(<INPUT>){
	next if /^\n$/;
	$count++;
}
print "nonblank line count: $count\n";
