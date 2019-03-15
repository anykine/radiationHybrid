#!/usr/bin/perl -w
#
open(INPUT, "ilmn_goodpos.txt");
while(<INPUT>){
@line = split(/\t/);

$pos{$line[1].":".$line[2]}++;
}

print scalar (keys %pos);
