#!/usr/bin/perl -w
#
# count amount of switching (chroms or direction) in liftover'd data
use strict;
use Math::Round;
use Data::Dumper;
my $DEBUG=0;
my @matrix=();

sub usage() {
	print <<EOH
	usage $0 <input file>
	 $0 mouse_revlo95.txt (format chr start stop chr2 start2 stop2 code)
EOH
}

sub load_data{
	my $file = shift;
	open(INPUT, $file) || die "cannot open input file\n";
	while(<INPUT>){
		next if /^#/;
		next if not /^chr/;
		chomp;
		push @matrix, [ split(/\t/) ];
	}
}

sub fill_in{
	my $dir;
	my $lastdir;
	my $i;
	my $delta;
	for($i=0; $i< scalar @matrix; $i++){
		#print "*i=$i\t";
		next if $matrix[$i]->[6] eq "0";
		print join("\t",@{$matrix[$i]}),"\n";
		$dir = $matrix[$i]->[6];
		$delta = 0;
		#scan ahead for match
		my $ii=$i+1;
		while($ii<scalar @matrix && $matrix[$ii]->[6] eq "0"){
			#print join("\t",@{$matrix[$ii]}),"\n";
			$delta++;	
			$ii++;
		}
		#print "delta=$delta\n";
		if ($delta !=0 && ($i+$delta) <scalar @matrix && $dir eq $matrix[$i+$delta+1]->[6] ){
			#impute
			#print "first $matrix[$i]->[4], sec $matrix[$i+$delta+1]->[4]\n";
			my $step = abs(round(($matrix[$i]->[4] - $matrix[$i+$delta+1]->[4])/($delta+1)));
			#print "step=$step\n";
			#print the newly imputed markers
			for(my $j=$i+1; $j<=$i+$delta; $j++){
				#$matrix[$j]->[6];
				if ($dir eq "d"){
					print "$matrix[$j]->[0]\t$matrix[$j]->[1]\t$matrix[$j]->[2]\t";
					print "$matrix[$i]->[3]\t";
					print $matrix[$i]->[4]-$step*($j-$i);
					print "\n";
				} elsif ($dir eq "a") {
					print "$matrix[$j]->[0]\t$matrix[$j]->[1]\t$matrix[$j]->[2]\t";
					print "$matrix[$i]->[3]\t";
					print $matrix[$i]->[4]+$step*($j-$i);
					print "\n";
				}
			}
		}
		#jump ahead
		$i = $i+$delta;
	}
}
###### START ############
unless(@ARGV==1){
	usage();
	exit(1);
}
load_data($ARGV[0]);
fill_in();
