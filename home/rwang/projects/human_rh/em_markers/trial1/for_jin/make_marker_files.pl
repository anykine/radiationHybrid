#!/usr/bin/perl -w
# make files, one for each chrom, of markers in order
# 
use DBI;
#######################
# CONSTANTS
#######################
$sqlmarkers = "SELECT g3_hybrid_scores from allg3_final1 where Chrom=? order by Chrom, chromStart";
$sqlmarkers_pos = "SELECT chromStart, chromEnd from allg3_final1 where Chrom=? order by Chrom, chromStart";
my($db,$hist,$user,$password,$sth);
$db="human_rh"; $host="localhost";$user="smithlab";$password="smithpass";
my $dbh=DBI->connect("DBI:mysql:database=$db:host=$host",
	$user,$password,{RaiseError=>1}) || die "dberror: ".DBI->errstr;

sub make_genotype_files{
	$sth = $dbh->prepare($sqlmarkers);
	for (my $i=1; $i<25; $i++){
		my $filename = "rh_genotype_chr" . $i . ".txt";
		open(OUTPUT, ">$filename") || die "cannot open file for output\n";
		$sth->execute($i);
		while (my @data = $sth->fetchrow_array() ) {
			print OUTPUT "$data[0]\n";			
		}
		close(OUTPUT);
	}
}

sub make_genotype_position_files{
	$sth = $dbh->prepare($sqlmarkers_pos);
	for (my $i=1; $i<25; $i++){
		my $filename = "rh_position_chr" . $i . ".txt";
		open(OUTPUT, ">$filename") || die "cannot open file for output\n";
		$sth->execute($i);
		while (my @data = $sth->fetchrow_array() ) {
			print OUTPUT "$data[0]\t$data[1]\n";
		}
		close(OUTPUT);
	}
}

sub test1{
	print "test1 running\n";
}
sub test2{
	print "test2 running\n";
}

sub display_menu(){
	print "1. test1\n2. test2\n";
	print "3. make genotype files\n4. make position files\n";
	print "pick a command to run: (ctrl-C to quit)\n";
}

## runcode

display_menu();
my $execcmd = <STDIN>;
chomp $execcmd;
if ($execcmd eq '1') {
	test1();
} elsif ($execcmd eq '2') {
	test2();
} elsif ($execcmd eq '3') {
	make_genotype_files();
} elsif ($execcmd eq '4') {
	make_genotype_position_files();
} else {
	print "unrecognized input\n";
	display_menu();
}
