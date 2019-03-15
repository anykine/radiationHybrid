#!/usr/bin/perl -w
#
use strict;
use DBI;
use Data::Dumper;

#get data from database
sub get_sym_pos{
	my $dbh = DBI->connect('dbi:mysql:database=mouse_rhdb; host=localhost', 'root', 'smith1', {RaiseError=>1});
	my $results = $dbh->selectall_arrayref("select `index`, probename, chrom, pos_start, pos_end from probe_gc_final1 order by `index`");
	#print Dumper($results);
	return $results;
}

# read in cis file and annotate
# format: gene#, marker#, alpha, nlp
# format: h.chrom, h.start, h.stop, h.index, h.alpha, m.index, m.alpha
sub annot_file{
	my ($file, $results) = @_;
	open(INPUT, $file) || die "err $!";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/); my $gene = $d[5]-1;
		print join("\t", 
				$$results[$gene][1],
				#$$results[$gene][3],
				#$$results[$gene][4],
				#$$results[$gene][5],
				@d
				), "\n";
	}
}

## MAIN 
my $res = get_sym_pos();
#annot_file("cis_FDR40.txt", $res);
#annot_file("mouse_cis_peaks_FDR40.txt", $res);
annot_file("comp_MH_FDR30.txt", $res);
