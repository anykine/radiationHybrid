#1/usr/bin/perl -w
#
use strict;
use Data::Dumper;

my %mouse_marker_count=();
my %human_marker_count=();
my %common_markers=();

# count number of genes regulated by each marker 
sub count_mouse_regulating{
	open(INPUT, "mouse_trans_peaks_3.99.txt") || die ;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
			$mouse_marker_count{$d[1]}++;
	}
	#output_mouse_regulators();
}

sub output_mouse_regulating{
	foreach my $k (sort {$a<=>$b} keys %mouse_marker_count) {
		print "$k\t$mouse_marker_count{$k}\n";
	}
}

# load counts of regulators foreach gene from file
sub count_human_regulating{
	open(INPUT, "../../regulator_countFDR40.txt") || die ;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		$human_marker_count{$d[0]} = $d[2];
	}
}

# load common mouse-human gene index
sub load_common_marker_index{
	#open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/hum2mus_noimpute_closest_uniq.txt") || die;
	open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/hum2mus_closest_uniq.txt") || die;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		# key = mouse, value = human
		$common_markers{ $d[1] } = $d[0];
	}
	#print scalar (keys %common_genes),"\n";
}

# find the orth genes and print out
sub construct_correlation{
	
	print "#hum\thumcount\tmouse\tmousecount\n";
	#iter over common genes (human - mouse)
	while( my ($h, $m) = each (%common_markers)){
		if (defined $human_marker_count{$h} && defined $mouse_marker_count{$m}){
			print "$h\t$human_marker_count{$h}\t";
			print "$m\t$mouse_marker_count{$m}\n";
		}
	}
}
########### MAIN #####################
count_mouse_regulating();
#print Dumper(\%mouse_marker_count);exit(1);
count_human_regulating();
load_common_marker_index();
construct_correlation();
