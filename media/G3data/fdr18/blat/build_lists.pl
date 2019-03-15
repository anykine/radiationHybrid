#!/usr/bin/perl -w
#
# 
use strict;
#store the neg/pos cis alpha gene symbols
my %neggenes=();
my %posgenes=();

# get the common neg cis alpha genes bt human and mouse
sub find_neg_cis{
	open(INPUT, 
	"/media/G3data/fdr18/cis/comp_MH_cis_alphas/comp_hum_mouse_FDR40_symbol.txt") || die "cannot open file1";
	while(<INPUT>){
		chomp;
		my @d = split(/\t/);
		$neggenes{uc($d[4])} = 1 if ($d[1]<0 && $d[3] <0);	
		$posgenes{uc($d[4])} = 1 if ($d[1]>0 && $d[3] >0);	
	}
}

# sort the ilmn probe file into +cis alpha and -cis alphas files
sub filter_ilmn_probes{
	open(INPUT, "ilmn_probeinfo.txt") || die "cannot open probe file";
	open(OUTPOS, ">cispos_probes.txt") || die "cannot open pos out file";
	open(OUTNEG, ">cisneg_probes.txt") || die "cannot open neg out file";
	while(<INPUT>){
		chomp;
		my @d = split(/\t/);
		if (defined $neggenes{$d[0]} ){
			print OUTNEG join("\t", @d),"\n";
			#print "hi $d[0]\n";
		} elsif ( defined $posgenes{$d[0]} ){
			print OUTPOS join("\t", @d),"\n";
		}
	}
}


sub build_cis_lists{
	find_neg_cis();
	#foreach my $k (keys %neggenes){
	#	print $k,"\n";
	#}
	filter_ilmn_probes();
}

# format a cis probe file as fasta for blat input
sub format_blatinput{
	my $file = shift;
	open(INPUT, $file) || die "cannot open file";
	open(OUTFA, ">$file".".fa") || die "cannot file for write";
	while(<INPUT>){
		chomp;
		my @d = split(/\t/);
		my $name = join("|", @d[0..4]);
		print OUTFA ">$name\n";
		print OUTFA $d[5],"\n";
	}
}

######### MAIN #####################
#build_cis_lists();
#format_blatinput("cisneg_probes.txt");
format_blatinput("cispos_probes.txt");
