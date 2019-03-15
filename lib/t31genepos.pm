# general package for storing G3 t31an gene positions by chrom
package t31genepos;

require Exporter;
use DBI;
use mysqldb;

@ISA = qw(Exporter);
@EXPORT = qw(&load_genepos_from_db &load_genepos_from_dbucsc 
          &load_genepos_from_dbucsc2 
					&load_genepos_from_dbucsc2_refseq_microRNA
					%t31genepos);
# create hashes of chroms pointing to start positions
#  t31genepos = {1=>{pos=> [start1 start2 ]
#  									 idx=> [1,2...N]
#  									}, 
#  							 2=> [start1 start2 ],...

# use OUR to make it globally
our %t31genepos=();

# create hashes for 1..XY
for (my $i=1; $i<21; $i++){
	$t31genepos{$i}{pos} = [];
	$t31genepos{$i}{idx} = [];
}

# load into hash using Agilent microarray genes
sub load_genepos_from_db{
	my $db = shift;
	my $dbh = db_connect($db);
	# take the midpoint of the gene
	my $sql = "select `index`, chrom, round((pos_start+pos_end)/2) from 
	            mouse_rhdb.probe_gc_final1 order by `index`";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		push @{$t31genepos{$rs[1]}{pos}}, $rs[2];
		push @{$t31genepos{$rs[1]}{idx}}, $rs[0];
	}
}

# use the gene list from UCSC mm7
# store midpoint of gene
sub load_genepos_from_dbucsc{
	my $db = shift;
	my $dbh = db_connect($db);

	# take the midpoint of the gene
	my $sql = "select chrom, round((txStart+txEnd)/2) as pos from 
	           ucscmm7.knownGene order by chrom, pos";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$rs[0] =~ s/chrX/20/;
		$rs[0] =~ s/chrY/21/;
		$rs[0] =~ s/chr//;
		if ($rs[0] =~ /^\d{1,2}$/) {
			push @{$t31genepos{$rs[0]}{pos}}, $rs[1];
		}
	}
}

# UCSC mm7 store start/stop positions
sub load_genepos_from_dbucsc2{
	my $db = shift;
	my $dbh = db_connect($db);
	
	my $sql = "select chrom, txStart, txEnd, round((txStart+txEnd)/2) as pos 
	           from ucscmm7.knownGene order by chrom, pos";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$rs[0] =~ s/chrX/20/;
		$rs[0] =~ s/chrY/21/;
		$rs[0] =~ s/chr//;
		if ($rs[0] =~ /^\d{1,2}$/) {
			push @{$t31genepos{$rs[0]}{pos}}, $rs[3];
			push @{$t31genepos{$rs[0]}{start}}, $rs[1];
			push @{$t31genepos{$rs[0]}{stop}}, $rs[2];
		}
	}
}

# UCSC mm7 knownGene and microRNA
sub load_genepos_from_dbucsc2_refseq_microRNA{
	my $db = shift;
	my $dbh = db_connect($db);
	
	my $sql = "select chrom, chromStart, chromEnd, round((chromStart+chromEnd)/2) as pos 
	           from ucscmm7.rw_knownGene_miRNA a join kgXref b on a.name = b.kgId
						 where b.refseq != '' order by chrom, chromStart";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$rs[0] =~ s/chrX/20/;
		$rs[0] =~ s/chrY/21/;
		$rs[0] =~ s/chr//;
		if ($rs[0] =~ /^\d{1,2}$/) {
			push @{$t31genepos{$rs[0]}{pos}}, $rs[3];
			push @{$t31genepos{$rs[0]}{start}}, $rs[1];
			push @{$t31genepos{$rs[0]}{stop}}, $rs[2];
		}
	}
}

1;

=head1 NAME

t31genepos - make available location of mouse genes (microarray or ucscmm7) 

=head1 SYNOPSIS

 # datastructure holding positions
 # hashes of chroms pointing to start positions
  t31genepos = {1=>{pos=> [start1 start2 ]
                    idx=> [1,2...N]
                   }, 
                2=>{pos=> [start1 start2 ],...

 #load data from microarray gene list
 load_genepos_from_db("mouse_rhdb")

 #load data from UCSC mm7 
 load_genepos_from_dbucsc("ucscmm7")

 #load data from UCSC mm7, with start and stop positions
 load_genepos_from_dbucsc2("ucscmm7")
 t31genepos = {1=>{pos=> [pos1 pos2]
                    start=> [start1,start2...N]
                    stop => [stop1,stop2...N]
                   }, 

=head1 AUTHOR

Richard Wang
