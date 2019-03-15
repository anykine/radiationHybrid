#!/usr/bin/perl -w
#create the header after the sort step
#chr start stop c1 c2 ... cN 
# read in the cgh.config file

open(INPUT, $ARGV[0]);
while(<INPUT>){
	next if /^#/;
	chomp;
	push @rhs, (split(/,/))[1];
}

print "chr\tstart\tstop\t";
@cols = map {"c".$_} sort {$a<=>$b} @rhs;
print join("\t", @cols), "\n";
