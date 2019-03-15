#!/usr/bin/perl -w
use strict;
use Data::Dumper;

unless (@ARGV == 1) {
	print <<EOH;
	usage $0 <batch3_binned.txt>

	Take CGH vectors for each RH cell and find the best PCR vector.
	This tests to see if there is a better match of CGH data to PCR
	data thereby indicating a potential mixup.

	Datafile has header: 
	oldindex newindex chrom start stop cgh1..n pcr1..n
EOH
exit(1);
}

my @pcr = (); #pcr datamatrix, cols=cell line, rows=markers
my @cgh = (); #cgh datamatrix
my $skipcols = 5;
open(INPUT, $ARGV[0]) or die "cannot open $ARGV[0] for read\n";

#skip header
my $num_clones = det_num_clones(\*INPUT);
print "num clones = $num_clones\n";
my @pcrcols = (); #pcr column numbers
my @cghcols = ();
my %bestmatch = (); #store the best match for every clone

#these are the cols I want from orig datafile
for (my $i=5; $i<$num_clones+5; $i++){
	push @cghcols, $i;
	push @pcrcols, $i+$num_clones;
}
print "@pcrcols\n";
print scalar @pcrcols,"\n";
print "@cghcols\n";
print scalar @cghcols,"\n";
#load the data into arrays of arrays
while(<INPUT>){
	chomp;
	my @tmp = split(/\t/);	
	push @cgh,[ @tmp[@cghcols] ]; 
#	print "=@cgh\n";
	push @pcr,[ @tmp[@pcrcols] ]; 
#	print "=@pcr\n";
}
#print Dumper(\@cgh);
#compare all pairs of cgh to pcr by iterating over AoA, get best,store in hash
for (my $i=0; $i<$num_clones; $i++){
	#print "i=$i\n";
	for (my $j=0; $j< $num_clones; $j++){
		#print "j=$j\n";
		my $count = 0;
		my $match = 0;
		#read down a column of cgh/pcr
		for (my $k=0; $k<= $#cgh; $k++){
			#print "k=$k\n";
			#print "cgh=$cgh[$k][$i]\n";
			#print "pcr=$pcr[$k][$j]\n";
			if ($pcr[$k][$j] == 1){  #match against PCR data where where marker=1
				$count++; #count cases where pcr marker is present
				$match++ if ($cgh[$k][$i] == $pcr[$k][$j]);  #counts cases where cgh=pcr=1
			}
		}
		$bestmatch{$i}{$j} = $match/$count;
		#print Dumper(\%bestmatch);
	}
}
best_match(\%bestmatch);
#show best match for each rh clones
sub best_match{
	my $hashref = shift;
	my $best=0;

	my @rh = sort keys %{$hashref}; #just 0..N
	foreach my $i (@rh){
		my @sorted = sort {$hashref->{$i}{$b} <=> $hashref->{$i}{$a}} (keys %{$hashref->{$i}});
		print "$i matches ";
		foreach my $key (@sorted){
			print "$key($hashref->{$i}{$key}) ";
		}
		print "\n";
	}
	#this gets your keys back in the order of sorted values ...
	#foreach my $key (sort {$hashref->{$b} <=> $hashref->{$a}} (keys(%{$hashref})) ){
	#	print ""	
	#}
#	my @rh = sort keys %{$hashref}; #just 0..N
#	print "rh=@rh\n";
#	foreach my $i (@rh){
#		foreach my $j (@rh){
#			$best = $j if $bestmatch{$i}{$j} > $bestmatch{$i}{$best};	
#		}
#		print "bestmatch for $i is $best: $bestmatch{$i}{$best}\n";
#		#$best = 0;
#	}
}

#this gets the number of clones from header in line1 of inputfile
sub det_num_clones{
	my ($fh) = shift;
	my $hdr = <$fh>;
	my @tmp = split(/\t/, $hdr);
	print "num cols = ", scalar @tmp, "\n";
	#5 cols in front, cgh, pcr data
	return ((scalar (@tmp)) - $skipcols)/2;
}
