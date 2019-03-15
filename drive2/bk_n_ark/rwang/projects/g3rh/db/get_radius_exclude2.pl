#!/usr/bin/perl -w
use strict;
#
# Richard Wang 1/31/06
# get pvals excluding surrounding markers (radius 5 markers)
# pvalue set at 10e-10 (bonferroni correction)
# This version uses markers instead of basepair coordinates (get_radius_exclude.pl)

use DBI;
use Data::Dumper;

my $db = "human_rh";
my $host = "localhost";
my $user = "root";
my $password = "smith1";

my @chromosomes = ('1','2','3','4','5','6','7','8','9','10','11','12',
	'13','14','15','16','17','18','19','20','21','22','X','Y');
#my @chromosomes = ('1');
my $pvalue = 0.000000000001;

my $sql1 = "INSERT INTO G3pvals99b(marker_1, marker_2, chisq_pval) SELECT marker_1, marker_2, chisq_pval FROM G3pvals WHERE marker_1 =? AND marker_2 >? AND chisq_pval < ? ORDER BY marker_2, marker_1";

my $sql2 = "INSERT INTO G3pvals99b(marker_1, marker_2, chisq_pval) SELECT marker_1, marker_2, chisq_pval FROM G3pvals WHERE marker_2 =? AND marker_1 <? AND chisq_pval < ? ORDER BY marker_2, marker_1";


#open conn
my $dbh = DBI->connect("DBI:mysql:database=$db:host=$host",
	$user, $password, {RaiseError=>1}) || die "dberror: ". DBI->errstr;


#get the markers on each Xsm
my $sql_marker_dist = "select m_order,sts_name,chromStart,chromEnd from stsname_marker_link a JOIN stsAlias b ON a.sts_name = b.alias JOIN stsMap c ON b.trueName = c.name WHERE c.chrom = ? and chrom NOT like '%random' ORDER BY chrom, chromStart";

my @marker_per_chrom = ();
foreach my $i (@chromosomes){
	my $sth = $dbh->prepare($sql_marker_dist);
	$sth->execute($i);
	my $counter = 0;
	while (my @data1st = $sth->fetchrow_array() ){
		push @marker_per_chrom, \@data1st;			
		$counter++;
	}	
	
	print "array-num per chrom $i: ".scalar @marker_per_chrom."\n";
	#print "$i:\n";
	#print "$#marker_per_chrom \n";
	#print Dumper(@marker_per_chrom);
	#gives the marker 
	my $first = $marker_per_chrom[0][0];
	my $last = $marker_per_chrom[$#marker_per_chrom][0];

	for (my $marker_i = 0; $marker_i <= $#marker_per_chrom; $marker_i++){
		#print "first=$first last=$last\n\n";
		#print "$marker_per_chrom[$marker_i][0]\n";
		my $current = $marker_per_chrom[$marker_i][0];
		my $right = $marker_per_chrom[$marker_i][0]+5;
		my $left= $marker_per_chrom[$marker_i][0]-5;
		if ($left < $first) { 
			$left = $first; 
		}
		if ($right > $last) { 
			$right = $last; 
		}
		print "left=$left\tcur=$current\tright=$right\n";
		my $sth2 = $dbh->prepare($sql1);
		$sth2->execute($current, $right, $pvalue);
		$sth2 = $dbh->prepare($sql2);
		$sth2->execute($current, $left, $pvalue);
	#	while (my @sql1 = $sth2->fetchrow_array() ){
	#		print "@sql1\n";
	#	}

	} #end for
	@marker_per_chrom = ();
} 	#end foreach



############################
# SUBS
############################

sub strip_quote{
	my($var) = @_;
	$var =~ s/"//g;
	#$var =~ s/^/"/g;
	#$var =~ s/$/"/g; 
return $var;
}
