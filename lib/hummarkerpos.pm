# general package for storing G3 human marker positions by chrom
package hummarkerpos;

require Exporter;
use DBI;
use mysqldb;
use Math::Round;


@ISA = qw(Exporter);
@EXPORT = qw(&load_markerpos_from_db_range &load_markerpos_from_db 
	&load_markerpos_by_index 
	%hummarkerpos
	%hummarkerpos_by_index);

# create hashes of chroms pointing to start positions
#  humgenepos = {1=> {pos=> [start1 start2 ]
#											idx=>[1, 2...N]
#  									}, 
#  							 2=> [start1 start2 ],...

# use OUR to make it globally
our %hummarkerpos=();

# create hashes for 1..XY
for (my $i=1; $i<25; $i++){
	#pos is average start/stop
	$hummarkerpos{$i}{pos} = [];
	$hummarkerpos{$i}{start} = [];
	$hummarkerpos{$i}{stop} = [];
	$hummarkerpos{$i}{idx} = [];
}

# load into hash, avg start/stop pos 
sub load_markerpos_from_db{
	my $db = shift;
	my $dbh = db_connect($db);
	# take the midpoint of the gene
	my $sql = "select `index`, chrom, round((pos_start+pos_end)/2) from g3data.agil_poshg18 
		order by `index`";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		push @{$hummarkerpos{$rs[1]}{pos}}, $rs[2];
		push @{$hummarkerpos{$rs[1]}{idx}}, $rs[0];
	}
}

# same as above, but keep start/stop range
sub load_markerpos_from_db_range{
	my $db = shift;
	my $dbh = db_connect($db);
	# take the midpoint of the gene
	my $sql = "select `index`, chrom, pos_start,pos_end from g3data.agil_poshg18 
		order by `index`";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		push @{$hummarkerpos{$rs[1]}{start}}, $rs[2];
		push @{$hummarkerpos{$rs[1]}{stop}}, $rs[3];
		push @{$hummarkerpos{$rs[1]}{pos}}, round(($rs[2]+$rs[3])/2);
		push @{$hummarkerpos{$rs[1]}{idx}}, $rs[0];
	}
}

our %hummarkerpos_by_index=();
# create a hash keyed by marker index to point to position
sub load_markerpos_by_index{
	my $db = shift;
	my $dbh = db_connect($db);
	# take the midpoint of the gene
	my $sql = "select `index`, chrom, pos_start,pos_end from g3data.agil_poshg18 
		order by `index`";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$hummarkerpos_by_index{$rs[0]}{start} = $rs[2];
		$hummarkerpos_by_index{$rs[0]}{stop} = $rs[3];
		$hummarkerpos_by_index{$rs[0]}{pos} = round(($rs[2]+$rs[3])/2);
		$hummarkerpos_by_index{$rs[0]}{chrom} = $rs[1];
	}
}
1;

=head1 NAME

hummarkerpos - make human Agilent CGH markers available easily

 
=head1 SYNOPSIS

 # load data into %hummarkerpos keyed by chrom/pos(avg start/stop), idx 
 load_markerpos_from_db("g3data")

 # load data into %hummarkerpos keyed by chrom/start,stop,pos and idx 
 load_markerpos_from_db_range("g3data")

 # load data keyed by index 
 load_markerpos_by_index("g3data")

 # data structure exported to user, keyed by chrom,start/stop/pos/idx
 # chrom is 1..24, with 23=X and 24=Y
 %hummarkerpos = {1=> {pos=> [start1 start2 ],
                       idx=>[1, 2...N],
											 start=>[...],
											 stop=>[...]
                      }, 
                  2=> {pos=> [start1 start2 ],...
 
 # data structured used by load_markerpos_by_index()
 %hummarkerpos_by_index= { 1 =>{chrom =>1,
                                start => 30000,
                                stop => 40000,
                                pos => 35000
                               },
                           235829=>{chrom....
                                

=head1 AUTHOR

Richard Wang

=cut
