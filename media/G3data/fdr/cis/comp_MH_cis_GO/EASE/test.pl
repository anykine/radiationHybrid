#!/usr/bin/perl -w
#
# assign GO categories as numbers for rank-sum test
use strict;
use Data::Dumper;

unless (@ARGV==2){
	print <<EOH;
	usage $0 <EASE GO file to read> <maxlength>
	 eg $0 cis_human_FDR20.txt.pos.GO 50
	 This will read in the human file, assign ranking to every GO category
	 and then do the same to the mouse file for the top <maxlength> hits. 
	 Output is a pair of ranks that you can use for Mann-Whitney test in R.
EOH
exit(1);
}
#print "size is: ", unique_lists($ARGV[0]), "\n";
do_rank($ARGV[0], $ARGV[1]);

# assign ranks to GO categories for the mouse and hamster lists
# first file is the rank master
sub do_rank {
	my $file = shift;
	my $maxlength = shift; #number of lines in each list to compare (e.g., top50, 100..)
	my %lookup=(); #for 2nd species lookup rank
	my %f1hash=();
	my %f2hash=();
	my $count = 0;
	open(FILE1, $file) || die "cannot open $file\n";
	while(<FILE1>){
		next if /^#/;
		next if $_ !~ /^GO/;
		chomp;
		my @line = split(/\t/);
		$f1hash{$count} = $line[1];
		$lookup{$line[1]} = $count;
		$count++;
	}
	#figure out name of second file
	my $file2 = $file;
	my $order = 0;
	if ($file2 =~ /human/){
		$file2 =~ s/human/mouse/;
		$order = 1;
	} elsif ($file2 =~/mouse/){
		$file2 =~ s/mouse/human/;
		$order = 2;
	}
	open(FILE2, $file2) || die "cannot open $file2\n";
	$count = 0;
	while(<FILE2>){
		next if /^#/;
		next if $_ !~ /^GO/;
		last if $count > $maxlength;
		chomp;
		my @line = split(/\t/);
		$f2hash{$count} = $lookup{$line[1]};
		$count++;
	}

	#output the pair lists: second input species| first input species
	#top N for list 1 and the corresponding ranks in list2
	#We add +1 so the first guy starts at 1 and not 0 (zero)
	if ($order==1){ 
		print "mouse\thuman\n";
	} elsif ($order ==2){
		print "human\tmouse\n";
	}
	for (my $i=0; $i<= $maxlength; $i++){
		print $i+1;
		print "\t";
		print $f2hash{$i}+1;
		print "\n";
	}
}

# utility
# get length of unique number of GO categories
sub unique_lists {
	my $file = shift;
	my %h =();
	open(FILE, $file) || die "cannot open file $file\n";
	while(<FILE>){
		next if /^#/ ;
		#line must start with GO; some excel files look messed up
		next if $_ !~ /^GO/;
		chomp;
		my @line = split(/\t/);
		$h{$line[1]}++;
		print $line[1], "\n";
	}
	return scalar (keys %h)
}

