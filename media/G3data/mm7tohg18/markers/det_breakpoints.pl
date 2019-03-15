#!/usr/bin/perl -w
#
# count amount of switching (chroms or direction) in liftover'd data
use strict;
use Data::Dumper;
my $DEBUG=0;
my @matrix=();

sub usage() {
	print <<EOH
	usage $0 <input file>
	 $0 mouse_lo95_align2.txt (format chr start stop chr2 start2 stop2)
EOH
}

sub load_data{
	my $file = shift;
	open(INPUT, $file) || die "cannot open input file\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		push @matrix, [ split(/\t/) ];
	}
}

#look at the new chrom position and note changes
sub count_chrom_breaks{
	my $switches = 0;
	#my $prevchrom = ${$matrix[0]}[3];
	my $prevchrom = "chr8";
	for (my $i=0; $i<scalar @matrix; $i++){
		#print ${$matrix[$i]}[3];
		if ($prevchrom ne ${$matrix[$i]}[3] && ${$matrix[$i]}[3] ne "0"){
			#print "  ** switch\t";
			$switches++;
			$prevchrom = ${$matrix[$i]}[3];
		}
		#print "\n";
	}
	return $switches;
}

# we want N markers in front to be the same value
# but beware of 0's
sub checkfuture{
	my($cur,$i,$n) = @_;
	my $counter=0;
	#bounds check
	for (my $ii=$i+1; $ii< scalar @matrix; $ii++){
		next if ${$matrix[$ii]}[3] eq "0"; 
		return 1 if ($counter==$n-1);
		if (${$matrix[$ii]}[3] eq $cur && $counter<$n-1){
			$counter++;
			next;
		} else {
			return 0;
		}
	}
	return 1;
}

#see if past N are the same chrom in queue
sub checkhist{
	my($aref) = @_;
	# are all the entries the same?
	my $cur = $aref->[0];
	for (my $i=1; $i< scalar @{$aref}; $i++){
		if ($cur eq $aref->[$i])	 {
			next;	
		} else {
			return 0;
		}
	}
	return 1;
}
sub add_to_queue{
	my($n,$aref,$val) = @_;
	print "before: ", scalar @{$aref}, "\n" if $DEBUG;
	print Dumper($aref) if $DEBUG;
	if (scalar @{$aref} == $n && $val ne "0"){
		shift @{$aref};
		push @{$aref}, $val;
	} elsif (scalar @{$aref} < $n){
		push @{$aref}, $val;
	}
	print "after: ", scalar @{$aref}, "\n" if $DEBUG;
	print "test: ",$aref->[0], "\n" if $DEBUG;
	print Dumper($aref) if $DEBUG;
}

#define change if at least N markers from diff chrom
sub count_chrom_breaks_n{
	my $n = shift;
	my $switches = 0;
	my @prev=(); #this will always be N long queue

	#my $prevchrom = ${$matrix[0]}[3];
	for (my $i=0; $i<scalar @matrix; $i++){
		print "line $i\n" if $DEBUG;;
		next if ${$matrix[$i]}[3] eq "0";
		# 1.current chrom diff than last one in queue
		# 2.not 0
		# 3.last N entries in queue are the same
		if ($prev[$#prev] ne ${$matrix[$i]}[3] && ${$matrix[$i]}[3] ne "0" && 
		checkhist(\@prev) && checkfuture(${$matrix[$i]}[3], $i,$n) && scalar @prev==$n) {
			print "  ** switch\n" if $DEBUG;
			$switches++;
		}
		add_to_queue($n, \@prev, ${$matrix[$i]}[3]);
	}
	return $switches;
}

sub label_breaks_reversals{
	my @prev=();
	my $flag;
	my $oldflag;
	my $count=0;
	#for (my $i=0; $i<1176; $i++){
	for (my $i=0; $i<scalar @matrix; $i++){
		if (${$matrix[$i]}[3] eq "0"){
			print join("\t",@{$matrix[$i]});
			print "\t0\n";
			next;
		}
		#if chrom equal, mark direction change
		if (${$matrix[$i]}[3] eq $prev[3]){
			if (${$matrix[$i]}[4] < $prev[4]){
				print join("\t",@{$matrix[$i]});
				print "\td\n";
				$count++ if $oldflag ne "d";
				$oldflag = "d";
			} else {
				print join("\t",@{$matrix[$i]});
				print "\ta\n";
				$count++ if $oldflag ne "a";
				$oldflag = "a";
			}
		#break in chrom
		} else {
			print join("\t",@{$matrix[$i]});
			print "\tx\n";
		}
		@prev = @{$matrix[$i]};
		
	}
	return $count;
}
###### START ############
unless(@ARGV==1){
	usage();
	exit(1);
}

load_data($ARGV[0]);
my $chrsw = count_chrom_breaks();
print "count_chrom_breaks=$chrsw\n";

my $sum1 = count_chrom_breaks_n(2);
print "count_chrom_breaks_n=$sum1\n";
#
my $brkrev = label_breaks_reversals();
print "$brkrev\n";
