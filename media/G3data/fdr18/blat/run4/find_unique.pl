#!/usr/bin/perl -w
#
# take the blat output and find the uniquest highest match
# per probe and use that as output
use strict;

my %pos=();
sub hashcount{
	my $file = shift;
	open(INPUT, $file) || die "cannot open file $file";
	while(<INPUT>){
		chomp;
		my @d = split(/\t/);
		if (defined $pos{$d[9]}){
			$pos{$d[9]} = $d[0] if $d[0] > $pos{$d[9]};
		} else {
			$pos{$d[9]} = $d[0];
		}
	}
}

sub iter_all_files{
	my $prefix = shift;
	for (my $i=1; $i<=21; $i++){
		hashcount($prefix.$i.".psl");
	}
}

sub output{
	foreach my $k (keys %pos){
		print "$k\t$pos{$k}\n";
	}
}
### MAIN ###

iter_all_files("cisneg_probe");
#iter_all_files("cispos_probe");
output();
