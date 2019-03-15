#!/usr/bin/perl -w
#
# correlate the alpha/pvalue for a chosen mouse 0-gene eQTL
# with that of the orthogonal 0-gene eQTL.
#
#use strict;
#use R;
#use RReferences;
use Fcntl ":seek";
use lib '/home/rwang/lib';
use g3datamanip;
use Data::Dumper;
use t31datamanip;

# get gene-alpha and gene-pval for every gene assoc with given marker
# using BINARY file format package g3datamanip
sub get_human_data_by_marker{
	my ($marker) = @_;
	my %data=(); 
	for( my $i=1; $i<=20996; $i++){
		my %record = g3datamanip::get_g3record($i, $marker);
		push @{$data{alpha}}, $record{alpha};
		push @{$data{nlp}}, $record{nlp};
	}
	#print Dumper(\%data);
	return \%data;	
}

#ge the alphas and nlp for MOUSE data
sub get_mouse_data_by_marker{
	my ($marker) = @_;
	my $fh = open_t31file('alpha');
	my %data=();
	for (my $i=1; $i<=20145; $i++){
		my $val = get_t31record($i, $marker, $fh);
		push @{$data{alpha}}, $val;
	}
	$fh = open_t31file('nlp');
	for (my $i=1; $i<=20145; $i++){
		my $val = get_t31record($i, $marker, $fh);
		push @{$data{nlp}}, $val;
	}
	#print Dumper(\%data);
	return \%data;
}

# global hash
my %hum2mus=();

# dictionary of hum->mus genes
sub get_common_gene{
	open(INPUT, "/media/G3data/fdr18/cis/comp_MH_cis_alphas/common_human_mouse_indexes.txt") || die "common file\n";
	#skip first line
	<INPUT>;
	#human idx | mouse idx
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		$hum2mus{$data[0]} = $data[1];
	}
	close(INPUT);
}

# assemble data for output
# human alpha| human nlp | mouse alpha | mouse nlp
sub output_mh_alp_nlp{
	my ($mushashref, $humhashref, $fh) = @_;
	while( my ($h, $m) = each(%hum2mus) ) {
		#print "$h and $m\n";
		# genes are 1-based, arrays are 0 based
		print $fh ${$humhashref}{alpha}[$h-1],"\t";
		print $fh ${$humhashref}{nlp}[$h-1],"\t";
		print $fh ${$mushashref}{alpha}[$m-1],"\t";
		print $fh ${$mushashref}{nlp}[$m-1],"\n";
	}
}

#find the common genes in each list and filter
sub assemble_to_list{
	my ($mushashref, $humhashref) = @_;
	my %data=();
	while( my ($h, $m) = each(%hum2mus) ) {
		#print "$h and $m\n";
		# genes are 1-based, arrays are 0 based
		push @{$data{humalpha}}, ${$humhashref}{alpha}[$h-1];
		push @{$data{humnlp}},   ${$humhashref}{nlp}[$h-1];
		push @{$data{musalpha}}, ${$mushashref}{alpha}[$m-1];
		push @{$data{musnlp}},   ${$mushashref}{nlp}[$m-1];
	}
	#print Dumper(\%data);
	return (\%data);
}
############ RUN ##############
#my %hash = read_g3header();

# load up the mus-hum gene dictionary
get_common_gene();

# start R
#&R::initR("--silent");
#&R::library("RSPerl");

my $counter=0;
# my file of hum & mus shared 0-gene eQTLs
open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/new/overlap150k.txt") || die "cannot open input\n";
#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/overlap/within15k.txt") || die "cannot open input\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	my @data = split(/\t/);
	my $humhashref = get_human_data_by_marker($data[1]);
	#for (my $i=0; $i<20996; $i++){
	#	print $humhashref->{alpha}[$i],"\t";
	#	print $humhashref->{nlp}[$i],"\n";
	#}

	my $mushashref = get_mouse_data_by_marker($data[0]);
	#for (my $i=0; $i<20145; $i++){
	#	print ${$mushashref}{alpha}[$i],"\t";
	#	print ${$mushashref}{nlp}[$i],"\n";
	#}
	
	# RSPerl interface doesn't work! Write to file instaed
	# call assemble on data
	#my $hashref = assemble_to_list($mushashref, $humhashref);
	#my @x = @{$hashref->{humalpha}};
	#my @y = @{$hashref->{musalpha}};

	my $fname = 'data' . $counter++ . '.txt';	
	open my $fh, ">$fname";
	output_mh_alp_nlp($mushashref, $humhashref, $fh);
	close $fh;
	#my $res = &R::callWithNames("cor.test", {'x',@{$humhashref->{alpha} , 'y',$mushashref->{alpha}}} );
	#my $res= &R::callWithNames("cor.test", {'x',\@x , 'y',\@y} );
	#print $res,"\n";
	#print $res->getName;
	
}
