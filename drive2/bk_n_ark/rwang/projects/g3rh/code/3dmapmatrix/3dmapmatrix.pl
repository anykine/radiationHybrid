#!/usr/bin/perl -w
# generate 3d data plot for Matlab to graph
# to see marker peaks in 3d 
# 
# for HUMAN g3
# input: xaxis markers (lower numbers), yaxis markers (higher nums)
# output: xaxis range(bp), yaxis range(bp), pvals


use strict;
use warnings;
use DBI;
use Data::Dumper;

my $db = "human_rh";
my $host = "localhost";
my $user = "root";
my $password = "smith1";

my $x1 = 4762;
my $x2 = 4772;
my $y1 = 7241;
my $y2 = 7251;
#my $y2 = 10721;
my @yvars = ();
my @xvars = ();
my $pvals = [];

#sanity check
unless (@ARGV) {
	print "usage: $0 <ouput file name>\n";
	exit;
}
my $SQLX="select a.marker_1, a.marker_2, a.chisq_pval, b.m_order, c.chrom, c.chromStart from G3pvals a JOIN stsname_marker_link b ON a.marker_2= b.m_order JOIN shgc_g3 c ON b.sts_name= c.sts_name where marker_1 = ? AND marker_2 between ? and ? order by marker_2";

#open conn
my $dbh = DBI->connect("DBI:mysql:database=$db:host=$host",
	$user, $password, {RaiseError=>1}) || die "dberror: ". DBI->errstr;
my $sth = $dbh->prepare($SQLX); 

#get the ycoords in bp and pvals
my $counter = 0;
for (my $i = $x1; $i<=$x2; $i++){
	$sth->execute($i ,$y1, $y2) || die "cannot execute query\n";
	while (my @rs = $sth->fetchrow_array()){
		#push
		#only need the ycoords once
		if ($counter== 0){ push @yvars,$rs[5]; }
		#need all pvals in order
		push @{$pvals->[$counter]},$rs[2]; 
	}
	$counter++;
}
#print "yvars--\n";
print Dumper(\@yvars);
#print "pvals--\n";
print Dumper($pvals);

#output
open(OUTPUT1, ">$ARGV[0]".".yval.txt");
foreach (@yvars){
	print OUTPUT1 "$_ ";
}
close OUTPUT1;

open(OUTPUT2, ">$ARGV[0]".".pval.txt");
for (my $i = 0; $i<= $#{$pvals}; $i++) {
	for (my $j=0; $j <=$#{$pvals->[$i]}; $j++){
		print OUTPUT2 "$pvals->[$i][$j] ";
	}
	print OUTPUT2 "\n";
}
close OUTPUT2;

#get xcoords in bp
my $SQLY="select a.m_order, b.chrom, b.chromStart from stsname_marker_link a JOIN shgc_g3 b ON a.sts_name = b.sts_name where a.m_order between ? and ? order by m_order";

$sth = $dbh->prepare($SQLY); 
$sth->execute($x1, $x2) || die "cannot execute query\n";
while (my @rs = $sth->fetchrow_array() ){
	push @xvars,$rs[2];
}
#print "xvars--\n";
#print Dumper(\@xvars);
open(OUTPUT3, ">$ARGV[0]".".xval.txt");
foreach (@xvars){
	print OUTPUT3 "$_ ";
}
close OUTPUT3;
