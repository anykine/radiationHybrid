#!/usr/bin/perl -w
#
# parse the mus2human_closest.txt - this shows the 
# closest human marker to a mouse lifted over marker.
# We want only unique human markers, so (randomly) pick one unique human
# marker if there are multiple ones and its associated
# mouse marker.
# 

my %hum2musmarkers=();

# get common markers
sub get_mus_hum_markers{
	open(INPUT, "mus2human_closest.txt") || die "cannot open mus2hum\n";
	while(<INPUT>){
		chomp;
		my @line = split(/\t/);
		#$mus2hum{$line[3]} = $line[5];
		# pick unique hum markers, map to mus
		# human marker id is the key, val is mouse marker id
		$hum2musmarkers{$line[5]} = $line[3];
	}
}

############ RUN ##############

# get common markers
get_mus_hum_markers();
#print Dumper(\%hum2musmarkers); exit(1);
my $counter=0;

# 
print "#hum markerid\tmus markerid\n";
foreach my $k (sort {$a<=>$b} keys %hum2musmarkers){
	print "$k\t$hum2musmarkers{$k}\n";
}
