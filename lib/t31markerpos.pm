# general package for storing T31 mouse marker positions by chrom
package t31markerpos;

require Exporter;
use DBI;
use mysqldb;
use Math::Round;
use Data::Dumper;

@ISA = qw(Exporter);
@EXPORT = qw(&load_markerpos_from_db_range &load_markerpos_from_db 
	&load_markerpos_by_index 
	%t31markerpos
	%t31markerpos_by_index);

# create hashes of chroms pointing to start positions
#  t31markerpos = {1=> {pos=> [start1 start2 ]
#											idx=>[1, 2...N]
#  									}, 
#  							 2=> [start1 start2 ],...

# use OUR to make it globally
our %t31markerpos=();

# create hashes for 1..XY
for (my $i=1; $i<21; $i++){
	#pos is average start/stop
	$t31markerpos{$i}{pos} = [];
	$t31markerpos{$i}{start} = [];
	$t31markerpos{$i}{stop} = [];
	$t31markerpos{$i}{idx} = [];
}

# load into hash, avg start/stop pos 
sub load_markerpos_from_db{
	my $db = shift;
	my $dbh = db_connect($db);
	# take the midpoint of the gene
	my $sql = "select `idx`, chrom, round((pos_start+pos_end)/2) from mouse_rhdb.cgh_pos 
		order by `idx`";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		push @{$t31markerpos{$rs[1]}{pos}}, $rs[2];
		push @{$t31markerpos{$rs[1]}{idx}}, $rs[0];
	}
}

# same as above, but keep start/stop range
sub load_markerpos_from_db_range{
	my $db = shift;
	my $dbh = db_connect($db);
	# take the midpoint of the gene
	my $sql = "select `idx`, chrom, pos_start,pos_end from mouse_rhdb.cgh_pos
		order by `idx`";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		push @{$t31markerpos{$rs[1]}{start}}, $rs[2];
		push @{$t31markerpos{$rs[1]}{stop}}, $rs[3];
		push @{$t31markerpos{$rs[1]}{pos}}, round(($rs[2]+$rs[3])/2);
		push @{$t31markerpos{$rs[1]}{idx}}, $rs[0];
	}
}

our %t31markerpos_by_index=();
# create a hash keyed by marker index to point to position
sub load_markerpos_by_index{
	my $db = shift;
	my $dbh = db_connect($db);
	# take the midpoint of the gene
	my $sql = "select `idx`, chrom, pos_start,pos_end from mouse_rhdb.cgh_pos 
		order by `idx`";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$t31markerpos_by_index{$rs[0]}{start} = $rs[2];
		$t31markerpos_by_index{$rs[0]}{stop} = $rs[3];
		$t31markerpos_by_index{$rs[0]}{pos} = round(($rs[2]+$rs[3])/2);
		$t31markerpos_by_index{$rs[0]}{chrom} = $rs[1];
	}
}
1;

=head1 NAME

t31markerpos - make mouse Agilent CGH markers available easily

 
=head1 SYNOPSIS

 # load data into %t31markerpos keyed by chrom/ pos(avg start/stop) and idx 
 load_markerpos_from_db("mouse_rhdb")

 # load data into %t31markerpos keyed by chrom/ start,stop,pos and idx 
 load_markerpos_from_db_range("mouse_rhdb")

 # load data into %31markerpos_by_index keyed by index/chrom,start,stop,pos
 load_markerpos_by_index("mouse_rhdb")

 # data structure exported to user, keyed by chrom,start/stop/pos/idx
 # chrom is 1..24, with 23=X and 24=Y
 %t31markerpos = {1=> {pos=> [start1 start2 ],
                       idx=>[1, 2...N]
                      }, 
                  2=> {pos=> [start1 start2 ],...
 
 # data structured used by load_markerpos_by_index()
 %t31markerpos_by_index= { 1 =>{chrom =>1,
                                start => 30000,
                                stop => 40000,
                                pos => 35000
                               },
                           232626=>{chrom....
                                

=head1 AUTHOR

Richard Wang

=cut
