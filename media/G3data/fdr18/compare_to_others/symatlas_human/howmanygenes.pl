#!/usr/bin/perl -w
#
# how many genes are there annotated in the symatlas
# annotation files?
use strict;
use Data::Dumper;

my %genes=();

sub read_annotation_file{
	my ($file, $col) = @_;
	open(INPUT, $file ) || die "cannot open file $file";
	while(<INPUT>){
		chomp; next if /^#/;
		my @line = split(/\t/);
		# not every line in the annotation file has the all columns
		if (defined $line[$col]) {
			if (defined $genes{$line[$col]}){
				$genes{$line[$col]}++;
			} else {
				$genes{$line[$col]} = 1;
			}
		}
	}
}

sub summarize{
	foreach my $k (keys %genes){
		print "$k\t$genes{$k}\n";
	}
	print "size=", scalar keys %genes;
}

# how do the two GNF annotation files overlap?
# is every element of the smaller file in the larger file?
sub overlap2gnfs{
	# store my genes
	my %genelist=();
	my ($yes, $no);
	# store the larger file
	open(INPUT, "gnf1h.annot2007.txt") || die "cannot open newer/larger annotation file";
	while (<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);	
		$genelist{ uc $d[6]} = 1;
	}
	close(INPUT);
	#now see if the smaller file is contained in the larger file;	
	open(INPUT, "gnf1b-anntable.txt") || die "cannot open smaller/older annotation";
	while(<INPUT>){
		chomp; next if /^#/;
		my ($gene) = uc((split(/\t/))[1]);
		next if $gene eq 'NA';
		# does it exist?
		if (defined $genelist{ $gene } ){
			print "$gene exists!\n";
			$yes++;
		} else {
			print "no $gene!\n";
			$no++;
		}
	}
	print "$yes of ", $yes+$no, " exist\n";
	print "$no of ", $yes+$no, " exist\n";
}

######### MAIN #####################

#how many probes have an associated gene symbol ?
#read_annotation_file("gnf1h.annot2007.txt", 6);
#read_annotation_file("gnf1b-anntable.txt",1 );
#summarize();

# see if smaller annot file is contained in larger one
overlap2gnfs();
