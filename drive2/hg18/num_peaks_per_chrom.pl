#!/usr/bin/perl -w
#
#find the number of 0-gene eQTLs on these chroms
#so I can compare the #of pos hits

my %data=();
print "number of 0-gene eQTLs for select chromosomes\n";
open(INPUT, '/media/G3data/fdr18/trans/zero_gene_peaks/new/zero_gene_peaks_ucschg18.txt') || die "file\n";
while(<INPUT>){
	chomp;
	my @line= split(/\t/);
	
	if ($line[1] >= 184625 && $line[1] <= 191418 ) {
		$data{16}++;
	} elsif ($line[1]>= 191419 && $line[1] <= 199075) {
		$data{17}++;	
	} elsif ($line[1]>= 199076 && $line[1] <= 204849){
		$data{18}++;	
	} elsif ($line[1]>= 204850 && $line[1] <= 210826) {
		$data{19}++;
	} elsif ($line[1]>= 210827 && $line[1] <= 216157) {
		$data{20}++;
	} elsif ($line[1]>= 216158 && $line[1] <= 219519) {
		$data{21}++;
	}
}

foreach $i (sort keys %data){
	print "$i = $data{$i}\n";
}
