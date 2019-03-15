#!/usr/bin/perl -w
#
use strict;
use lib '/home/rwang/lib';
use hummarkerpos;

unless (@ARGV==1){
	print <<EOH;
	usage: $0 <mus2human_markers_imputed.bed>

 	find the closest human cgh marker to a lifted over
	mouse cgh marker.
EOH
exit(1);
}

sub find_nearest_marker{
	open(INPUT, $ARGV[0]) || die "cannot open input file\n";
	#format: chr | start| stop | idx
	while(<INPUT>){
		next if /^#/;
		chomp;
		my @line = split(/\t/);
		next if $line[0] =~ /_/;
		next if $line[0] =~ /chrM/;
		next if $line[0] =~ /random/;
		$line[0]='23' if ($line[0] =~ /chrX/);  
		$line[0]='24' if ($line[0] =~ /chrY/);
		$line[0] =~ s/chr//i;
		my $closest=0;
		my $pos = ($line[1]+$line[2])/2;
		for (my $i=0; $i< scalar @{$hummarkerpos{$line[0]}{pos}}; $i++){
			if ( abs($pos-${$hummarkerpos{$line[0]}{pos}}[$i]) < abs($pos-${$hummarkerpos{$line[0]}{pos}}[$closest]) )	{
				$closest = $i;
			}
		}
		#print mus stuff
		print join("\t", @line), "\t";
		#print closest human pos | markeridx
		print ${$hummarkerpos{$line[0]}{pos}}[$closest],"\t";
		print ${$hummarkerpos{$line[0]}{idx}}[$closest],"\n";
		
	}
}

##### MAIN ######

# exported %hummarkerpos()
load_markerpos_from_db("g3data");
find_nearest_marker($ARGV[0]);
#print scalar @{$hummarkerpos{1}{pos}};
