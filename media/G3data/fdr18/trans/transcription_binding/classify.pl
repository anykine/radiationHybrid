#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;
use DBI;
use lib '/home/rwang/lib';
use hummarkerpos;
use mysqldb;

# 1. find closest marker to each gene
# 2. determine if marker has trans ceQTL
# 3. 
#  create list of gene symbols that 
#  1. have a trans ceQTL < fdr40
#  2. do not have a trans ceQTL < fdr40
#

my %trans40=();
my %humgenepos=();
my %genes_with_trans=();

# mark those markers with FDR40
sub load_trans40{
	my $fdr = shift;
	my $file =  join("", "/media/G3data/fdr18/trans/trans_peaks_FDR", $fdr,".txt");
	open(INPUT, $file) || die "cannot open file FDR $fdr";
	while(<INPUT>){
		chomp; next if /^#/;
		my(undef, $marker, undef, undef) = split(/\t/);
		$trans40{$marker} = 1;
	}
}


# load the gene pos
# expose %humgenepos;
sub load_gene{
	my $dbh= db_connect("g3data");	
	my $sql = "select `index`, chrom, pos_start,pos_end,symbol from g3data.ilmn_sym order by `index`";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	while(my @rs = $sth->fetchrow_array() ){
		$humgenepos{$rs[0]} = {
			chrom=> $rs[1],
			start => $rs[2],
			stop => $rs[3],
			symbol => $rs[4]
		};
		# load up all the genes
		$genes_with_trans{$rs[4]} = 0;
	}
	#print Dumper(\%humgenepos);
	
	#foreach my $idx (sort {$a<=>$b} keys %humgenepos){
	#	print $idx,"\n";
	#	print $humgenepos{$idx}{chrom},"\t";
	#	print $humgenepos{$idx}{start},"\t";
	#	print $humgenepos{$idx}{stop},"\t";
	#	print $humgenepos{$idx}{symbol},"\n";
	#}
}


# find genes with trans eqtls nearby
sub search_closest_trans_to_gene{

	load_markerpos_from_db_range("g3data");
	#iter over all genes
	foreach my $idx (sort {$a<=>$b} keys %humgenepos){
		my $chr= $humgenepos{$idx}{chrom};
		my $start = $humgenepos{$idx}{start};
		my $stop = $humgenepos{$idx}{stop};
		my $symbol = $humgenepos{$idx}{symbol};

		#print "$chr\t$start\t$stop\t$symbol\n";
		#iter over markers on same chrom
		#print scalar @{$hummarkerpos{$chr}{pos}},"\n";
		for (my $m=0; $m < scalar @{$hummarkerpos{$chr}{pos}}; $m++	){
			#print ${$hummarkerpos{$chr}{pos}}[$m],"\t",$start,"\n";
			my $diffs = ${$hummarkerpos{$chr}{pos}}[$m] - $start;
			my $diffe = ${$hummarkerpos{$chr}{pos}}[$m] - $stop;
			# marker is within 1mb
			if (abs($diffs) < 1000000 || abs($diffe) < 1000000) {
				my $marker = ${$hummarkerpos{$chr}{idx}}[$m];
				#is marker <fdr40
				if (defined $trans40{$marker} && $trans40{$marker}==1 ){
					#push @{$results{$symbol}}, ${$hummarkerpos{$chr}{idx}}[$m];
					$genes_with_trans{$symbol}=1;
				}
			}
		}
	}
}
	
# search closest marker to gene, using center of gene
sub search_closest_trans_to_gene2{
	my $limit = shift;
	load_markerpos_from_db_range("g3data");
	#iter over all genes
	foreach my $idx (sort {$a<=>$b} keys %humgenepos){
		my $chr= $humgenepos{$idx}{chrom};
		my $start = $humgenepos{$idx}{start};
		my $stop = $humgenepos{$idx}{stop};
		my $symbol = $humgenepos{$idx}{symbol};
		my $pos = ($start+$stop)/2;
		#print "$chr\t$start\t$stop\t$symbol\n";
		#iter over markers on same chrom
		#print scalar @{$hummarkerpos{$chr}{pos}},"\n";
		for (my $m=0; $m < scalar @{$hummarkerpos{$chr}{pos}}; $m++	){
			#print ${$hummarkerpos{$chr}{pos}}[$m],"\t",$start,"\n";
			my $diff = ${$hummarkerpos{$chr}{pos}}[$m] - $pos;
			# marker is within 1mb
			if (abs($diff) < $limit) {
				my $marker = ${$hummarkerpos{$chr}{idx}}[$m];
				#is marker <fdr40
				if (defined $trans40{$marker} && $trans40{$marker}==1 ){
					#push @{$results{$symbol}}, ${$hummarkerpos{$chr}{idx}}[$m];
					$genes_with_trans{$symbol}=1;
				}
			}
		}
	}
}

# use start position of genes/markers
# marker cannot be a neighbor to > 1 gene
# use UCSC known gene + microRNA gene set
sub search_closest_trans_to_gene3{
	my $limit = shift;
	load_markerpos_from_db_range("g3data");
	#iter over all genes
	foreach my $idx (sort {$a<=>$b} keys %humgenepos){
		my $chr= $humgenepos{$idx}{chrom};
		my $start = $humgenepos{$idx}{start};
		my $stop = $humgenepos{$idx}{stop};
		my $symbol = $humgenepos{$idx}{symbol};
		my $pos = ($start+$stop)/2;
		#print "$chr\t$start\t$stop\t$symbol\n";
		#iter over markers on same chrom
		#print scalar @{$hummarkerpos{$chr}{pos}},"\n";
		for (my $m=0; $m < scalar @{$hummarkerpos{$chr}{pos}}; $m++	){
			#print ${$hummarkerpos{$chr}{pos}}[$m],"\t",$start,"\n";
			my $diff = ${$hummarkerpos{$chr}{pos}}[$m] - $pos;
			# marker is within 1mb
			if (abs($diff) < $limit) {
				my $marker = ${$hummarkerpos{$chr}{idx}}[$m];
				#is marker <fdr40
				if (defined $trans40{$marker} && $trans40{$marker}==1 ){
					#push @{$results{$symbol}}, ${$hummarkerpos{$chr}{idx}}[$m];
					$genes_with_trans{$symbol}=1;
				}
			}
		}
	}
}

sub test{

	load_markerpos_from_db_range("g3data");
	foreach my $idx (sort {$a<=>$b} keys %humgenepos){
		$idx=1;
		my $chr= $humgenepos{$idx}{chrom};
		my $start = $humgenepos{$idx}{start};
		my $stop = $humgenepos{$idx}{stop};
		my $symbol = $humgenepos{$idx}{symbol};
	#iter over all genes
		print "size is ", scalar @{$hummarkerpos{1}{pos}},"\n";
		for (my $m=0; $m < scalar @{$hummarkerpos{1}{pos}}; $m++	){
			#print ${$hummarkerpos{1}{pos}}[$m],"\n";
			print ${$hummarkerpos{$chr}{pos}}[$m],"\t",$start,"\n";
		}
		exit(1);
	}
}

# compute all distances between marker/gene pairs using startpos
# to save space, separate by chromosome
sub all_dist{
	#get gene pos
	#testing
	load_genepos_from_dbucsc2_microRNA();
	print Dumper(%humgenepos);
}

# output the results
sub output{
	foreach my $g (sort keys %genes_with_trans){
		print "$g\t$genes_with_trans{$g}\n";	
	}
}

############# MAIN ##################
unless (@ARGV==2){
	print "usage $0 <FDR level, eg 40, 30> <distance to gene, 100000, 1000000>\n";
	exit;
}
load_trans40($ARGV[0]);
load_gene();
#print Dumper(\%humgenepos);
#search_closest_trans_to_gene();
search_closest_trans_to_gene2($ARGV[1]);
#test();
output();

