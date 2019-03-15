#!/usr/bin/perl -w
use strict;
use Data::Dumper;
# 
# Find the min mfe (free energy) score within a radius of X.
# Essentially this is peak finding to find the best scoring
# hairpin in mouse 0gene region for further analysis.

sub identify{
	
	my $file = shift;

	# store data as parallel arrays
	my %data = ();
	my $idx=0;
	
	# read in file
	# blocknumber| offset (from block start) | delta_g, | strand
	open(INPUT, "$file")||die "cannot open $file";
	#open(INPUT, "mpin/mblock27.hpin.txt")||die "cannot open mblock";
	while(<INPUT>){
		next if /^#/;chomp;
		my @d = split(/\t/);
		push @{$data{index}}, $idx++;
		push @{$data{blocknum}}, $d[0];
		push @{$data{offset}}, $d[1];
		push @{$data{mfe}}, $d[2];
		push @{$data{strand}}, $d[3];
	}
	close(INPUT);
	#print $data{mfe}[125],"\n";exit(1);
	#print join("\n", @{$data{index}});exit(1);
	
	# sort by mfe, desc
	my @index_by_mfe= sort {$data{mfe}[$a] <=> $data{mfe}[$b]; } (@{$data{index}});
	
	# the accepted are stored
	my %bin=();
	
	# for every sorted index
	for(my $i=0; $i < scalar @index_by_mfe; $i++){
		# accept the first guy, unconditionally
		push @{$bin{index}}, $index_by_mfe[$i] if $i==0;	
		my $flag = 0;
		# compare against stored vals and det distance	
		foreach my $k (@{$bin{index}}){
			# must be further than X basepairs
			if (abs(${$data{offset}}[$k] - ${$data{offset}}[$index_by_mfe[$i]]) > 200){
				$flag = 1;
			} else {
				$flag = 0;
				last;
			}
		}
		if ($flag){
			push @{$bin{index}}, $index_by_mfe[$i];
		}
	}
	
	#	print Dumper(\%bin);exit(1);
	# print orig blocks, filtering on accepted indexes

	open(OUTPUT, ">$file".".min") || die "cannot open $file.min";
	foreach my $i (sort {$a<=>$b} @{$bin{index}}){
		print OUTPUT join("\t", 	
		${$data{index}}[$i], 
		${$data{blocknum}}[$i],
		${$data{offset}}[$i], 
		${$data{mfe}}[$i], 
		${$data{strand}}[$i], 
		),"\n";
	}
	close(OUTPUT);
}

################# MAIN #######################

unless (@ARGV==2){
	print "usage: $0 <start block> <end block>\n";
	exit(1);
}

# input a numeric range of files
for ($ARGV[0] .. $ARGV[1]){
	my $f = "mpin/mblock". $_. ".hpin.txt";
	my $fmin = $f.".min";
	#my $f = "testblock.txt";
	# if file exists and is NOT zero size AND .min file not created
	if (-e $f && ! -z $f){
		if (! -e $fmin ){
			identify($f);
		}
	}
}

