#!/usr/bin/perl -w

# After you run mirscan on hhit###.summary.mirscan files (manuall),
# use this to  parse the mirscan output file to get score and name.
# The scores can be used to build distribution of mirscan scores and
# see if there are any interesting candidates
use strict;
use Data::Dumper;

sub parse_mirscan{
	my $file = shift;
	my ($blocknum) = ($file =~ /hhit(\d+)/);
	open(INPUT, $file) || die "cannot open $file";
	open(OUTPUT, ">$file".".result") || die "cannot open $file .result for write";
	while(<INPUT>){
		next if /^#/; chomp;
		my ($name , $totscore) = ($_ =~ /(.+) totscore (.+) bp/);
		if ($totscore !~ /NA/){
			print OUTPUT "$name\t$totscore\n";
		}
	}	
}
############ MAIN ##################
my $usage = "usage $0 startblock stopblock\n";
unless(@ARGV==2) { print $usage; exit(1); }

my @files = ();
for ($ARGV[0]..$ARGV[1]){
	my $f = "hhit".$_.".summary.mirscan.out";
	push @files, $f if (-e $f);
}
#print Dumper(\@files);exit(1);
foreach my $f (@files){
	print STDERR "parsing $f\n";
	parse_mirscan($f);
	#parse_mirscan("hhit1.summary.mirscan.out");
}
