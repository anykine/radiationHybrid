#!/usr/bin/perl -w

#modified by richard
# from HPRD files, extract prot-prot interactors, convert to gene
#  name, create hash of gene interactors

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

#-------- Global variables ----------------------------------------------------------------------------------------------
#my %hoh = "";

# xml interactorID -> gene name hash
my %interactor2gene = ();
# gene interaction hash
my %network = ();

my %participantcnt = (); # a hash that contains all the interactors in a file as keys and the number of instances they occur as values
						 # this hash is cleared before each file is opened


my %properties = (); # a hash that stores uniprot IDs as values given HPRD IDs as keys 

my @interaction =(); # an array of all the interactors in a file
																			#my @interactions = (); 
my $cntexist = 0 ;
my $keyname ="";

my $twig_handlers = { 'interactor' => \&interactor_ext , 'interaction' => \&participant_ext};
#my $twig_handlers = { 'interactor' => \&interactor_ext };
my $twig = new XML::Twig(TwigRoots=>{interactorList=>1, interactionList=>1}, TwigHandlers => $twig_handlers);
# -----------------------------------------------------------------------------------------------Global Variables-------


#--------------MAIN Section-----open directory here and run for loop to extract from each file------------------------------


chdir "/home/josh/databasemanip/HPRD_PARSE/HPRD_PSIMI_060106/";

	# create a hash of interactions using HPRD id number as reference and most common or first occuring interactor as key
for (<*.xml>) {
		$twig->parsefile($_);
		
		#print Dumper (\%hashHPRDids);
} 
#print Dumper(\%interactor2gene);
#print Dumper(\%network);
		
writeData(\%network);


#-----------------------------------------------------------------------------end open directory loop-----------------------

# handles interaction information (i.e. two prot that bind)
sub participant_ext{
	my ($twig,$title) = @_;
	my @genes=();
	# $title points to interaction element
	my $plist = $title->first_child('participantList');
	my @participants = $plist->children('participant');
	if (@participants >=2){
		foreach my $i (@participants) {
			if (exists $interactor2gene{$i->first_child('interactorRef')->text}){
				#store gene names in a array
				push @genes, $interactor2gene{$i->first_child('interactorRef')->text}
			}
		}
		#create/store gene interaction in hash
		my $key = shift @genes;
		foreach my $i (@genes) {
			if (exists $network{$key}){
				my $arraycontents = join(" ", @{$network{$key}});
				push @{$network{$key}}, $i unless $arraycontents =~ /$i/;
			} else {
				push @{$network{$key}}, $i ;
			}
		}

#		my $key = shift @genes;
#		if (exists $network{$key}) {
#			foreach my $i (@genes) {
#				my $arraycontents = join(" ", @{$network{$key}});
#				push @{$network{$key}}, $i unless $arraycontents =~ /$i/;
#			}
#		} else {
#			foreach my $i (@genes) {
#				next if not (e$network{$key});
#				my $arraycontents = join(" ", @{$network{$key}});
#				push @{$network{$key}}, $i unless $arraycontents =~ /$i/;
#			}
#		}

	}
}


# handles info about single protein; builds hash of id->gene name
sub interactor_ext{
	my($twig, $title) = @_;
	return if $title->first_child('interactorType')->first_child('names')->first_child('shortLabel') eq "protein";
	my $interactorID = $title->att('id');
	my $organism_id = $title->first_child('organism')->att('ncbiTaxId');
	#get gene name
	my $hprdref = $title->first_child('xref')->first_child('primaryRef');
	my @databases = $hprdref->next_siblings('secondaryRef');
	my $genename;
	for my $i (@databases){ 
		if ($i->att('db') eq 'uniprot'){
			$genename = dbquery('uniprot', $i->att('id'));
			last if defined $genename;
		}elsif ($i->att('db') eq 'entrezgene'){
			$genename = dbquery('entrezgene', $i->att('id'));
			last if defined $genename;
		}elsif ($i->att('db') eq 'omim') {
			$genename = dbquery('omim', $i->att('id'));
			last if defined $genename;
		}
	}
	#add to hash of interactorID to genename
	$interactor2gene{$interactorID} = $genename if defined $genename;
	
	#parse_interactions($twig, $title, $organism_id);
	#parse_information($twig, $title, $organism_id);
}

sub dbquery{
	my($database, $value) = @_;
	my $sql_swp = "select distinct gene from swp2gene2 where swp_acc=?";
	my $sql_omim = "select distinct symbol from omim_genes where omimID=?";
	my $sql_entrezgene= "select distinct symbol from acc2gn1 where geneid=?";
	my $sth ;
	if ($database eq 'uniprot'){
		$sth = $dbh->prepare($sql_swp); 
	} elsif ($database eq 'entrezgene') {
		$sth = $dbh->prepare($sql_entrezgene); 
	} elsif ($database eq 'omim') {
		$sth = $dbh->prepare($sql_omim); 
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
	while (my($k, $v) = each(%$hashref) ){
		print "$k\t@$v\n";
	}
}
# ----------- unused ----------------------
# ----------- unused ----------------------
# ----------- unused ----------------------
sub parse_information{

	my($twig, $title, $organism_id) = @_;


	if (($organism_id eq "10090" || $organism_id eq "9606") && ($title->first_child('interactorType')->first_child('names')->field('shortLabel') eq "protein"   ))		{
			
			my $interactor = $title->att('id');
			my @dbSecRefs =$title->first_child('xref')->first_child('primaryRef')->next_siblings('secondaryRef');
			my $uniprotID = "";
			foreach my $j ( @dbSecRefs ) {
					if ($j->att('db') eq "uniprot") 
						{
						$uniprotID = $j->att('id');
						print $uniprotID , " \n";
						}
				
				}
						

			# only assign uniprotID to HPRD interator if not null

			if ($uniprotID ne "")
				{
					$properties{$interactor}={'uniprot'	=> "$uniprotID" };
				}
		}
}


sub parse_interactions{

	my($twig, $title, $organism_id) = @_;
	
	 if ($organism_id eq "10090" || $organism_id eq "9606" )
		{
			push (@interaction, $title->att('id'));
		}
}

