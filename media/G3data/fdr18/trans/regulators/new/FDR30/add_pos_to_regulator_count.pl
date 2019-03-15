#!/usr/bin/perl -w
# Add position info to regulator count files

use strict;
use DBI;
use Data::Dumper;

#get hum pos data from database
sub get_hum_marker_pos{
	my $dbh = DBI->connect('dbi:mysql:database=g3data; host=localhost', 'root', 'smith1', {RaiseError=>1});
	my $results = $dbh->selectall_arrayref("select `index`, chrom, pos_start, pos_end from agil_poshg18 order by `index`");
	#print Dumper($results);
	return $results;
}

#get mus pos data from database
sub get_mus_marker_pos{
	my $dbh = DBI->connect('dbi:mysql:database=mouse_rhdb; host=localhost', 'root', 'smith1', {RaiseError=>1});
	my $results = $dbh->selectall_arrayref("select `idx`, chrom, pos_start, pos_end from cgh_pos order by `idx`");
	#print Dumper($results);
	return $results;
}

# read in cis file and annotate
# format: gene#, marker#, alpha, nlp
sub annot_hum_file{
	my ($file, $results) = @_;
	open(INPUT, $file) || die "err $!";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/); my $marker = $d[0]-1;
		#print marker, chrom, start, stop, counts
		print join("\t", 
				$d[0],
				$$results[$marker][1],
				$$results[$marker][2],
				$$results[$marker][3],
				$d[2]
				), "\n";
	}
}

# mouse file does not contain counts, so 
# generate counts like human file
sub annot_mus_file{
	my ($file, $results) = @_;
	my %m = ();
	open(INPUT, $file) || die "err $!";
	# get counts and add pos
	while(<INPUT>){
		chomp; next if /^#/;
		#file is gene | marker | alpha | nlp
		my @d = split(/\t/); my $marker = $d[1]-1;
		
		if (defined $m{$d[1]}){
			$m{$d[1]}{count}++;
		} else {
			$m{$d[1]} = {
				chrom => $$results[$marker][1],
				start => $$results[$marker][2],
				stop => $$results[$marker][3],
				count => 1
				};	
		}
	}

	#print marker, chrom, start, stop, counts
	foreach my $k (sort {$a<=>$b} keys %m){
		print join("\t", 
			$m{$k}{chrom},
			$m{$k}{start},
			$m{$k}{stop},
			$k,
			$m{$k}{count}
		),"\n";
	}
	#print Dumper(\%m);
}
######## MAIN ###########
# human
#my $hres = get_hum_marker_pos();
#annot_hum_file("../../regulator_countFDR30.txt", $hres);

# mus

my $mres = get_mus_marker_pos();
annot_mus_file("../mouse/mouse_trans_peaks_3.99.txt", $mres);
