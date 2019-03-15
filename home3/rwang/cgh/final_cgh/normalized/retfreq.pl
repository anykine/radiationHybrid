#!/usr/bin/perl -w
use strict;
use Data::Dumper;

# partition g3 into two groups, healthy and slow and see if
# slow cells all contain a similar region of the genome
#
# slow growth
my @slow    = (5,7,9,10,11,13,14,18,19,22,25,26,35,37,55,56,58,59,64,68,72,74);
my @semi    = (3,4,8,17,23,27,29,34,36,43,48,63,66,69,70,73,75,77,79,80);
my @healthy = (1,2,6,12,15,16,20,21,24,28,30,31,32,33,38,39,40,41,42,44,45,46,47,49,50,51,52,53,54,57,60,65,62,61,67,71,76,78);

#output sizes
print "slow = ", scalar @slow,"\n";
print "semi= ", scalar @semi,"\n";
print "healthy= ", scalar @healthy,"\n";
exit(1);

my @new=();
#merge into one big list
push(@new, @slow, @semi, @healthy);

# change from 1-based to 0-based indexing
subtract_from_vec(\@slow, 1);
subtract_from_vec(\@semi, 1);
subtract_from_vec(\@healthy, 1);
#iter_vec(\@slow);

# group the columns by slow/fast/semi
sub rearray_discrete{
	open(INPUT, "g3cghnorm_and_pos_discrete.txt") || die "cannot open write file";
	while(<INPUT>){
		chomp;
		my ($chr,$start,$stop,@data) = split(/\t/);
		print join("", @data[@slow]), "\t|\t";
		print join("", @data[@healthy]), "\t|\t";
		print join("", @data[@semi]), "\n";
	}
}

# convert CGH log ratios to discrete 1/0
sub convert_logratio_to_discrete{
	open(INPUT, "g3cghnorm_and_pos.txt") || die "cannot open file";
	open(OUTPUT, ">g3cghnorm_and_pos_discrete.txt") || die "cannot open write file";
	my $count=0;
	while(<INPUT>){
		my($chr,$start,$stop,@data) = split(/\t/);
		my @discrete=();
		foreach my $k (@data){
			if (($chr eq 'chrY') || ($chr eq 'chrX')){
				# X and Y are scaled differently, >95% of mode0
				if ($k > 0.1132){
					push @discrete, 1;
				} else {
					push @discrete, 0;
				}
			# autosomes
			} else {
				# > 95% of mode0
				if ($k > 0.0554){
					push @discrete, 1;
				} else {
					push @discrete, 0;
				}
			}
		}
		print OUTPUT join("\t", $chr, $start, $stop),"\t";
		print OUTPUT join("\t", @discrete),"\n"; 
		#last if ++$count==100;
	}
}
sub compute_difference{
	# read in file
	open(INPUT, "g3cghnorm_and_pos_discrete.txt") || die "cannot open g3cghnormalized";
	open(OUTPUT, ">g3cghnorm_rf_analysis.txt") || die "cannot open analysis write";
	my $c=0;
	while(<INPUT>){
		my($chr,$start,$stop,@data) = split(/\t/);
		my @slowones = @data[@slow];
		my @fastones = @data[@healthy];
		my $slowrf = avg_vec(\@slowones);
		my $fastrf = avg_vec(\@fastones);
		my $diff = abs($fastrf - $slowrf);
		print OUTPUT join("\t", $slowrf, $fastrf, $diff);
		# arbitrary threshold 
		if ($diff > 0.4){
			print OUTPUT "\t****","\n";
		} else {
			print OUTPUT "\n";
		}
		#last if ++$c == 100;
	}
}

sub subtract_from_vec{
	my ($vec, $value) = @_;
	for (my $i=0; $i< scalar @$vec; $i++){
		$vec->[$i] = ($vec->[$i] - $value);
	}
}
sub iter_vec{
	my ($vec) = @_;
	foreach my $k (sort {$a<=>$b} @$vec){
		print "$k ";
	}
	print "\n";
}
sub avg_vec{
	my ($vec) = @_;
	return -1 if (scalar @$vec == 0) ;
	my $res=0;
	my $count=0;
	foreach my $k (@$vec){
		$res += $k;
		$count++	
	}
	return $res/$count;
}

########## MAIN ####################
#convert_logratio_to_discrete();
#compute_difference();
rearray_discrete();
