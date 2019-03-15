#!/usr/bin/perl -w
#
# This accomplishes several things:
# 1. Finds the closests mouse-human blocks
# 2. Compares the list of genes regulated by a mouse block to the list of genes regulated
#    by an orthologous human block
#
# 3/27/09 - modified match_blocks() to store best pos/res in hash so i can output
#           the translated mouse->human block
#         - added get_match_blocks() for only getting best block lineups
use strict;
use Data::Dumper;
use lib '/home/rwang/lib';
use hummarkerpos ();   #do this to prevent export
use t31markerpos ();   #because of namespace collision
use Math::Round;
use Getopt::Std;

my %options=();
getopts("h", \%options);

#store mouse->hum marker mapping
my %markersM2H=();
my %commongeneM2H=();
my %commongeneH2M=();

# display help
if (defined $options{h}){
	print <<EOH;
	usage $0 <file>

	Find the list of overlapping genes between mouse and human
	0-gene blocks.
	1. use merged blocks
	2. align blocks
	3. for ea group, det. genes regulated
	   det ortholog genes
		 calc % overlap

EOH
exit(1);
}

# constants
use constant INF => 1000000000;

# Take mouse blocks translated in onto human genome and get those human coordinates
# uses the 577 mouse blocks. If necessary, you can cahnge the read_nogeneeqtl_block()
# function to read in a different block
sub output_M2H_translated_blocks{
	my %mouseblock=();
	my %humanblock=();
	my $mblockref = \%mouseblock;
	read_nogeneqtl_block(\%mouseblock, 'm');
	read_nogeneqtl_block(\%humanblock, 'h');
	#my %blocks = match_blocks(\%mouseblock, \%humanblock);

	#for each mouse block
	foreach my $mk (sort {$a<=>$b} keys %$mblockref){
		#print $mblockref->{$mk}{start},"\n";
		my $res = INF;
		my %best = (block=>INF, result=>INF);
		my $bestres = $res;
		my $bestblock = INF;

		#translate mouse->hum	 block, get back start_human_marker and end_human_marker
		my %m2hblock = translM2H_block($mblockref->{$mk}{start}, $mblockref->{$mk}{stop});
		if ( 0 != scalar (keys %m2hblock) )  {
			# get the position of markers = mouse block position on human genome	
			my $m2hchr = $hummarkerpos::hummarkerpos_by_index{ $m2hblock{start} }{chrom};
			my $m2hstart = $hummarkerpos::hummarkerpos_by_index{ $m2hblock{start} }{start};
			my $m2hstop = $hummarkerpos::hummarkerpos_by_index{ $m2hblock{stop} }{stop};
	
			# write out the mouse blocks using human coordinates
			print join("\t", $m2hchr, $m2hstart, $m2hstop),"\n";
		}
	}
}

# output the best mouse-human block lineups (mostly for testing)
sub get_match_blocks{
	my %mouseblock=();
	my %humanblock=();
	read_nogeneqtl_block(\%mouseblock, 'm');
	read_nogeneqtl_block(\%humanblock, 'h');
	# don't forget to uncomment the print statemetn in match_blocks
	my %blocks = match_blocks(\%mouseblock, \%humanblock);
}

# load the data into block, try and match, find overlapping lists
sub blockalign{
	my %mouseblock=();
	my %humanblock=();
	read_nogeneqtl_block(\%mouseblock, 'm');
	read_nogeneqtl_block(\%humanblock, 'h');
	my %blocks = match_blocks(\%mouseblock, \%humanblock);
	my %humreggenes=();
	my %mousereggenes=();
	read_regulated_genes(\%humreggenes, 'h');
	read_regulated_genes(\%mousereggenes, 'm');
	search_overlap(\%blocks, \%mouseblock, \%humanblock,\%mousereggenes,\%humreggenes);
}

# compare lists for signs of overlapping genes
#  takes: aligned blocks; mouse genes in block; hum genes in block;
#           genes regulated by mouse; genes regulated by human
sub search_overlap{
	my($blocksref, $mblockref,$hblockref,$mregref,$hregref) = @_;
	
	#mouse->human block
	#for each mouse-hum block
	foreach my $mk (sort {$a<=>$b} keys %$blocksref){
		print "$mk\t $blocksref->{$mk}\n";
		my $hk = $blocksref->{$mk};

		my %mousereggenes=();
		#get markers in a mouse block
		for (my $i = $mblockref->{$mk}{start}; $i<= $mblockref->{$mk}{stop}; $i++){
			#get genes regulated by markers in block
			foreach my $ii (sort {$a<=>$b} keys %{$mregref->{$i}}){
				# i regulates ii
				# translate mouse->human gene IDs
				$mousereggenes{$commongeneM2H{$ii} } = 1 if defined $commongeneM2H{$ii};
			}
		}

		my $humcounter=0;
		my %humanreggenes=();
		#get genes regulated by human block
		for (my $i=$hblockref->{$hk}{start}; $i<=$hblockref->{$hk}{stop}; $i++){
			foreach my $ii (sort {$a<=>$b} keys %{$hregref->{$i}}) {
				#print "$i -> $ii \n";
				$humanreggenes{$ii} = 1;				
				$humcounter++ if (exists $commongeneH2M{$ii} );
			}
		}
		
		# count only those human genes in the common_gene_list

		#search to see if regulated genes overlap, calculate percentage;
		if (keys %mousereggenes > 0 && keys %humanreggenes > 0){
			my $total1 = (keys %mousereggenes) + (keys %humanreggenes);
			my $total = (keys %mousereggenes) + $humcounter;
			my $counter = 0;
			foreach my $i (keys %humanreggenes){
			#foreach my $i (keys %mousereggenes){
				#if (defined $humanreggenes{$i} ){
				if (defined $mousereggenes{$i} ){
					$counter++;
				}
			}
			print "overlap of block $mk/$hk is $counter out of $total($total1) ",$counter/$total, "\n";
		} else {
			print "hash size is zero\n";
		}
	
	}
}

# simple algorithm to match blocks, take majority vote
sub match_blocks{
	my($mblockref, $hblockref) = @_;
	my %matched_blocks=();
	my $cnt=0;
	#for each mouse block
	foreach my $mk (sort {$a<=>$b} keys %$mblockref){
		#print $mblockref->{$mk}{start},"\n";
		my $res = INF;
		my %best = (block=>INF, result=>INF);
		my $bestres = $res;
		my $bestblock = INF;

		foreach my $hk ( sort {$a<=>$b} keys %$hblockref){ 

			#translate mouse->hum	 block
			my %m2hblock = translM2H_block($mblockref->{$mk}{start}, $mblockref->{$mk}{stop});
			if (keys %m2hblock != 0 ){
				# replace mblock->mk/start/stop with translated (human)block start/stop
				#print "1--$m2hblock{start}\t";
				#print "$m2hblock{stop}\t";
				#print "$hblockref->{$hk}{start}\t";
				#print "$hblockref->{$hk}{stop}\n";
				my $res = block_dist($m2hblock{start},
														$m2hblock{stop},
														$hblockref->{$hk}{start}, 
														$hblockref->{$hk}{stop} )	;
				if ($res  < $best{result})	{
					$best{result}= $res;
					$best{block}= $hk;
				}
			} else {
				next;
			}
		}
		#output best result	
		if ($best{block}!= INF){
			$matched_blocks{$mk} = $best{block};
			#print "$mk\t$bestblock\t$bestres\n";
			print "$mk\t$best{block}\t$best{result}\n";
		}
	}
	#collect best result
	return %matched_blocks;
}

# translate mouse block to human marker domain
# take a simple majority vote
sub translM2H_block{
	my($mstart, $mstop) = @_;
	my %data=();

	# holds the mouse-to-human markers (human equiv markers)
	my %M2Hblock=();
	for (my $i=$mstart; $i <= $mstop; $i++){
		if (exists $markersM2H{$i} ) {
			$M2Hblock{ $markersM2H{$i} } = 1;
		}
	}
	if (keys %M2Hblock ==0) {
		return %data;
	}
	
	# clean the block - this needs work
	# count votes for chrom, pick majority
	# count distribution of marker locations, pick the majority, throw the rest away
	# return the clean mus2hum block (start/stop markers)
	my $prev = 0;
	my %chroms = ();

	# markers are on which chrom?
	foreach my $k (sort keys %M2Hblock){
		my $poschr    = $hummarkerpos::hummarkerpos_by_index{$k}{chrom};
		$chroms{$poschr}++;
	}

	my $maxchr = max_chrom(%chroms);

	my @hmarkers=(); 
	# hum markers are in order, so take first, last
	# assume markers are close to each other
	foreach my $k (sort keys %M2Hblock){
		my $pos       = $hummarkerpos::hummarkerpos_by_index{$k}{start};
		my $poschr    = $hummarkerpos::hummarkerpos_by_index{$k}{chrom};
		if ($poschr == $maxchr){
			push @hmarkers, $k;
		}
	}
		#if ($prev == 0){
		#	$prev = $k;
		#} else {
		#	my $pos       = $hummarkerpos::hummarkerpos_by_index{$k}{start};
		#	my $poschr    = $hummarkerpos::hummarkerpos_by_index{$k}{chrom};
		#  my $prevpos   = $hummarkerpos::hummarkerpos_by_index{$prev}{start};
		#  my $prevposchr = $hummarkerpos::hummarkerpos_by_index{$prev}{chrom};

		#	#if ($poschr != $prevposchr) {
		#	#	delete($M2Hblock{$k});
		#	#	next;
		#	#}
		#	#if (abs($pos-$prevpos) > 500000) {
		#	#	print $k,"\n";
		#	#}

		#}
	
	#return hash of start/stop markers
	$data{start} = $hmarkers[0];
	$data{stop} = $hmarkers[$#hmarkers];
	#$data{mouseblock} = ;	
	return %data;
}


# given a hash of counts for ea chrom, return max
sub max_chrom{
	my %chrom = @_;
	my @sorted = sort {$chrom{$b} <=> $chrom{$a} } keys %chrom;
	#print Dumper(\@sorted);
	return $sorted[0];
}

# calc distance between two marker blocks
# takes mouse2hum start/stop block, human start/stop block
# calc takes place in human domain using mouse-transl block
sub block_dist{
	my ($m2hstart,$m2hstop, $hstart,$hstop) = @_;
	#print "@_","\n";
	#need genepos	
	my $m2hchrom = $hummarkerpos::hummarkerpos_by_index{$m2hstart}{chrom};
	my $hchrom = $hummarkerpos::hummarkerpos_by_index{$hstart}{chrom};

	#check if on same chrom
	if ($m2hchrom == $hchrom){
		#print "$mstart $mchrom\t";
		#print "$hstart $hchrom\n";
		#easy way, take mean of each block
		#print "mus: ";
		my $m2hpos = average($hummarkerpos::hummarkerpos_by_index{$m2hstart}{start},
		             $hummarkerpos::hummarkerpos_by_index{$m2hstop}{stop});
		#print "hum: ";
		my $hpos = average($hummarkerpos::hummarkerpos_by_index{$hstart}{start},
		             $hummarkerpos::hummarkerpos_by_index{$hstop}{stop});

		return abs($m2hpos-$hpos);
	} else {
		return INF;
	}
}

# calc avg
sub average{
	my($a,$b) = @_;
	#print "$a and $b = ", round(($a+$b)/2), "\n";
	return round(($a+$b)/2)	;
}


# this is the Liftover10 mus2hum marker equivalents (closest hum marker
# for mus marker)
# many mus markers map to the same hum markers
sub load_M2H_markers{
	open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/mus2human_closest.txt")
	  || die "cannot open mus2hum markers\n";
	#format: converted_mus_chr/start/stop|musID | hum pos|hum id
	while(<INPUT>){
		chomp;
		my @line = split(/\t/);
		$markersM2H{$line[3]} = $line[5];
	}
}

# store the genes regulated by each marker in HoH
sub read_regulated_genes{
	my ($aref, $species) = @_;
	if ($species eq 'm') {
		open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/0_gene_300k_trans_4.0.txt")
		  || die "cannot open mouse regulated genes\n";
		while(<INPUT>){
			chomp;
			my @data = split(/\t/);
			#create hash of hashes
			$aref->{$data[2]}{$data[1]}=1;
		}
	} elsif ($species eq 'h'){
		open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks_ucschg18.txt")
		  || die "cannot open human regulated genes\n"; 
		while(<INPUT>){
			chomp;
			my @data = split(/\t/);
			$aref->{$data[1]}{$data[0]}=1;
		}
	} else {
		die "no file to open\n";
	}
	close(INPUT);
	#print Dumper($aref);
}

# general utility to read merged_blocks of 0-gene eqtl peaks
# pass in ref to array to fill and species={m, h}
# start=first markerid; stop = last marker in block
sub read_nogeneqtl_block{
	my($aref, $species) = @_;
	if ($species eq 'm'){
		#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k.txt")
		open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/simulation/mouse_zero_gene_cgh_markers_ranges300kb.txt")
	   || die "cannot open mouse block file\n";
	} elsif ($species eq 'h'){
		#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt")
		#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/simulation/zero_gene_cgh_ranges300kb.txt")
		open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/simulation/zero_gene_cgh_ucsc+miRNA_ranges300kb.txt")
	   || die "cannot open human block file\n";
	} else {
		die "no file to open\n";
	}
	my $blockcount=0;
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		# block#1..N contains start_marker and stop_marker
		$aref->{$blockcount}{start} = $data[0];
		$aref->{$blockcount}{stop}  = $data[3];
		$blockcount++;
	}
	close(INPUT);
}

# matchup of mouse to human genes
sub load_common_geneidx{
	open(INPUT, "/media/G3data/fdr18/cis/comp_MH_cis_alphas/common_human_mouse_indexes.txt") || die "cannot open common genes\n";
	<INPUT>;
	while(<INPUT>){
		chomp;
		my @data = split(/\t/);
		$commongeneM2H{$data[1]} = $data[0];
		$commongeneH2M{$data[0]} = $data[1];
	}
	#print Dumper(\%commongeneM2H);
}

# load the hum/mouse marker locations
sub init{
	t31markerpos::load_markerpos_by_index("mouse_rhdb");
	hummarkerpos::load_markerpos_by_index("g3data");

	#exposes 2 hashes 
	#%t31markerpos::t31markerpos_by_index);
	#%hummarkerpos::hummarkerpos_by_index);
}
############ MAIN ####################

init();
load_M2H_markers();
load_common_geneidx();
#blockalign();
#get_match_blocks() ;

# 9/16/2009 find the mouse-to-human block genome locations for side-by-side plot
output_M2H_translated_blocks();
