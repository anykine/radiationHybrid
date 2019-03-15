#!/usr/bin/perl -w

# filter vista for score of 900 (=positive enhancer)
# score of 200 (= negative enhancer)
open(INPUT, "vista.txt")
while(<INPUT>){
	next if /^#/;
	my @d = split(/\t/); 
	pri
}
