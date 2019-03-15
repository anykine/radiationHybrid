#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

# find the closest CGH index to the binned index to compare
# GMM versus the greater than 0.176 method

#cgh
my %cgh=();
sub load_cgh_data{
	open(INPUT,"mouse_cgh_pos.txt") || die;
	while(<INPUT>){
		chomp;
		# format is chrom | pos | index
		my @line = split(/\t/);
		push @{$cgh{$line[0]}{pos}}, $line[1];
		push @{$cgh{$line[0]}{idx}}, $line[2];
	}
	close(INPUT);
}

# use binned (basically PCR) as scaffold
sub find_nearest{
	open(INPUT, "fixed_binned_scaled_pos.txt") || die;
	<INPUT>;
	while(<INPUT>){
		chomp;
		#formt oldidx | newidx | chr | star | end
		my @line = split(/\t/);
		$line[2] =~ s/chr//;
		$line[2] =~ s/^0//;
		$line[2] =~ s/^X/20/;
		$line[2] =~ s/^Y/21/;
	
		#now serach for closest
		my $closest= 0;

		for (my $i=0; $i< scalar @{$cgh{$line[2]}{pos}} ; $i++){
			my $pos = ($line[3]+$line[4])/2;
			if (abs($pos - ${$cgh{$line[2]}{pos}}[$i]) < abs($pos - ${$cgh{$line[2]}{pos}}[$closest]) ){
				$closest = $i;
			}
		}
		#oldidx | newidx | chr | star|end| closest cgh marker
		print join("\t",@line), "\t${$cgh{$line[2]}{idx}}[$closest]\n";
	}
}




load_cgh_data();
#print Dumper(\%cgh);
find_nearest();
