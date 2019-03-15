#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

# split cgh or expr data into male and female sets
my %female=();
my @female=();
my @male=();

sub load_female{
	open(INPUT, "female.idx") || die "cannot open index";
	%female = map {chomp; ((split(/\t/, $_))[1]-1) => 1 } grep{/^V/}  <INPUT>;
	foreach my $i (sort {$a<=>$b}  keys %female){
		push @female, $i; 
	}
	#push @female, $i foreach my $i (sort {$a <=> $b} keys %female);
	for (my $i=0; $i<237; $i++){
		if (!defined $female{$i}){
			push @male, $i;
		}
	}
}

sub output{
	foreach my $i (sort keys %female){ print $i,"\n";}
}

sub split_cgh{
	open(INPUT, "allcgh.sort.2") || die "cannot open cgh";
	open(OUTMALE, ">cghmale") || die "cannot open cgh male";
	open(OUTFEMALE, ">cghfemale") || die "cannot open cgh female";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		print OUTMALE join("\t", @d[@male]),"\n";
		print OUTFEMALE join("\t", @d[@female]),"\n";
	}

}

sub split_expr{
	open(INPUT, "allexpr.sort.1") || die "cannot open expr";
	open(OUTMALE, ">exprmale") || die "cannot open expr male";
	open(OUTFEMALE, ">exprfemale") || die "cannot open expr female";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		print OUTMALE join("\t", @d[@male]),"\n";
		print OUTFEMALE join("\t", @d[@female]),"\n";
	}

}
######### MAIN######################
load_female();
#print Dumper(\%female);
#output();
#split_cgh();
split_expr();
