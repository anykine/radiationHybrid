#!/usr/bin/perl -w

$a = "Spermophilus tridecemlineatus (Thirteen-lined ground squirrel).";

$a =~ s/\(.*\)\.//;

print $a;
