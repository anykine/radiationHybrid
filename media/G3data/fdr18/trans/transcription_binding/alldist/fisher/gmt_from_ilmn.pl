#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

my %go_cats = ();
# parse the ilmn_ontology file
sub parse_file{
	open(INPUT, "ilmn_ontology.txt") || die "cannot open ilmn ontology";
	while(<INPUT>){
		next if /^#/; chomp;	
		my ($symbol,$gostring) = split(/\t/);
		my @gocats = split(";", $gostring);
		next if $gostring !~/go_/; 
		foreach my $cat (@gocats){
			$cat =~ s/go_//g;
			my ($class, $category, $goid) = ($cat =~ /(component|function|process): (.+) \[goid (\d+)\]/);
			#remove spaces
			$category =~ s/ /_/g;
			$category = uc($category);
			$symbol =~  s/ /_/g;
			$symbol = uc($symbol);
			$go_cats{$class}{$category}{$symbol} = 1;
		}
	}
	#print Dumper(\%go_cats);
}

# write out in format of .GMT
# col1 = category, col2 = GO cat(bp,cc,mf), col3..N=genes
sub output_as_gmt{
	my ($thresh) = @_;
	# class: component, function,process
	foreach my $k (keys %{$go_cats{component}}){
		my $size = scalar (keys %{$go_cats{component}{$k}});
		next if $size < $thresh;
		print "$k\tcellular_component\t";
		print join("\t", (sort keys %{$go_cats{component}{$k}})),"\n";
	}
	foreach my $k (keys %{$go_cats{function}}){
		my $size = scalar (keys %{$go_cats{function}{$k}});
		next if $size < $thresh;
		print "$k\tmolecular_function\t";
		print join("\t", (sort keys %{$go_cats{function}{$k}})),"\n";
	}
	foreach my $k (keys %{$go_cats{process}}){
		my $size = scalar (keys %{$go_cats{process}{$k}});
		next if $size < $thresh;
		print "$k\tbiological_process\t";
		print join("\t", (sort keys %{$go_cats{process}{$k}})),"\n";
	}
}
sub output_as_totals{
	my ($thresh) = @_;
	# class: component, function,process
	foreach my $k (keys %{$go_cats{component}}){
		my $size = scalar (keys %{$go_cats{component}{$k}});
		next if $size < $thresh;
		print "$k\t$size\n";
	}
	foreach my $k (keys %{$go_cats{function}}){
		my $size = scalar (keys %{$go_cats{function}{$k}});
		next if $size < $thresh;
		print "$k\t$size\n";
	}
	foreach my $k (keys %{$go_cats{process}}){
		my $size = scalar (keys %{$go_cats{process}{$k}});
		next if $size < $thresh;
		print "$k\t$size\n";
	}
}

######### MAIN #####################
parse_file();
output_as_gmt(70);
#test();
