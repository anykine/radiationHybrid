#!/usr/bin/perl -w

#calculate the retention frequency of each probe

#takes smoothed log ratios as input
my $file="../frag_size/g3cghnorm_and_pos.txt";

my $index=1;
my $sum = 0;

open(HANDLE, $file) or die "cannot open file\n";
while(<HANDLE>) {
	chomp $_;
	my @line = split ("\t", $_);
	my $chr = shift @line;
	my $start = shift @line;
	my $stop = shift @line;
	
	my $length= scalar @line;

		print "$index\t$chr\t$start\t$stop\t";
		
		my $cghplus=0;
		for(my $i=0; $i< $length; $i++) {
			if ($chr =~ /chr[XY]/ && $line[$i] > 0.1132 ){
				$cghplus++;
			} elsif ($chr =~/chr\d{2}/ && $line[$i] > 0.0554) {
				$cghplus++;
			}
		}
		
		print $cghplus/$length, "\n";
		$index++;
	}
close (HANDLE);
