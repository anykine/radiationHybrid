#!/usr/bin/perl -w

#take the output of the chisq data and assemble a bit
# matrix of 1's and 0's.
# 1 if pval < 1.0e-8
#
# first row will have N elements
# second row will have N-1 elements...
# When outputting final data, need to fill in the beginning
# of the next line with symmetrical elements from prev line(s)
use strict;

my $vector= {};  # reference to store the final data
my $limit = 9581;
my $count = 0;   #track which file data pair we're on
my $cur = 0;     #cur data array row

#this file is 1-9580 (not 0-9579) only highpvals
my $file = "/home2/rwang/projects/g3rh/data0/g3pvals_e10smaller_060615.txt";
open(INPUT, $file) or die "cannot open file!\n";
while(<INPUT>){
	next if /^marker/;
	chomp;
	#$data[0] contains marker1
	#$data[1] contains marker2
	#$data[2] contains the pvals
	my @data = split(/\t/);
	#if ($data[2] < 1e-08) {
		$vector->{$data[0]}{$data[1]} = 1;
	#} else {
	#	$vector->{$data[0]}{$data[1]} = 0 ;
	#}
}

#printtest(2,6);
#printtest(2,5);
printall();

######## SUBS ###################3
sub printall{
	#for(my $i =1 ; $i<=50; $i++){
	# mark sure to start with 1!!!!
	for(my $i =1 ; $i<=9580; $i++){
		for(my $j =1 ; $j<=9580; $j++){
			if (exists ($vector->{$i}) && exists ($vector->{$i}{$j}) ) {
				print $vector->{$i}{$j}; 
			} else {
				print 0;
			}
		}
		print "\n";
	}
}

sub printtest{
	my($k1, $k2) = @_;
	if (exists ($vector->{$k1}) && exists ($vector->{$k1}{$k2})) {
		print "k1=$k1, k2=$k2 vec=$vector->{$k1}{$k2}\n";
	} else {
		print "nothing found\n";
	}
}
