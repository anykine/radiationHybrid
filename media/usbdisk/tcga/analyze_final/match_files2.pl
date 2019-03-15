#!/usr/bin/perl -w
# 
# TGCA data: combine all CGH (or EXPR) files into one large matrix
# and make sure the sample has both a CGH and EXPR file prior to merging.
# This uses the files in the /data/ directory which are already 
# matched and sorted in genomic order (how? can't remember) for 237 samples.
# These files are level3 EXPR normalized and level2 CGH normalized
#
use strict;
use Data::Dumper;
use File::Basename;

# 15 characters of a string eg TCGA-02-0001-01C-01R-0177

# Load positions for AGIL CGH data, into a hashref
sub load_cghpos{
	my ($agilpos) = @_;
	open(INPUT, "/media/usbdisk/tcga/index/agilcgh/common_cgh1.txt") || die "cannot open pos";
	while(<INPUT>){
		next if /^#/; chomp;
		my ($index, $chrom, $start, $stop, $probe, $sym) = split(/\t/);
		next if $chrom !~ /\d/;
		${$agilpos}{$probe} = {
			chrom=> $chrom,
			start=> $start,
			stop=> $stop,
			index=>$index,
			sym=>$sym
		};
	}
}
# Load positions for AFFY EXPR data, into a hashref
sub load_affypos{
	my ($agilpos) = @_;
	open(INPUT, "/media/usbdisk/tcga/index/affyexpr/affypos_common_final.txt") || die "cannot open pos";
	while(<INPUT>){
		next if /^#/; chomp;
		my ($index, $chrom, $start, $stop, $gene) = split(/\t/);
		next if $chrom !~ /\d/;
		${$agilpos}{$gene} = {
			chrom=> $chrom,
			start=> $start,
			stop=> $stop,
			index=>$index,
		};
	}
}

# merge the CGH or EXPR files into one big file
# Takes argument {cgh=>1, expr=>0} and hashref of positions
sub merge_files{
	my ($params, $positions) = @_;
	die "need CGH or EXPR parameter!" if (!defined $params->{cgh} or !defined $params->{expr});
	my @f = glob("/media/usbdisk/tcga/data/*.sort");		
	my $header = make_header(@f);
	my %cgh = map { $_ => 1 } grep { /cgh/ } @f;
	my %expr = map { $_ => 1 } grep { /expr/ } @f;
	my @fh = ();
	if ($params->{cgh} == 1){
		for my $k ( sort keys %cgh) {
			local *FILE;
			open(FILE, $k) || die "err $k $!";
			push(@fh, *FILE);
		}
		print $header,"\n";
		for (my $i=0; $i<227605; $i++){
			for (my $j = 0; $j<= $#fh; $j++){
				# strange bug? doesn't work like <$fh[$j]>
				my $handle = $fh[$j];
				my ($probe,$val) = split(/\t/, <$handle>);
				chomp $val;
				$val =~ s/\r//g;


				#print positions?
				if (defined ${$positions}{$probe}){
					if ($j==0){
						print join("\t", $probe, 
							${$positions}{$probe}->{chrom},
							${$positions}{$probe}->{start},
							${$positions}{$probe}->{stop},
							$val ), "\t";
					} elsif ($j==$#fh){	
						print $val, "\n";
					} else {
						print $val, "\t";
					}
				}
			}
		}
	} elsif ( $params->{expr} == 1){

		for my $k ( sort keys %expr) {
			local *FILE;
			open(FILE, $k) || die "err $k $!";
			push(@fh, *FILE);
		}
		print $header,"\n";
		for (my $i=0; $i<11209; $i++){
			for (my $j = 0; $j<= $#fh; $j++){
				# strange bug? doesn't work like <$fh[$j]>
				my $handle = $fh[$j];
				my ($gene,$val) = split(/\t/, <$handle>);
				chomp $val;
				$val =~ s/\r//g;


				#print positions?
				if (defined ${$positions}{$gene}){
					if ($j==0){
						print join("\t", $gene, 
							${$positions}{$gene}->{chrom},
							${$positions}{$gene}->{start},
							${$positions}{$gene}->{stop},
							$val ), "\t";
					} elsif ($j==$#fh){	
						print $val, "\n";
					} else {
						print $val, "\t";
					}
				}
			}
		}
	}
}

sub make_header{
	my @filelist = @_;
	my @header = ();
	push @header, "probe", "chrom", "start", "stop";
	my %cgh = map { $_ => 1} grep { /cgh/ } @filelist;
	for my $k (sort keys %cgh){
		push @header, substr(basename($k), 0, 15);
	}
	#print join("\t",@header),"\n";
	return ( join("\t", @header));

}

sub test_files_in_same_order{
	my @f = glob("/media/usbdisk/tcga/data/*.cgh.sort");		
	#print Dumper(\@f);
	my %f = map { $_ => 1 } @f;
	#print Dumper(\%f);
	my $count=0; my $score=0;
	for my $k (sort keys %f){
		$score++ if $k eq $f[$count++]	;
	}
	print $score
}
######### MAIN #####################
#my %agilpos=();
#load_cghpos(\%agilpos); 
#merge_files({cgh=>1, expr=>0}, \%agilpos);

my %affypos=();
load_affypos(\%affypos); 
merge_files({cgh=>0, expr=>1}, \%affypos);
#test_files_in_same_order();
