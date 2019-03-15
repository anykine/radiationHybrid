# general package for storing G3 human gene positions by chrom
package humgenepos;

require Exporter;
use DBI;
use mysqldb;

@ISA = qw(Exporter);
@EXPORT = qw(&load_genepos_from_db 
		&load_genepos_from_dbucsc 
    &load_genepos_from_dbucsc2_refseq
		&load_genepos_from_dbucsc2 
		&load_genepos_from_dbucsc2_refseq_microRNA
		&load_genepos_from_dbucsc2_microRNA
		%humgenepos);
# create hashes of chroms pointing to start positions
#  humgenepos = {1=>{pos=> [start1 start2 ]
#  									 idx=> [1,2...N]
#  									}, 
#  							 2=> [start1 start2 ],...

# use OUR to make it globally
our %humgenepos=();
# create hashes for 1..XY
for (my $i=1; $i<25; $i++){
	$humgenepos{$i}{pos} = [];
	$humgenepos{$i}{idx} = [];
}

# load into hash using ILMN genes
sub load_genepos_from_db{
	my $db = shift;
	my $dbh = db_connect($db);
	# take the midpoint of the gene
	# using ILMN gene list
	my $sql = "select `index`, chrom, round((pos_start+pos_end)/2) from g3data.ilmn_poshg18 
		order by `index`";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		push @{$humgenepos{$rs[1]}{pos}}, $rs[2];
		push @{$humgenepos{$rs[1]}{idx}}, $rs[0];
	}
}

# use the gene list from UCSC hg 18
# uses midpoint of gene
sub load_genepos_from_dbucsc{
	my $db = shift;
	my $dbh = db_connect($db);
	# take the midpoint of the gene

	my $sql = "select chrom, round((txStart+txEnd)/2) as pos from ucschg18.newknownGene
		order by chrom, pos";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$rs[0] =~ s/chrX/23/;
		$rs[0] =~ s/chrY/24/;
		$rs[0] =~ s/chr//;
		if ($rs[0] =~ /^\d{1,2}$/) {
			push @{$humgenepos{$rs[0]}{pos}}, $rs[1];
		}
	}
}

#using uscshg18
# stores chrom/start/stop
sub load_genepos_from_dbucsc2{
	my $db = shift;
	my $dbh = db_connect($db);

	my $sql = "select chrom, txStart, txEnd, round((txStart+txEnd)/2) as pos from ucschg18.newknownGene
		order by chrom, pos";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$rs[0] =~ s/chrX/23/;
		$rs[0] =~ s/chrY/24/;
		$rs[0] =~ s/chr//;
		if ($rs[0] =~ /^\d{1,2}$/) {
			push @{$humgenepos{$rs[0]}{pos}}, $rs[3];
			push @{$humgenepos{$rs[0]}{start}}, $rs[1];
			push @{$humgenepos{$rs[0]}{stop}}, $rs[2];
		}
	}
}

# gets all all known genes AND microRNAs
sub load_genepos_from_dbucsc2_microRNA{
	my $db = shift;
	my $dbh = db_connect($db);
	# I created this table to hold all genes + microRNAs
	my $sql = "select chrom, chromStart, chromEnd, round((chromStart+chromEnd)/2) as pos from ucschg18.rw_newknownGene_miRNA
		order by chrom, chromStart";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$rs[0] =~ s/chrX/23/;
		$rs[0] =~ s/chrY/24/;
		$rs[0] =~ s/chr//;
		if ($rs[0] =~ /^\d{1,2}$/) {
			push @{$humgenepos{$rs[0]}{pos}}, $rs[3];
			push @{$humgenepos{$rs[0]}{start}}, $rs[1];
			push @{$humgenepos{$rs[0]}{stop}}, $rs[2];
		}
	}
}

# gets the REFSEQ known genes
sub load_genepos_from_dbucsc2_refseq{
	my $db = shift;
	my $dbh = db_connect($db);
	
	my $sql = "select chrom, txStart, txEnd, round((txStart+txEnd)/2) as pos from ucschg18.newknownGene a
	  JOIN ucschg18.newkgXref b on a.name = b.kgID where b.refSeq != ''
		order by chrom, pos";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$rs[0] =~ s/chrX/23/;
		$rs[0] =~ s/chrY/24/;
		$rs[0] =~ s/chr//;
		if ($rs[0] =~ /^\d{1,2}$/) {
			push @{$humgenepos{$rs[0]}{pos}}, $rs[3];
			push @{$humgenepos{$rs[0]}{start}}, $rs[1];
			push @{$humgenepos{$rs[0]}{stop}}, $rs[2];
		}
	}
}

# gets the REFSEQ known genes + microRNA
sub load_genepos_from_dbucsc2_refseq_microRNA{
	my $db = shift;
	my $dbh = db_connect($db);
	
	my $sql = "select chrom, chromStart, chromEnd, round((chromStart+chromEnd)/2) as pos from ucschg18.rw_newknownGene_miRNA a
	  JOIN ucschg18.newkgXref b on a.name = b.kgID where b.refSeq != ''
		order by chrom, chromStart";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$rs[0] =~ s/chrX/23/;
		$rs[0] =~ s/chrY/24/;
		$rs[0] =~ s/chr//;
		if ($rs[0] =~ /^\d{1,2}$/) {
			push @{$humgenepos{$rs[0]}{pos}}, $rs[3];
			push @{$humgenepos{$rs[0]}{start}}, $rs[1];
			push @{$humgenepos{$rs[0]}{stop}}, $rs[2];
		}
	}
}

1;

=head1 NAME

humgenepos - make available location of each a list of genes. Currently ILMN and UCSC hg18 available

=head1 SYNOPSIS

 # datastructure holding positions
 # hashes of chroms pointing to start positions
  humgenepos = {1=>{pos=> [start1 start2 ]
                    idx=> [1,2...N]
                   }, 
                2=>{pos=> [start1 start2 ],...

 #load data from ILMN gene list
 load_genepos_from_db("human_rh")

 #load data from UCSC hg18
 load_genepos_from_dbucsc("ucschg18")

 #load data from UCSC hg18, with start and stop positions
 load_genepos_from_dbucsc2("ucschg18")
 humgenepos = {1=>{pos=> [pos1 pos2]
                    start=> [start1,start2...N]
                    stop => [stop1,stop2...N]
                   }, 

 #load data from UCSC hg18, start/stop plus microRNA
 load_genepos_from_dbucsc2_microRNA("ucschg18")

=head1 AUTHOR

Richard Wang
