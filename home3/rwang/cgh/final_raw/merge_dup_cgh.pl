#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

unless (@ARGV==1){
	print <<EOH;
	$0 <sorted file w/ cgh values>
	 e.g. $0 g3matrix_pos_sorted.txt

	Some CGH probes are on the array multiple times. We want only unique
	probes, so we average duplicates. This expects the file to be sorted in
	genomic order and uses chrom/start for identifying duplicates.

EOH
exit(1);
}
my %data=(); #hash keys of chrom:start
my @matrix= ();

#-------start here----------
determine_dups($ARGV[0]);
avg_dups($ARGV[0]);

#we can assume that dups are in order
sub avg_dups{
	my ($file) = shift;
	open(INPUT, $file) || die "cannot open file for read\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		my @data1 = split(/\t/);	
		my $key = join(":", $data1[0], $data1[1]);

		#if duplicates
		if ($data{$key} > 1){
			my @newdata=();
			#get the first probe
			push @newdata, $data1[0], $data1[1], $data1[2], $data1[3];
			my $numlines = $data{$key};
			#print "numlines = $numlines\n";
			for (my $i=0; $i<$numlines-1; $i++){
				my $line = <INPUT>;
				chomp $line;
				push @matrix, [ split(/\t/, $line) ]; 
			}
			print join("\t", @newdata), "\n";
			#clear matrix
			$#matrix = -1;
		#no duplicates, just copy out the line
		} else {
			print $_,"\n";
		}
	}
}
sub dump_hash_keys{
	foreach my $k  (keys %data){
		if ($data{$k} > 1){
				print "$k\t$data{$k}\n";
		}
	}
}

sub determine_dups{
	my ($file) = shift;
	open(INPUT, $file) || die "cannot open file for read\n";
	while(<INPUT>){
		next if /^#/;
		my ($chr, $pos) = split(/\t/);
		my $key = join(":", $chr, $pos);
		if (exists $data{$key}){
			$data{$key}++ 
		} else {
			$data{$key} =1 ;
		}
	}
	close(INPUT);
#	foreach my $k  (keys %data){
#		if ($data{$k} > 1){
#			print "$k\t$data{$k}\n";
#		}
#	}
}
