#!/usr/bin/perl -w
#check for duplicate probes in CGH data
open(INPUT, $ARGV[0]) || die "cannot open file for read\n";
%data = ();
while(<INPUT>){
	next if /^#/;
	my ($chr, $pos) = split(/\t/);
	my $key = join(":", $chr, $pos);
	if (exists $data{$key}){
		$data{$key}++ 
	} else {
		$data{$key} =1 ;
	}
}
foreach $k  (keys %data){
	if ($data{$k} > 1){
		print "$k\t$data{$k}\n";
	}

}
