#!/usr/bin/perl -w
use strict;
#
# get pvals excluding surrounding markers (radius 5)
# DOES NOT WORK

use DBI;
use Data::Dumper;

my $db = "human_rh";
my $host = "localhost";
my $user = "root";
my $password = "smith1";

#exclusion radius 4MB
my $radius = 4000000;
#my @chromosomes = ('1','2','3','4','5','6','7','8','9','10','11','12',
#	'13','14','15','16','17','18','19','20','21','22','X','Y');
my @chromosomes = ('1');

my $sql1 = "SELECT marker_1, marker_2, chisq_pval FROM G3pvals WHERE marker_1 =? AND marker_2 >? AND chisq_pval < ? ORDER BY marker_2, marker_1";

my $sql2 = "SELECT marker_1, marker_2, chisq_pval FROM G3pvals WHERE marker_2 =? AND marker_1 <? AND chisq_pval < ? ORDER BY marker_2, marker_1";


#open conn
my $dbh = DBI->connect("DBI:mysql:database=$db:host=$host",
	$user, $password, {RaiseError=>1}) || die "dberror: ". DBI->errstr;

#execute once, twice;
my $sth = $dbh->prepare($sql1);
#$sth->execute($ARGV[0], $ARGV[1]);
#my $data1 = $sth->fetchall_arrayref();
#$sth->finish();
$sth = $dbh->prepare($sql2);
#$sth->execute($ARGV[0], $ARGV[1]);
#my $data2 = $sth->fetchall_arrayref();

#$dbh->disconnect();

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
	
	#print "$i:\n";
	#print "$#marker_per_chrom \n";
	#print Dumper(@marker_per_chrom);
	#gives the marker 
	my $first = $marker_per_chrom[0][0];
	my $last = $marker_per_chrom[$#marker_per_chrom][0];
	#build map of start/end positions
	#4000000 - pos1 + pos2 < 

	for (my $marker_i = 0; $marker_i <= $last; $marker_i++){
		print "$marker_per_chrom[$marker_i][0]\n";
		my $current = $marker_per_chrom[$marker_i][2];
		if ($current - 0 > ($radius/2)	){
			my $bookmark1 = $marker_i-1;
			while ($marker_per_chrom[$marker_i][2] - $marker_per_chrom[$bookmark1][2] < ($radius/2)){
				$bookmark1--;
			}
			my $bookmark2 = $marker_i+1;
			while ($marker_per_chrom[$bookmark2][2] - $marker_per_chrom[$marker_i][2] < ($radius/2)){
				$bookmark2++;
			}
			#bookmark+1 is your endpoint
			print "astart=$bookmark1 end=$bookmark2\n";
		}elsif ($current - 0 < ($radius/2)	){
			my $bookmark = $marker_i+1;
			print "1. $marker_per_chrom[$marker_i][2]\n";
			print "2. $bookmark\n";
			print "3. $marker_per_chrom[$bookmark][2]\n";
			my $center = $marker_per_chrom[$marker_i][2];
			my $right = $marker_per_chrom[$bookmark][2];
			my $eval = $radius - $center + $right;
			print "4. $eval\n";
if ($eval < $radius) {print "true\n"};
			while($eval < $radius) {
				$bookmark++;
				print "\tbk=AAA\n";
			}
			#bookmark-1 is your endpoint
			print "bstart=$bookmark end=$marker_i\n";
		}
	}
	my $sth2 = $dbh->prepare($sql1);
	$sth2->execute($first, $first+5, 0.01);
	while (my @sql1 = $sth2->fetchrow_array() ){
		#print "@sql1\n";
	}
} #end foreach

#foreach my $a (@$data2){
#	my($marker1,$marker2,$chisq,$chr,$mark_start) = @$a;
#	print "$marker1,$marker2,$chisq,$chr,$mark_start\n";
#}



############################
# SUBS
############################
sub find_closest_marker{

}

sub strip_quote{
	my($var) = @_;
	$var =~ s/"//g;
	#$var =~ s/^/"/g;
	#$var =~ s/$/"/g; 
return $var;
}
