#!/usr/bin/perl -w
#
# matching of ilmn gene symbol to symatlas gene symbols is poor.
# to improve it, try using hugo aliases
# Keep every thing UPPERCASE
use strict;
use Data::Dumper;
use DBI;

my %hugo= ();


# store all hugo: keys={prevsym{key1}=>cursym, alias{key10}=>cursym}
sub load_hugo{
	open(INPUT, "hgnc_downloads.txt") || die "cannot open HGNC";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		# previous symbol
		if (defined $d[4] && defined $d[1]){
			my @list = split(/,\s+/, $d[4]);
			foreach my $k (@list){
				$hugo{prevsym}{$k} = $d[1];
			}
		}
		# aliases
		if (defined $d[5] && defined $d[1]){
			my @list = split(/,\s+/, $d[5]);
			foreach my $k (@list){
				$hugo{alias}{$k} = $d[1];
			}
		}
	}
	#print Dumper(\%hugo);exit(1);
}

my @hugoarray=();
# this loads each line of HUGO file into array, basically each line
# is one entity: a list of gene symbols/aliases that all point to the same entity
sub load_hugo2{
	open(INPUT, "hgnc_downloads.txt") || die "cannot open HGNC";
	#open(INPUT, "h1.test") || die "cannot open HGNC";
	#my @hugoarray=();
	my $counter=0;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		# previous symbol
		if (defined $d[4] && defined $d[1] ){
			my @list = split(/,\s+/, $d[4]);
			push @{$hugoarray[$counter]}, $d[1];
			foreach my $k (@list){
				#print $k,"\n";
				push @{$hugoarray[$counter]}, $k;
			}
		}
		# aliases
		if (defined $d[5] && defined $d[1] ){
			my @list = split(/,\s+/, $d[5]);
			foreach my $k (@list){
				#print $k,"\n";
				push @{$hugoarray[$counter]}, $k;
			}
		}
		$counter++;
	}
	#print Dumper(\@hugoarray);exit(1);
}

my %genelist=();

# load ILMN gene symbols and mark those genes 
# already defined in common
sub load_ilmn{
	my $dbh = DBI->connect('dbi:mysql:database=symatlas;host=localhost', 'root', 'smith1', {RaiseError=>1});
	my $results = $dbh->selectcol_arrayref("select symbol from ilmn_exclude_affy_gnf1h");
	# make hash of ILMN genes
	%genelist = map {uc($_) => 0} @$results;
	# mark common genes as 1
	#open(INPUT, "ilmn_sym_match.txt") || die "cannot open matched symbols";
	#my %templist = map { chomp; $_ => 1}
	#	grep { !/^#/}
	#	<INPUT>;
	#foreach my $k (keys %templist){
	#	$genelist{$k} = 1 if defined $genelist{$k};		
	#}
}

# iter through genes list,
# for every entry, search 
sub search_affy_for_match{
	my $dbh = DBI->connect('dbi:mysql:database=symatlas;host=localhost', 'root', 'smith1', {RaiseError=>1});
	my $results = $dbh->selectcol_arrayref("select symbol from affy_exclude_ilmn");
	# make hash of AFFY genes
	my %affygenes = map {uc($_) => 0} @$results;
	print "#affy_gene\tilmn_gene\n";
	foreach my $k (keys %affygenes){
		
		# iter over hugoarray
		for (my $i=0; $i< scalar @hugoarray; $i++){
			if (defined $hugoarray[$i]){
				# iter over subarray
				for (my $j=0; $j < scalar @{$hugoarray[$i]}; $j++){
					# find 
					if ($k eq $hugoarray[$i][$j]){
						#print "match of symbol $k\n";	
						#check if another match in that line to ILMN
						if (my $result = inILMNrow($hugoarray[$i])) {
							#print "match of ILMN\n";
							# affygene | ilmn gene
							if ($result){
								print "$k\t$result\n";
							}
						}
					}
					#print $hugoarray[$i][$j],"\n";
				}
			}
		}
	}
}

# given a row of symbols, see if any member of row
# is  in the ILMN list
sub inILMNrow{
	my ($row ) = @_;
	#print join("\t",@$row),"\n";return;
	#iter over row
	foreach my $k (@$row){
		if (defined $genelist{$k} ){
				if ($genelist{$k} == 0) {
					$genelist{$k} = 1;
					#print $k,"\n";
					return $k;
				}
		}
	}
	return 0;
}

# as we read the file, try the prev symbols and aliases until it matches 
# the ILMN genelist, the mark it as found (set to 1)
sub match{
	# list of symatlas genes
	open(INPUT, "symgenes.txt") || die "cannot open list of symatlas gnees";
	while(<INPUT>){
		chomp; next if /^#/;	
		# first check if its already marked in ILMN list
		next if (defined $genelist{$_} && $genelist{$_} ==1);
		# try against hugo prev symbols
		if (defined $hugo{prevsym}{$_}){
			print "trying symgene prevsym $_ \n";
			my $testsym = $hugo{prevsym}{$_};
			if (inILMN($testsym)){
				print "\tfound prevsym ", $testsym,"\n";
			}
		}
		# try against hugo aliases
		if (defined $hugo{alias}{$_}){
			print "trying symgene alias $_\n";
			my $testsym = $hugo{alias}{$_};
			if (inILMN($testsym)){
				print "\tfound in alias", $testsym, "\n";	
			}
		}
	}
}

# general routine to check if gene symbol is in ILMN
sub inILMN{
	my ($sym ) = shift;
	if (defined $genelist{$sym}	){
		$genelist{$sym} = 1;
		return 1;
	} else {
		return 0;
	}
}

#how much of the ILMN hash is 1
sub summarize{
	my $counter = 0;
	foreach my $k (keys %genelist){
		$counter++ if $genelist{$k} == 1;
		print "$k\t$genelist{$k}\n";
	}
	print "$counter out of ", scalar keys %genelist,"\n";
}




########### MAIN ###################

load_hugo2();             #load the @hugoarray
load_ilmn();              #put ilmn genes into %genelist
search_affy_for_match();  #iter %affygenes
print "-------\n";
summarize();
