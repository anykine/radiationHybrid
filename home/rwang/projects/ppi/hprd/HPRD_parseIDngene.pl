#!/usr/bin/perl -w

#modified by richard
# from HPRD files, extract hprd id and get gene names

use strict;
use XML::Twig;
use Data::Dumper;
use DBI;

my $db = "ppi";
my $db_host = "localhost";
my $db_user = "root";
my $db_pass = "smith1";
my $dbh = DBI->connect("DBI:mysql:database=$db:host=$db_host",
	$db_user, $db_pass, {RaiseError=>1}) or die "dberror: ".DBI->errstr;

#-------- Global variables 
#my %hoh = "";

# xml interactorID -> gene name hash
my %interactor2gene = ();
my $twig_handlers = { 'interactor' => \&interactor_ext };
my $twig = new XML::Twig(TwigRoots=>{interactorList=>1}, TwigHandlers => $twig_handlers);
# ---------------Global Variables-------


#--------------MAIN Section-----


chdir "/home/josh/databasemanip/HPRD_PARSE/HPRD_PSIMI_060106/";

	# create a hash of interactions using HPRD id number as reference and most common or first occuring interactor as key
for (<*.xml>) {
		#print $_, "\n";
		$twig->parsefile($_);
		
		#print Dumper (\%hashHPRDids);
} 
#print Dumper(\%interactor2gene);
#print Dumper(\%network);
		
#writeData(\%interactor2gene);

#------------------------------ open directory loop-----------------------

# handles info about single protein; builds hash of id->gene name
# grab hprdid and get a gene name
sub interactor_ext{
	my($twig, $title) = @_;
	#print $title->att('id'),"\n";
	#return if $title->first_child('interactorType')->first_child('names')->first_child('shortLabel') eq "protein";
	my $hprd_id= $title->first_child('xref')->first_child('primaryRef')->att('id');
	#get gene name
	my $hprdref = $title->first_child('xref')->first_child('primaryRef');
	my @databases = $hprdref->next_siblings('secondaryRef');
	my $genename;
	my $agilent_genename;
	for my $i (@databases){ 
		if ($i->att('db') eq 'uniprot'){
			$genename = dbquery('uniprot', $i->att('id'));
			if (defined $genename){
				$agilent_genename= dbquery('agilent', $genename);
			}
			last if defined $agilent_genename;
		}elsif ($i->att('db') eq 'entrezgene'){
			$genename = dbquery('entrezgene', $i->att('id'));
			if (defined $genename){
				$agilent_genename= dbquery('agilent', $genename);
			}
			last if defined $agilent_genename;
		}elsif ($i->att('db') eq 'omim') {
			$genename = dbquery('omim', $i->att('id'));
			if (defined $genename){
				$agilent_genename= dbquery('agilent', $genename);
			}
			last if defined $agilent_genename;
		}
	}
	#add to hash of interactorID to genename
	print "$hprd_id\t$agilent_genename\n" if defined $agilent_genename;
	#$interactor2gene{$hprd_id} = $agilent_genename if defined $agilent_genename;
	
}

sub dbquery{
	my($database, $value) = @_;
	my $sql_swp = "select distinct gene from swp2gene2 where swp_acc=?";
	my $sql_omim = "select distinct symbol from omim_genes where omimID=?";
	my $sql_entrezgene= "select distinct symbol from acc2gn1 where geneid=?";
	my $sql_agilent= "select distinct name from agilentarray where name=?";
	my $sth ;
	if ($database eq 'uniprot'){
		$sth = $dbh->prepare($sql_swp); 
	} elsif ($database eq 'entrezgene') {
		$sth = $dbh->prepare($sql_entrezgene); 
	} elsif ($database eq 'omim') {
		$sth = $dbh->prepare($sql_omim); 
	} elsif ($database eq 'agilent') {
		$sth = $dbh->prepare($sql_agilent); 
	} else {
		warn "unrecognized database in dbquery\n";
		return;
	}
	$sth->execute($value);
	my($data) = $sth->fetchrow_array();
	return $data;
}

sub writeData{
	my($hashref) = shift;
	open(OUTPUT, ">hprdid_gene.txt") or die "cannot open file\n";
	while (my($k, $v) = each(%$hashref) ){
		print OUTPUT "$k\t@$v\n";
	}
}

