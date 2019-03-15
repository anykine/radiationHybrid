#!/usr/bin/perl -w

# process the mus2human_closest.txt file
#
# create mapping of one-mouse-to-one-human marker.
# Every mouse has a human assigned to it, but some human markers
# are duplicated. So here, we take each unique human marker as key
# and assign a mouse marker to it.
#
use strict;
use Data::Dumper;

my %mus2hum = ();
my %hum2mus = ();

# pass in file name and column locs of file
sub readfile{
	my ($file, $col) = @_;
	my %temp=(); #remember the best distance for a human marker
	open(INPUT, $file) || die "cannot open file for read\n";
	#open(INPUT, "mus2human_closest.txt") || die "cannot open file for read\n";
	while(<INPUT>){
		chomp;
		my @d=split(/\t/);
		# map the closest hum->mus
		if (defined $hum2mus{ $d[$col->{hummarker}] } ){
			if (abs($d[$col->{m2hstart}]-$d[$col->{humstart}]) < $temp{$d[$col->{hummarker}]}){	
				$temp{$d[$col->{hummarker}]} = abs($d[$col->{humstart}]-$d[$col->{m2hstart}]);
				$hum2mus{ $d[$col->{hummarker}] } = $d[$col->{musmarker}];
			}
		} else {
			$temp{$d[$col->{hummarker}]} = abs($d[$col->{humstart}]-$d[$col->{m2hstart}]);
			$hum2mus{ $d[$col->{hummarker}] } = $d[$col->{musmarker}];
		}
	}
}

sub avg{
	my ($aref)= @_;
	return (($aref->[0]+$aref->[1])/2);
}
#output list
sub output_list{
	#human_marker | mouse_marker
	foreach my $k (keys %hum2mus) {
		print "$k\t$hum2mus{$k}\n";
	}
}

sub readfile_orig{
	my ($file, $argref) = @_;
		open(INPUT, "mus2human_closest.txt") || die "cannot open file for read\n";
		while(<INPUT>){
			chomp;
			my @data = split(/\t/);
			# two options, we can take either the first instance,
			# the last instance, or some random instance. For
			# ease, I'm taking the last instance of a human marker
			if (defined $hum2mus{ $data[5] } ){
				$hum2mus{ $data[5] } = $data[3];
			} else {
				$hum2mus{ $data[5] } = $data[3];
			}
		}
}

##### MAIN #####
# describe the mus2hum_closest file
#my %args=(
#	lostart=>1, lostop=>2, musmarker=>3,
#	humstart=>4, hummarker=>5 
#);

# describe mus2human_noimpute_closest.txt
my %args=(
	m2hstart=>1, m2hstop=>2, musmarker=>3,
	humstart=>5, hummarker=>6 
);
readfile("mus2human_noimpute_closest.txt", \%args);
output_list();
