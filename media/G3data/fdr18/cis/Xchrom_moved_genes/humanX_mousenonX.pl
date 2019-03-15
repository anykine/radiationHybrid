#!/usr/bin/perl -w

# goal is to find X genes on human and see if they ARE NOT
# X genes in mouse 
use strict;
use Data::Dumper;
use DBI;

######### globals #########
my %genes=();

######### run #########
readHumanXData();
lookupMouseX();

######### funcs ############
sub lookupMouseX{
	my $sql = "select a.chrom, b.genename, a.index from mouse_rhdb.probe_gc_final1 a 
		join mouse_rhdb.agilent_array_upd070126 b on a.probename = b.probename
		where b.genename = ?";
	my $dbh = db_connect();
	my $sth = $dbh->prepare($sql);
	foreach my $k (keys %genes){
		$sth->execute($k);
		my($chr, $symbol,$idx) = $sth->fetchrow_array();
		if (defined $chr && $chr !='20') {
			#print "***" if $chr != '23';
			print "$idx\t$chr\t$symbol\n";
		} else {
			#print "unk\t";
		}
		#print "$chr\t$symbol\n";
		#print $symbol,"\n" if ($chr !=	23);
	}
}

#read in file
sub readHumanXData{
	open(INPUT, "human_x_genes.txt") || die "cannot open file\n";
	while(<INPUT>){
		next if /^#/;
		chomp;
		$genes{ (split(/\t/))[1] } = 1;
	}
	#print Dumper(\%genes);
}

sub db_connect{
	my $dbh = DBI->connect("DBI:mysql:database=g3data:host=localhost",
		"root", "smith1", {RaiseError=>1}) or die "dberror: ".DBI->errstr;
	return $dbh;
}

