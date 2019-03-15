#!/usr/bin/perl -w
#
# convert AFFY probes to gene symbol
use strict;
use Data::Dumper;

my %genes=();

# sample gene list based on level1 normalized affy data from TCGA
sub load_sample{
	open(INPUT, "samp.12k") || die "cannot open sample";
	%genes = map {chomp; $_ => 1} <INPUT>;
	#print Dumper(\%genes);
}

# load probe2gene
my %probe2gene=();

sub load_probe2gene{
	open(INPUT, "../index/affyprobe2gene.txt") || die "err";
	while(<INPUT>){
		chomp; next if /^#/;
		my ($probe, $gene) = split(/\t/);
		next if $gene eq '---';
		next if $gene eq '';
		$probe2gene{$probe} = $gene;
	}
	#print Dumper(\%probe2gene);
}

sub test{
	foreach my $k (values %probe2gene){
		if (defined $genes{$k}){
			
		} else {
			#print "$k in probelist, not in sample\n";
		}
	}
	foreach my $k (keys %genes){
		my $found=0;
		foreach my $i (values %probe2gene){
			if ($k eq $i){
				$found = 1;
			}
		}
		print "$k from samp not in probelist\n" if ($found == 0)
	}
}

# add the gene identifier
sub annotate_exprfile{
	open(INPUT, "all.expr.txt" ) || die "err in annotate";
	<INPUT>;
	print;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		my $probe = shift @d;
		if (defined $probe2gene{$probe}){
			print $probe2gene{$probe},"\t";
			print join("\t", @d), "\n";
		}
	}
}

# remove rows with genes not in sample list
# creates the all.expr.matched.txt file
sub match2samplegenes{
	my $file = shift;
	open(INPUT, $file) || die "cannot open $file";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		if (defined $genes{$d[0]} ) {
			print join("\t", @d),"\n";
		}
	}
}

### MAIN ###
load_sample();
load_probe2gene();
#test();
#annotate_exprfile();
match2samplegenes("all.expr.genenames.txt");
