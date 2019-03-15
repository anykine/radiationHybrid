#!/usr/bin/perl -w

# RW 8/14/07
# Rip positions and logRatios from aCGH files and creates files as rhNN (NN=[0,83]).
# Only the smallest RH file has positions data.
#
# Handle Agilent CGH data. Assumes all data files have identical structure
# first 10 rows contain no data
# column 12 contains position
# column 16 has log ratio
#
# Note: make sure cgh.config file does not have msdos line ending
use strict;
use Data::Dumper;

#-------------------
# globals
#-------------------
our %rh2file=();   #global RHcell to filename mapping
our %cghPos=();    #global cgh positions
our $cghHeaderSkip = 11;
our $cghPosCol = 11;  #zero based
our $cghLogRatioCol = 15; #zero based

#-------------------
# main code
#-------------------
readConfig();
if (scalar keys(%rh2file) > 0){
	my @hybrids = sort {$a <=> $b } keys(%rh2file);
	#print "@hybrids","\n";
	#pick a hybrid to get the positions
	#debugShowCols($rh2file{$hybrids[0]} );
	getCghPos($rh2file{$hybrids[0]},$hybrids[0] );
	getOtherCgh(@hybrids);
}
#-------------------
# subroutines
#-------------------
# extracts log ratios from all other cgh files
sub getOtherCgh{
	my ($pos,$logRatio,$ofname);
	my @hybrids = @_;
	#skip the first hybrid, already extracted
	for (my $i=1; $i<=$#hybrids; $i++){
		open(INPUT, $rh2file{$hybrids[$i]}) or die "cannot open CGH file $hybrids[$i] to get logRatios\n";
		#zero pad number is length is < 2
		if (length($hybrids[$i]) == 1 ){
			$ofname= "rh0".$hybrids[$i];
		}else {
			$ofname = "rh".$hybrids[$i]; 
		}
		open(OUTPUT, ">$ofname") or die "cannot open CGH file $hybrids[$i] to write logRatios\n";
		#skip the junk
		for (my $i=1; $i<=$cghHeaderSkip; $i++){
			<INPUT>;
		}
		while(<INPUT>){
			chomp;
			(undef,undef,undef,undef,undef,
			undef,undef,undef,undef,undef,
			undef,$pos,undef,undef,undef,$logRatio) = split(/\t/);
			print OUTPUT $logRatio,"\n" if ($pos =~ /chr/ && $pos !~ /ran/);
		}
		print "created rh# $ofname\n";
	}
}
# extracts 1st file w/chrom positions and log Ratios
sub getCghPos{
	my ($pos,$logRatio);
	my($file,$rh) = @_;
	open(INPUT, $file) or die "cannot open CGH file to get positions\n";
	#zero pad number is length is < 2
	$rh = "0$rh" if length($rh) == 1;
	open(OUTPUT, ">rh". $rh) or die "cannot open CGH file to write\n";
	#skip the junk
	for (my $i=1; $i<=$cghHeaderSkip; $i++){
		<INPUT>;
	}
	my $cnt=0;
	while(<INPUT>){
		chomp;
		(undef,undef,undef,undef,undef,
		undef,undef,undef,undef,undef,
		undef,$pos,undef,undef,undef,$logRatio) = split(/\t/);

		if ($pos =~ /chr/ && $pos !~ /ran/){
			$pos=~s/:/\t/g;
			$pos=~s/-/\t/g;
			unless ($pos=~/\t/) { $pos=~s/$/\t\t/g;}
			$pos =~ s/(chr)(\d\t)/$1_$2/ig;  #stupid hack b/c $1(ZERO) looks like $10
			$pos =~ s/_/0/ig;	
			print OUTPUT join("\t",split("\t",$pos)),"\t$logRatio\n";
		}
		#$cghPos{$cnt} = (split(/\t/))[$cghPosCol];
		#$cnt++;
	}
	print "created rh# $rh\n";
	#print Dumper(\%cghPos);
}
sub readConfig{
	my @test=();
	open(INPUT, "cgh.config") or die "cannot open cgh.config file\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		$rh2file{(split(/,/,$_))[1]} = (split(/,/,$_))[0];
	}
	print Dumper(\%rh2file),"\n";
	#print scalar keys(%rh2file),"\n";
}
sub debugShowCols{
	open(INPUT, shift) or die "debug:cannot open input CGH file\n";
	for (my $i=1; $i<=9; $i++){
	<INPUT>;
	}
	$_=<INPUT>;
	print $_;
	my $cnt;
	$cnt = 0;
	foreach my $i ( split(/\t/, $_) ){
		print "$cnt:\t$i\n";
		$cnt++;
	}

}
