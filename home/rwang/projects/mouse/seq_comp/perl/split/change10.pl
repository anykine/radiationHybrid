#!/usr/bin/perl -w

open INPUT, "debug2.txt" or die "cannot oopen file\n";

while(<INPUT>){
	s/\|/1/ig;
	s/x/0/ig;
	@arr = split(//);
	print join(",", @arr);
}
