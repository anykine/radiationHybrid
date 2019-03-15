#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

my $NUMSAMPLES = 219;
# split cgh or expr data into male and female sets
my %female=();
my @female=();
my @male=();

sub load_female{
	open(INPUT, "fem.idx") || die "cannot open index";
	%female = map {chomp; ((split(/\t/, $_))[1]-1) => 1 }  <INPUT>;
	foreach my $i (sort {$a<=>$b}  keys %female){
		push @female, $i; 
	}
	#push @female, $i foreach my $i (sort {$a <=> $b} keys %female);
	for (my $i=0; $i< $NUMSAMPLES; $i++){
		if (!defined $female{$i}){
			push @male, $i;
		}
	}
}

sub output{
	foreach my $i (sort keys %female){ print $i,"\n";}
}

sub split_cgh{
	#open(INPUT, "allcgh.sort.2") || die "cannot open cgh";
	#open(INPUT, "all.cghcall.scaled.txt") || die "cannot open cgh";
	open(INPUT, "all.cghcall.allscaled.txt") || die "cannot open cgh";
	open(OUTMALE, ">cghmale") || die "cannot open cgh male";
	open(OUTFEMALE, ">cghfemale") || die "cannot open cgh female";
	<INPUT>;
	while(<INPUT>){
		chomp; next if /^#/; next if /^ID/;
		my @d = split(/\t/);
		# first 4 cols are position info
		for (my $i=0; $i<4; $i++){
			shift @d;
		}
		my @temp = (217, 218);
	
		print OUTMALE join("\t", @d[@male]),"\n";
		print OUTFEMALE join("\t", @d[@female]),"\n";
	}

}

sub split_expr{
	#open(INPUT, "allexpr.sort.1") || die "cannot open expr";
	#open(INPUT, "all.expr.txt") || die "cannot open expr";
	open(INPUT, "normalized_expr.txt") || die "cannot open expr";
	open(OUTMALE, ">exprmale") || die "cannot open expr male";
	open(OUTFEMALE, ">exprfemale") || die "cannot open expr female";
	while(<INPUT>){
		chomp; next if /^#/; next if /^Chrom/;
		my @d = split(/\t/);
		for (my $i=0; $i<4; $i++){
			shift @d;
		}
		print OUTMALE join("\t", @d[@male]),"\n";
		print OUTFEMALE join("\t", @d[@female]),"\n";
	}

}
######### MAIN######################
load_female();
#print Dumper(\%female);exit(1);
#print Dumper(\@male); exit;
#output();
split_cgh();
#split_expr();
