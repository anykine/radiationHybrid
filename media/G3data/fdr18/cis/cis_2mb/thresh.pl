#!/usr/bin/perl -w

open(INPUT, $ARGV[0]);
while(<INPUT>){
	chomp;
	@d = split(/\t/);
	print join("\t",@d),"\n" if $d[4] > $ARGV[1] ;
}
