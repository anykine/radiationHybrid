#!/usr/bin/perl -w
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
my @acc = ();
my @gn = ();
my @syn = ();
my $organism;
while(<INPUT>){
	if (/^ID/) {$inRecord=1;}	
	if ($inRecord==1){
		if (/^AC/) {
			s/AC   //g;
			s/\s+//g;
			@acc = split(";");
			#print "@acc\n";
		}
		if (/^OS/) {
			s/OS   //g;
			chomp($_);
			s/\s*\(.*\)\.//g;
			$organism = $_;
		}
		if (/^GN   Name/) {
			s/GN   //g;
			@gn = split(";");
			#get the name
			if ($gn[0] =~ /Name=/){
				$gn[0] =~ s/Name=//;
				#print "name=$gn[0]\n";
			}
			#if synonym, get those
			if ($gn[1] =~ /Synonyms=/){
				$gn[1] =~ s/\s*Synonyms=//;
				$gn[1] =~ s/ //;
				#print "syns_all=$gn[1]\n";
				@syn = split(/,/, $gn[1]);
			}
		}
		if (/^\/\//) {
			$inRecord = 0;
			#assemble datastruct
			#for every prot id
			# only print if gene name exists for protein
			if (defined $gn[0]){
				for my $i (@acc){
					#$hoh{$i} = { 'gene'=>$gn[0], 'syn' => [@syn], 'organism' => $organism };
					$hoh{$i} = { 'gene'=>$gn[0], 'syn' => [@syn] };
				}
			}#defined
				#clear out vars
				$#acc = -1;
				$#gn = -1;
				$organism = "";
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
