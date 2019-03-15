#!/usr/bin/perl -w

open(INPUT, "$ARGV[0]") or die "cannot open file\n";
while($line = <INPUT>){
	next if $line !~ /^ MGI/;
	my($acc,$ch,$pos,$sym,$syn) = ($line=~ /^\s(MGI\:\d+)\s+(\S+)\s+(\S+)?\s+(\S+)\s+(.+?)\s+$/ig);
	print "$acc\t$ch\t$pos\t$sym\t$syn\n";
	#print "$acc\n$ch\n$pos\n$sym\n$syn\n";
}
