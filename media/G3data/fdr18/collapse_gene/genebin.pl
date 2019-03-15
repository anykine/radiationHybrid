#!/usr/bin/perl -w
#
use strict;
use Data::Dumper;
use DBI;
use lib '/home/rwang/lib';
use mysqldb;
use hummarkerpos;

# bin the peaks into genes; id which gene a marker falls into;
#

unless(@ARGV==1){
	print <<EOH;
	usage $0 <file of gene pos>

	Bin the peaks into gene regions. G3data.
EOH
exit(1);
}

my %intervals=();

# NOT FINISHED
sub load_gene_intervals{
	my($fh) = @_;
	open(INPUT, $fh) || die "cannot open gene pos\n";
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		next if $data[0] !~ /chr\d{1,2}$/;
		
		print $data[0],"\n"; 
		push @{$intervals{ $data[0]=~s/chr//}{start}}, $data[1];
		push @{$intervals{ $data[0]=~s/chr//}{stop}}, $data[2];
	}
	#print Dumper(\%intervals);
}


# find the genes regulated by the gene on the gene list
sub find_jakes_genes{
	# read in list of names
	my @genes=();
	open(INPUT, "jakelist.txt") || die "cannoe open gene list\n";
	while(<INPUT>){
		chomp;
		push @genes, $_;
	}
	close(INPUT);

	# get the list of positions for these genes
	
	my $dbh=db_connect("g3data");
	my $sql1="SELECT a.index,a.chrom,a.pos_start,a.pos_end, b.symbol 
	 from g3data.ilmn_poshg18 a join human_rh.ilmn_ref8 b on
	 a.probename=b.target where b.symbol=?";

	my $sql2=qq{select a.chrom, a.chromStart, a.chromEnd, b.geneSymbol
	  from ucschg18.knownCanonical081027 a join ucschg18.kgXref081027 b
		on a.transcript=b.kgID where b.geneSymbol=?};
	my $sth = $dbh->prepare($sql2);
	foreach my $g (@genes){
		$sth->execute($g);
		while( my($chr,$start,$stop,$sym) =$sth->fetchrow_array()){
			next if $chr !~ /chr\d{1,2}$/;
			$chr =~ s/chr//ig;
			# get the longest stretch of gene
			if (defined $intervals{$chr}{$sym} ) {
				if ($start < $intervals{$chr}{$sym}{start}){
					$intervals{$chr}{$sym}{start} = $start;
				}
				if ($stop > $intervals{$chr}{$sym}{stop}){
					$intervals{$chr}{$sym}{stop} = $stop;
				}
			} else {
				$intervals{$chr}{$sym}{start}  = $start;
				$intervals{$chr}{$sym}{stop} =  $stop;
			}
		}
	}
	#print Dumper(\%intervals);
	#debug hash
#	foreach my $tchr (keys %intervals){
#		print "chr $tchr\n";
#		foreach my $tg (keys %{$intervals{$tchr}}) {
#			print "gene $tg\n";
#			print $intervals{$tchr}{$tg}{stop},"\n";
#			print $intervals{$tchr}{$tg}{start}, "\n";
#			my $r = $intervals{$tchr}{$tg}{stop} - $intervals{$tchr}{$tg}{start};
#			print $r,"\n";
#		}
#	}
}

# scan the list of humam markers-peaks
# test if marker is located within a gene of interest
sub scan_markers{
	open(INPUT, "/media/G3data/fdr18/trans/trans_peaks_FDR40.txt") || die "cannot open trans\n";
	while(<INPUT>){
		chomp;
		my ($gene, $marker) = split(/\t/);
		my $mchr = $hummarkerpos_by_index{$marker}{chrom};
		my $mstart = $hummarkerpos_by_index{$marker}{start};
		my $mstop= $hummarkerpos_by_index{$marker}{stop};
		my $mpos= $hummarkerpos_by_index{$marker}{pos};

		#print "$marker\t$mchr\t$mstart\t$mstop\t$mpos\n";
		my $geneofinterest = search_genes_list($mchr, $mstart, $mstop, $mpos) ; 
		if ($geneofinterest) {
			print "$marker\t";
			print "$geneofinterest\t$gene\t";
			my ($symbol, $syns,$ilmn_transid,$ilmn_probeid,$ilmn_acc)=decode_geneid($gene);
			print "$symbol\t$syns\t$ilmn_transid\t$ilmn_probeid\t$ilmn_acc\n";
		}
		
	}
}

# search the hash of genes to see if a marker is contained within gene.
# if it is found w/in a gene, return the gene name
sub search_genes_list{
	my($chr,$start,$stop,$pos) = @_;
	
	#iter over genes on chrom, is marker within gene iterval?
	foreach my $k2 (keys %{$intervals{$chr}}){
		if (($start >= $intervals{$chr}{$k2}{start}) &&
			 ($stop <= $intervals{$chr}{$k2}{stop})){ 

			return $k2;
		}
	}
	return 0; 
}

# convert the gene id to gene symbol
sub decode_geneid{
	my $geneid = shift;
	my $sql = "select b.Symbol,b.synonym, a.index,b.transcript, b.probeID,b.Accession from g3data.ilmn_poshg18 a JOIN 
	 human_rh.ilmn_ref8 b on a.probename = b.target where a.index=?";
	my $dbh=db_connect("g3data");
	my $sth = $dbh->prepare($sql);
	$sth->execute($geneid);
	my($gSym, $gSyn, $gIdx, $gTrans,$gProbe,$gAcc) = $sth->fetchrow_array();
	return ($gSym, $gSyn, $gTrans,$gProbe,$gAcc);	
	
}
############ MAIN #############3
#load_gene_intervals($ARGV[0]);

load_markerpos_by_index("g3data");
find_jakes_genes();
scan_markers();
#search_genes_list(undef,undef, undef,undef);
