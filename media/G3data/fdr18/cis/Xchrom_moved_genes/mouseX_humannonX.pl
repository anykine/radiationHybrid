#!/usr/bin/perl -w

# goal is to find X genes on mouse and see if they ARE NOT
# X genes in human
use strict;
use Data::Dumper;
use DBI;

my %genes=();

#read in file
open(INPUT, "mouse_x_genes.txt") || die "cannot open file\n";
while(<INPUT>){
	next if /^#/;
	chomp;
	$genes{ (split(/\t/))[1] } = 1;
}
#print Dumper(\%genes);

my $sql = "select b.chrom,a.symbol,b.index from human_rh.ilmn_ref8 a join 
g3data.ilmn_poshg18 b on a.target= b.probename
where a.symbol=?";

my $dbh = db_connect();
my $sth = $dbh->prepare($sql);
foreach my $k (keys %genes){
	$sth->execute($k);
	my($chr, $symbol,$idx) = $sth->fetchrow_array();
	if (defined $chr && $chr !='23') {
		#print "***" if $chr != '23';
		print "$idx\t$chr\t$symbol\n";
	} else {
		#print "unk\t";
	}
	#print "$chr\t$symbol\n";
	#print $symbol,"\n" if ($chr !=	23);

}

sub db_connect{
	my $dbh = DBI->connect("DBI:mysql:database=g3data:host=localhost",
		"root", "smith1", {RaiseError=>1}) or die "dberror: ".DBI->errstr;
	return $dbh;
}

