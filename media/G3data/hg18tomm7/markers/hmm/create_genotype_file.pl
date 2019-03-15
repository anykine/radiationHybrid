#!/usr/bin/perl -w
#
# create the genotype file needed for the HMM
# by using the sorted position file as template

unless(@ARGV==2){
	print <<EOH;
	usage $0 <hmm position input file> <1/0 genotype file> 
	(eg $0 mouse_hmm_input_sort.bed  mouse/gmm_genotype_cgh.txt)

  Create the genotype (1/0) file needed for the HMM using the
	position file as template.
EOH
exit(1);
}

# file of 1/0s', should be in genomic order
open(INPUT, $ARGV[1]) || die "cannot open genotype file\n";
my @geno = <INPUT>;
close(INPUT);

open(INPUT, $ARGV[0]) || die "cannot open position template file\n"; 
while(<INPUT>){
	chomp;
	#template fmt is: chrom | position | 1=pseudo,0=orig | index
	my @line = split(/\t/);
	if ($line[2] == 1) {
		#pseudo, just make 99 2's
		my $twos = 2 x 99;
		print join("\t", split(//,$twos)),"\n";
		
	} elsif ($line[2] == 0) {
		#get the 1/0 vector from the genotype file created by 
		#GMM/matlab code
		print $geno[$line[3] - 1];
	}
}
