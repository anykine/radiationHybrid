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

my $vector= [];  #store the final data
my $limit = 9581;
my $count = 0;   #track which file data pair we're on
my $cur = 0;     #cur data array row

open(INPUT, "$ARGV[0]") or die "cannot open file!\n";
while(<INPUT>){
	chomp;
	#$data[1] contains the pvals
	#$data[0] contains marker1, marker2
	my @data = split(/:/);
	#$data[0] =~ s/m\d=//g;
	#my @index = split(/ /, $data[0]);

	if ($count < $limit ) {
		print "$data[1]\n";
		if ($data[1] < 1e-08) {
			keeptrack($cur, 1);
		} else {
			keeptrack($cur, 0);
		}
	} else {
		#limit has been reached, reset vars
		$count = 0;
		$limit--;
		$cur++;
	}


	$count++;
}

sub keeptrack{
	my($cur, $val) = @_;
	push @{$vector->[$cur]}, $val;
}

sub printall{
	for(my $i =0 ; $i<9580; $i++){
		for(my $j =0 ; $j<9580; $j++){
			if (defined $vector->[$i][$j]) {
				print $vector->[$i][$j]; 
			} else {
				print 0;
			}
		}
		print "\n";
	}
}
