#!/usr/bin/perl -w

# expand the corners to create list of all points

open(INPUT, "dog.csv") or die "cannot open file for read\n";
while(<INPUT>){
	my @data = split(/\t/);
	for (my $i=$data[0]; $i<=$data[2]; $i++){
		for (my $j = $data[1]; $j<=$data[3]; $j++){
			print "$i,$j\n";			
		}
	}
}
