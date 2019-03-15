#!/usr/bin/perl -w
#
$string = "go_category: test test1 [goid]; go_function: crapola";
my ($word1, $word2) = $string =~ /(category|function): (.+) \[goid\]/; 
	print $word1,"\n";
	print $word2,"\n";
