#!/usr/bin/perl -w

open(INPUT, $ARGV[0]) or die "cannot open file for read\n";
<INPUT>;
while(<INPUT>){
	my @data = split(/\t/);
	$data[2] =~ s/GI_//ig;
	$data[3] =~ s/GI_//ig;
	$data[4] =~ s/\.\d+//;

	print join("\t", @data);
}
