#!/usr/bin/perl -w
#
open(INPUT, $ARGV[0]);
while(<INPUT>){
print $.,"\t";
print $_;
}
