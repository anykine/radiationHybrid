#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;

my $NUMSAMPLES = 237;
# split cgh or expr data into male and female sets
my %female=();
my @female=();
my @male=();

# Use clinical sex data
sub load_female_clinical{
	#store sex assignments;
	my %sex=();
	open(CLINICAL, "../clinical/clin_sex.txt") || die "err";
	<CLINICAL>;
	while(<CLINICAL>){
		chomp; next if /^#/;
		my ($samp, $mf) = split(/\t/);
		$samp =~ s/-/\./g;
		#$sex{$samp} = $mf if $mf eq 'FEMALE';
		$sex{$samp} = $mf ;
	}

	#make arrays of female/male
	#open(TEST, ">test.txt");
	open(HEADER, "allcgh1.txt_smoothed.scaled.filtX") || die "err";
	my $header = <HEADER>;
	my @d = split(/\t/, $header); shift @d for 1..4;
	for (my $i=0; $i< scalar @d; $i++){
		my $s = substr($d[$i], 0, 12);
		if (defined $sex{$s} && $sex{$s} eq 'FEMALE'){
			push @female, $i;
			#print TEST join("\t", $s, "FEMALE"),"\n";
		} elsif (defined $sex{$s} && $sex{$s} eq 'MALE') {
			push @male, $i;
			#print TEST join("\t", $s, "MALE"),"\n";
		} else {
			#print TEST join("\t", $s, "UNKNOWN"), "\n";
		}
	}
	#print Dumper(\@female);	
	#exit(1);
}
# using CGH calls by me
sub load_female{
	open(INPUT, "fem.idx") || die "cannot open index";
	%female = map {chomp;next if /^#/; ((split(/\t/, $_))[1]-1) => 1 } grep { /V/ }  <INPUT>;
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
	open(INPUT, "allcgh1.txt_smoothed.scaled.filtX") || die "cannot open cgh";
	open(OUTMALE, ">tcga_cghmale_sm.sc.filtX_clin") || die "cannot open cgh male";
	open(OUTFEMALE, ">tcga_cghfemale_sm.sc.filtX_clin") || die "cannot open cgh female";
	while(<INPUT>){
		chomp; next if /^#/; next if /^ID/; next if /^probe/;
		my @d = split(/\t/);
		# first 4 cols are position info
		for (my $i=0; $i<4; $i++){
			shift @d;
		}
		print OUTMALE join("\t", @d[@male]),"\n";
		print OUTFEMALE join("\t", @d[@female]),"\n";
	}

}

sub split_expr{
	open(INPUT, "allexpr.txt") || die "cannot open expr";
	open(OUTMALE, ">tcga_exprmale_clin") || die "cannot open expr male";
	open(OUTFEMALE, ">tcga_exprfemale_clin") || die "cannot open expr female";
	while(<INPUT>){
		chomp; next if /^#/; next if /^Chrom/; next if /^probe/;
		my @d = split(/\t/);
		for (my $i=0; $i<4; $i++){
			shift @d;
		}
		print OUTMALE join("\t", @d[@male]),"\n";
		print OUTFEMALE join("\t", @d[@female]),"\n";
	}

}
######### MAIN######################
load_female_clinical();
#load_female();
#print Dumper(\%female);exit(1);
#print Dumper(\@male); exit;
#output();
split_cgh();
split_expr();
