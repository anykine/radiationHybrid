#!/usr/bin/perl -w
# 8/22/06
# parse swissprot/trembl, extract gene name,
# organism, synonyms, etc...
# build mapping of swiss prot id->gene name
# input swissprot files
# output prot ids -> gene names
#		sample data: 
# AC P38383; P12345; 
# GN Name=Exo1; Synonyms=Kip1, Waf1;
use strict;
use Data::Dumper;

open(INPUT, $ARGV[0]) || die "cannot open file: $!";
my $inRecord = 0;
my %hoh = ();
my @gn = ();
my @syn = ();
my $organism;
my $acline;
my $gnline;
while(<INPUT>){
	if (/^ID/) {$inRecord=1;}	
	if ($inRecord==1){
		if (/^AC/) {
			s/AC   //g;
			s/\s+//g;
			chomp($_);
			$acline .= $_;
			#print "@acc\n";
		}
		if (/^OS/) {
			s/OS   //g;
			chomp($_);
			s/\s*\(.*\)\.//g;
			$organism = $_;
		}
		if ((/^GN/) && ($_ !~/and/i)) {
			s/GN   //g;
			s/\s+//g;
			chomp($_);
			$gnline .= $_;
		}
		if (/^\/\//) {
			$inRecord = 0;
			#assemble datastruct
			#for every prot id only print if gene name exists for protein
			#get accessions
			#print "AC=$acline\n";
			#print "GN=$gnline\n";
			my @acc = split(/;/, $acline);
			#get genes: possible keys Name, Synonyms, ORFname
			my @gnentries = split(/;/, $gnline);
			my %gnhash=();
			for my $j (@gnentries){
				my($k, $v) = split(/=/, $j);
				if (exists $gnhash{$k}) {
					push @{ $gnhash{$k} }, split(/,/, $v);
				} else {
					$gnhash{$k} = [ split/,/, $v];
				}
			}

			#print Dumper(\%gnhash);
			if (exists $gnhash{'Name'}) {
				for my $i (@acc){
					for my $k (@{$gnhash{'Name'}}){
						#$hoh{$i} = { 'gene'=>$gn[0], 'syn' => [@syn], 'organism' => $organism };
						$hoh{$i} = { 'gene'=>$k, 'syn' => $gnhash{'Synonyms'}};
					}
				}#for
			}#defined

			#clear out vars
			$#acc = -1;
			$#gn = -1;
			$organism = "";
			%gnhash = ();
			$acline = "";
			$gnline = "";
		}
	}#inRecord
}#while
close(INPUT);

writeData(\%hoh);
#print Dumper(\%hoh);

sub writeData{
	my($hashref) = shift;
	while (my ($key, $value) = each(%$hashref) ){
		print "$key\t";
		print "$value->{gene}\n";
		#print "$value->{organism}\n";
	}
}
