#!/usr/bin/perl -w
#
use strict;
use DBI;
use Data::Dumper;

#get data from database
sub get_sym_pos{
	my $dbh = DBI->connect('dbi:mysql:database=g3data; host=localhost', 'root', 'smith1', {RaiseError=>1});
	my $results = $dbh->selectall_arrayref("select `index`, probename, chrom, pos_start, pos_end, symbol from ilmn_sym order by `index`");
	#print Dumper($results);
	return $results;
}

# read in cis file and annotate
# format: gene#, marker#, alpha, nlp
sub annot_file{
	my ($file, $results) = @_;
	open(INPUT, $file) || die "err $!";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/); my $gene = $d[0]-1;
		print join("\t", 
				$$results[$gene][2],
				$$results[$gene][3],
				$$results[$gene][4],
				$$results[$gene][5],
				@d
				), "\n";
	}
}

## MAIN 
my $res = get_sym_pos();
#annot_file("cis_FDR40.txt", $res);
annot_file("cis_2mb/cis_FDR30.txt", $res);
