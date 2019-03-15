#!/usr/bin/perl -w
use Data::Dumper;
use strict;

# josh's script to calculate fragment length in hybrids
# it uses a fuzz factor to bridge cgh markers. like many things, it needed help.

unless (@ARGV==1){
	print "usage: $0 <gapsize>\n";
	exit(1);
}
my $t="\t";
my $n="\n";

my $file="g3cghnorm_and_pos.txt";
#my $file="test4col.in";
my $fuzz = $ARGV[0];
#my $fuzz=4000000;
#$ARGV[0];

my $len = 0;
#my chr hash of log_ratios
my %lr=();
open(HANDLE, $file) or die "cannot open $file\n";
while(<HANDLE>) {
	chomp $_;

	my @line = split( "\t", $_);
	my $chr = shift @line;
	my $start = shift @line;
	my $stop = shift @line;

	#store start/stop pos for each cgh marker in arrays
	push @{$lr{$chr}{start}}, $start;
	push @{$lr{$chr}{stop}}, $stop;
	$len= scalar @line;
	#store intensities for ea cell in an array
	for (my $i=1; $i<=$len; $i++) { 
		push @{$lr{$chr}{$i}}, shift @line;
	}
}
close(HANDLE);

#retained fragments
my %rfrag=();
#@{$rfrag{$cell_line}{chr}{frag_start}}
#@{$rfrag{$cell_line}{chr}{frag_stop}}
#@{$rfrag{$cell_line}{chr}{frag_size}}
#length will  be number of fragments

# outer loop here will be to do all cell lines
for (my $c=1; $c<=$len; $c++ ) {

foreach my $chr ( sort keys %lr ) {
 	my $found=0;
	my $start=0;
	#iterate over markerr intensity; if above threshold, copy start/stop to rfrag hash
	for (my $i=0; $i< scalar @{$lr{$chr}{start}}; $i++) {
		#autosomes
		if ($chr =~ /chr\d{2}/) {
			if (${$lr{$chr}{$c}}[$i] >= 0.0554 && $found==0) {
				push	@{$rfrag{$c}{$chr}{frag_start}}, ${$lr{$chr}{start}}[$i];
				$found=1;
				$start=${$lr{$chr}{start}}[$i];
			} elsif (${$lr{$chr}{$c}}[$i] < 0.0554  && $found==1 ) {
				push	@{$rfrag{$c}{$chr}{frag_stop}}, ${$lr{$chr}{stop}}[$i];
				push	@{$rfrag{$c}{$chr}{frag_size}}, ${$lr{$chr}{stop}}[$i]-$start;
				$found=0;
			}
		#sex chroms
		} else{
			if (${$lr{$chr}{$c}}[$i] >= 0.1132 && $found==0) {
				push	@{$rfrag{$c}{$chr}{frag_start}}, ${$lr{$chr}{start}}[$i];
				$found=1;
				$start=${$lr{$chr}{start}}[$i];
			} elsif (${$lr{$chr}{$c}}[$i] < 0.1132 && $found==1 ) {
				push	@{$rfrag{$c}{$chr}{frag_stop}}, ${$lr{$chr}{stop}}[$i];
				push	@{$rfrag{$c}{$chr}{frag_size}}, ${$lr{$chr}{stop}}[$i]-$start;
				$found=0;
			}

		}
	}
}
}


#retained fragments using fuzz factor
my %rfixedfrag=();

for (my $c=1; $c<=$len; $c++ ) {
	foreach my $chr (sort keys %{$rfrag{$c}} ) {
		my %sub=();
		for (my $i=1; $i < scalar @{$rfrag{$c}{$chr}{frag_stop}}; $i++) {
			#mark if the dist from one frag to next is less than fuzz
			if ( ${$rfrag{$c}{$chr}{frag_start}}[$i]-${$rfrag{$c}{$chr}{frag_stop}}[$i-1] < $fuzz ) {
				$sub{$i}=1;
			}
		}

		my $i=0;
		while ($i<scalar @{$rfrag{$c}{$chr}{frag_stop}} ) {
			if ( !(defined($sub{$i+1})) ){
				push @{$rfixedfrag{$c}{$chr}{frag_start}} , ${$rfrag{$c}{$chr}{frag_start}}[$i];
				push @{$rfixedfrag{$c}{$chr}{frag_stop}} , ${$rfrag{$c}{$chr}{frag_stop}}[$i];
			} else {
				push @{$rfixedfrag{$c}{$chr}{frag_start}} , ${$rfrag{$c}{$chr}{frag_start}}[$i];
				while ( defined $sub{$i+1} ) {
					$i++;
				}
				push @{$rfixedfrag{$c}{$chr}{frag_stop}} , ${$rfrag{$c}{$chr}{frag_stop}}[$i];
			}
			$i++;
		}
	}
}

for (my $cell=1; $cell<=$len; $cell++ ) {
	foreach my $chr (sort keys %{$rfixedfrag{$cell}} ) {
		for (my $i=0; $i<scalar @{$rfixedfrag{$cell}{$chr}{frag_stop}} ; $i++) {
				print "$cell\t$chr\t${$rfixedfrag{$cell}{$chr}{frag_start}}[$i]\t${$rfixedfrag{$cell}{$chr}{frag_stop}}[$i]\t",(${$rfixedfrag{$cell}{$chr}{frag_stop}}[$i]-${$rfixedfrag{$cell}{$chr}{frag_start}}[$i]),"\n";
		}
	}
}
