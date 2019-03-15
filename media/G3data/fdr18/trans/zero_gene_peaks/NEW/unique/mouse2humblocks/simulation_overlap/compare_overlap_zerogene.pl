#!/usr/bin/perl -w
#
# Brute force search for overlapping intervals such as 
# betweeen Lander lincRNAs and my human zero gene intervals
# or between Wolds ncRNAs and my zero genes

# a slick implemntation would use red-black trees but for the 
# small number of segments (i hope) brute force is fine.
#
# To count number of unique blocks, do cut -f2 <output> |sort -n|uniq | wc -l.
# To count number of unique lincRNA/etc, do cut -f4 <output> ...
#
# Reference organism is mouse or human zero gene blocks
#    %hash={ 
#    			 0=>{ chrom=>1 , start=>100 , stop=>200},
#          1=>{ chrom=>1, start=>150000, stop=>200000}
#          100=>{ chrom=>9 , start=>100 , stop=>200}
#          }
#
# Comp organism is external dataset lincRNA, Wold next gen sequencing
# 	%hash={
#				1={start=array(1, 24, 100...),
#				   stop = array(10, 35, 150..),
#					},
#				23={start=array(),
#					 stop = array(),
#					}
# 	}

use strict;
use Data::Dumper;
use Carp;
use Getopt::Long;

# sort intervals on start, s1 is the smaller
sub overlap{
	my($s1low, $s1high, $s2low, $s2high) = @_;
	#an overlap must satisfy this constraint
	if ($s1low <= $s2high && $s2low <= $s1high){
		return 1;
	} else {
		return 0;
	}
}

# GENERIC function to load (mouse/human data) block data
# pass in hash to fill, name of file, hash descript of file struct 
sub load_ref_blocks{
	my ($aref, $file, $filestruct) = @_;
	#open(INPUT, $file) || die "cannot open block file $file";
	open(INPUT, $file) || croak "cannot open block file $file";
	my $counter=0;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		$aref->{$counter}{chrom} = $d[$filestruct->{startchrom}];
		$aref->{$counter}{start} = $d[$filestruct->{startpos}];
		$aref->{$counter}{stop} = $d[$filestruct->{endpos}];
		$aref->{$counter}{blocknum} = $d[$filestruct->{blocknum}] if defined $filestruct->{blocknum};
		$counter++;
	}
}


# GENERIC LOAD DATA ROUTINE.
# data format MUST BE  chrom(noX,noY) | start | stop 
# for the first 3 columns
sub load_comp_data{
	my ($aref, $file)=@_;
	#open(INPUT, $file) || die "cannot open file";
	open(INPUT, $file) || croak "cannot open file";
	my $counter=0;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		push @{$aref->{$d[0]}{start}}, $d[1];
		push @{$aref->{$d[0]}{stop}}, $d[2];
		push @{$aref->{$d[0]}{index}}, $counter++;
		#if (scalar @d == 4){
		if (defined $d[3]){
			push @{$aref->{$d[0]}{blocknum}}, $d[3];
		}
	}
	close(INPUT);
}

# specify the columns to load
sub load_comp_data2{
	my ($aref, $file, $filestruct)=@_;
	#open(INPUT, $file) || die "cannot open file";
	open(INPUT, $file) || croak "cannot open file";
	my $counter=0;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		push @{$aref->{$d[$filestruct->{startchrom}]}{start}}, $d[ $filestruct->{startpos}];
		push @{$aref->{$d[$filestruct->{startchrom}]}{stop}}, $d[$filestruct->{endpos}];
		push @{$aref->{$d[$filestruct->{startchrom}]}{index}}, $counter++;
		#if (scalar @d == 4){
		if (defined $filestruct->{blocknum} && defined $d[$filestruct->{blocknum}]){
			push @{$aref->{$d[$filestruct->{startchrom}]}{blocknum}}, $d[$filestruct->{blocknum}];
		}
	}
	close(INPUT);
}
#delete a specific block
#input chrom and index, aref
sub delete_comp_data{
	my ($chrom, $index, $aref)=@_;
	if (defined $aref->{$chrom}){
		#splice @{$aref->{$chrom}{start}}, $index, 1;
		#splice @{$aref->{$chrom}{stop}}, $index, 1;
		#splice @{$aref->{$chrom}{index}}, $index, 1;
		$aref->{$chrom}{start}[$index] = undef
		$aref->{$chrom}{stop}[$index] = undef
		$aref->{$chrom}{index}[$index] = undef
	} else {
		die "chrom not defined\n";
	}
}
#find closest
#based on start positions
#sub matchup{
#	my $aref= shift;
#	my $j;
#
#	#for each mouse block
#	foreach my $i (sort {$a<=>$b} keys %musblocks){
#		my %best=(dist=>100000000,index=>undef );
#
#		my $chr = $musblocks{$i}{chrom};
#		my $start = $musblocks{$i}{start};
#		my $stop = $musblocks{$i}{stop};
#
#		#search over all RNAFAR 
#		foreach my $j ($aref->{$chr}{start}){
#			for (my $i=0; $i< scalar @$j; $i++){
#				my $sdist = abs($j->[$i] - $start);
#				if ($sdist < $best{dist}){
#					$best{dist} = $sdist;
#					$best{index} = $i;
#				}
#			}
#		}
#		#mouse stuff
#		print join("\t", $chr, $start, $stop), "\t";
#		#rnafar stuff
#		print join("\t", $aref->{$chr}{start}[$best{index}], 
#											$aref->{$chr}{stop}[$best{index}]
#								), "\t";
#		print $best{dist},"\n";
#	}
#}

# GENERIC COMPARISON FUNCTION
# find interval overlap between reference (mouse zero gene, human zero gene)
# and comparison (wold, lincRNA)
# $ref = reference genome (mus mm7, hum)
# $comp = dataset to compare to (wold, lincRNA)
# 9/15/2009 - modification, adding 300kb to start/stop of zero gene blocks
# 9/17/2009 - made an parameter for the adding 300kb to start/stop
sub overlap_ref_comp{
	my ($ref, $comp, $flag300) = @_;
	#iter over reference (mouse/human zero) blocks 
	foreach my $i (sort {$a<=>$b} keys %$ref){
		my $chr = $ref->{$i}{chrom};
		my ($start,$stop,$blocknum);
		if (defined $flag300 && $flag300==1){
			$start = ($ref->{$i}{start}-300000 < 0) ? 0 : $ref->{$i}{start}-300000;
			$stop = $ref->{$i}{stop}+300000;
		} else {
			$start = $ref->{$i}{start};
			$stop = $ref->{$i}{stop};
			$blocknum = $ref->{$i}{blocknum};
		}

		my $res = 999;
		#search over all comparison data (RNAFAR/lincRNA) on this chrom
		next if (!defined $comp->{$chr});
		for (my $j=0; $j < scalar @{$comp->{$chr}{start}}; $j++){

			#pass in intervals sorted on start key to overlap()
			if ($comp->{$chr}{start}[$j] < $start) {
				$res = overlap($comp->{$chr}{start}[$j],
								$comp->{$chr}{stop}[$j],
								$start,
								$stop);
			} else {
				$res = overlap($start,
								$stop,
								$comp->{$chr}{start}[$j],
								$comp->{$chr}{stop}[$j]);
			}
			if ($res){
				# print reference data
				print join("\t", $chr, $start,$stop );
				if (defined $blocknum) {
					print "\t$blocknum\t";
				} else {
					print "\t";
				}
				#print join("\t", $chr, $start,$stop, $blocknum),"\t";
				# print comparison data
				print join("\t", $comp->{$chr}{start}[$j],
													$comp->{$chr}{stop}[$j],
													$comp->{$chr}{blocknum}[$j]
									),"\n";
				#if (defined $comp->{$chr}{blocknum}[$j]){
				#	print "\t", $comp->{$chr}{blocknum}[$j],"\n";
				#} else {
				#	print "\n";
				#}
			}
			$res = 999;
		}
	}
}

# iterates over one file and marks each line that has an overlap
# with another file
sub label_overlap_ref_comp{
	my ($ref, $comp, $flag300) = @_;
	#iter over reference (mouse/human zero) blocks 
	foreach my $i (sort {$a<=>$b} keys %$ref){
		
		my $chr = $ref->{$i}{chrom};
		
		my ($start,$stop,$blocknum);
		if (defined $flag300 && $flag300==1){
			$start = ($ref->{$i}{start}-300000 < 0) ? 0 : $ref->{$i}{start}-300000;
			$stop = $ref->{$i}{stop}+300000;
		} else {
			$start = $ref->{$i}{start};
			$stop = $ref->{$i}{stop};
			$blocknum = $ref->{$i}{blocknum};
		}

		my $res = 999;
		my $flagoverlap = 0;
		#search over all comparison data (RNAFAR/lincRNA) on this chrom
		if (!defined $comp->{$chr}){
			# this handles one weird case where ref is on chrom but no comp is on that chrom
			goto SKIP;
		}
		for (my $j=0; $j < scalar @{$comp->{$chr}{start}}; $j++){

			#pass in intervals sorted on start key to overlap()
			if ($comp->{$chr}{start}[$j] < $start) {
				$res = overlap($comp->{$chr}{start}[$j],
								$comp->{$chr}{stop}[$j],
								$start,
								$stop);
			} else {
				$res = overlap($start,
								$stop,
								$comp->{$chr}{start}[$j],
								$comp->{$chr}{stop}[$j]);
			}
			if ($res){
				# print the reference position and mark it as overlap
				$flagoverlap = 1;
				last;
			} 
		}#comp ref
		SKIP:
		if ($flagoverlap){
			# print the reference position and mark it as overlap
			print join("\t", $chr, $start,$stop,"o"),"\n";
		}  else {
			print join("\t", $chr, $start,$stop,"n"),"\n";
		}
		$res = 999;
	}# ref iter
}

# are mouse 0-gene blocks overlapping
# with human zero gene blocks  at FDR30
sub run_comp_mus_hum_zerogene{
	my ($reffile, $compfile) = @_;
	my %comp=();
	load_comp_data(\%comp, " mouse_577_to_human_blocks_merged.txt");
	#print Dumper(\%comp); exit(1);
	my %ref = ();
	#my %filestruct=( startmarker=>1,startchrom=>2,startpos=>3,endmarker=>4,endchrom=>5,endpos=>6);
	my %filestruct=(blocknum=>0, startmarker=>1,startchrom=>2,startpos=>3,endmarker=>4,endchrom=>5,endpos=>6);
	load_ref_blocks(\%ref,
	             "human_523_blocks.txt",
							 \%filestruct);
	#print Dumper(\%ref); exit(1);
	overlap_ref_comp(\%ref, \%comp);
}


# human zero gene blocks that overlap a mouse one are labelled
sub run_comp_mus_hum_zerogene_fdr30h{
	my ($reffile, $compfile) = @_;
	my %comp=();
	load_comp_data(\%comp, 
		"/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/mouse2humblocks/fdr30/m2h_fdr30_ordered_sorted_merged.txt");
	#print Dumper(\%comp); exit(1);
	my %ref = ();
	#my %filestruct=( startmarker=>1,startchrom=>2,startpos=>3,endmarker=>4,endchrom=>5,endpos=>6);
	my %filestruct=(startmarker=>0,startchrom=>1,startpos=>2,endmarker=>3,endchrom=>4,endpos=>5);
	load_ref_blocks(\%ref,
							 "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_FDR30_ranges300k.txt",
	             #"human_523_blocks.txt",
							 \%filestruct);
	#print Dumper(\%ref); exit(1);
	label_overlap_ref_comp(\%ref, \%comp);
}

# mouse zero gene blocks that overlap a human one are labelled
sub run_comp_mus_hum_zerogene_fdr30m{
	my ($reffile, $compfile) = @_;
	my %comp=();
	load_comp_data2(\%comp, 
		"/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_FDR30_ranges300k.txt",
		{startchrom=>1, startpos=>2, endpos=>5}
		);
	#print Dumper(\%comp); exit(1);
	my %ref = ();
	#my %filestruct=( startmarker=>1,startchrom=>2,startpos=>3,endmarker=>4,endchrom=>5,endpos=>6);
	my %filestruct=(startchrom=>0,startpos=>1,endpos=>2, blocknum=>3);
	load_ref_blocks(\%ref,
							"/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/mouse2humblocks/fdr30/m2h_fdr30_ordered_sorted_merged.txt",
							 \%filestruct);
	#print Dumper(\%ref); exit(1);
	label_overlap_ref_comp(\%ref, \%comp);
}

sub output_comp{
	my ($chrom, $index, $comp) = @_;
	print $comp->{$chrom}{start}[$index],"\t";
	print $comp->{$chrom}{stop}[$index],"\t";
	print $comp->{$chrom}{index}[$index],"\n";
}

# we're comparing a set of zero gene regions
# against itself to see if some overlap. if they do, merge them
# assume the input is sorted on first position
sub merge_overlap{
	my ($comp, $flag300) = @_;
	#iter over reference (mouse/human zero) blocks using REF structure
	# iter over each chrom
	foreach my $chrom (sort {$a<=>$b} keys %$comp){
		#print "chrom=$chrom\n";
		# iter over each element of array 
		for (my $j=0; $j < scalar @{$comp->{$chrom}{start}}; $j++){
			# because we set element to undef if merged
			next if (!defined $comp->{$chrom}{start}[$j]);
			#print "------------j = $j\n";
			my $start = $comp->{$chrom}{start}[$j];
			my $stop = $comp->{$chrom}{stop}[$j];
			my $blocknum = $comp->{$chrom}{blocknum}[$j];
			# edge case, last in list
			print join("\t", $chrom, $start, $stop, $blocknum),"\n" if $j == (scalar @{$comp->{$chrom}{start}}-1);
			#print "big loop testing ";
			#output_comp($chrom, $j, $comp);
			# iter over every element of array starting at +1
			my $res = 0;
			for (my $k=$j+1; $k < scalar @{$comp->{$chrom}{start}}; $k++){
				# because we set element to undef if merged
				#next if (!defined $comp->{$chrom}{start}[$k]);
				#print "----small loop\n";
				#print "k=$k\n";	
				#print "subtesting ";
				#output_comp($chrom, $k, $comp);
			#pass in intervals sorted on start key to overlap()
				if ($comp->{$chrom}{start}[$k] < $start) {
					$res = overlap($comp->{$chrom}{start}[$k],
									$comp->{$chrom}{stop}[$k],
									$start,
									$stop);
				} else {
					$res = overlap($start,
									$stop,
									$comp->{$chrom}{start}[$k],
									$comp->{$chrom}{stop}[$k]);
				}
				#print "overlap=$res\n";
				# if something overlaps with a block, extend it.
				# and remove the overlapping block
				if ($res==1){
					#print "merge!\n";
					$start = $comp->{$chrom}{start}[$k] if ($comp->{$chrom}{start}[$k] < $start);
					$stop= $comp->{$chrom}{stop}[$k] if ($comp->{$chrom}{stop}[$k] > $stop);
					# add the blocknum to list
					$blocknum = "$blocknum, $comp->{$chrom}{blocknum}[$k]";
					#print "newstart $start\n";
					#print "newstop $stop\n";
					#delete overlapping block
					delete_comp_data($chrom, $k,$comp); 
					#print Dumper($comp);
				} else {
					print join("\t", $chrom, $start, $stop, $blocknum),"\n" ;
					last;
				}
			}#for
			#print join("\t", $chrom, $start, $stop),"\n" ;
			$res=0;
		}#for
	}
}

sub merge_overlap_old{
	my ($ref, $comp, $flag300) = @_;
	#iter over reference (mouse/human zero) blocks 
	foreach my $i (sort {$a<=>$b} keys %$ref){
		my $chr = $ref->{$i}{chrom};
		my ($start,$stop);
		if (defined $flag300 && $flag300==1){
			$start = ($ref->{$i}{start}-300000 < 0) ? 0 : $ref->{$i}{start}-300000;
			$stop = $ref->{$i}{stop}+300000;
		} else {
			$start = $ref->{$i}{start};
			$stop = $ref->{$i}{stop};
		}

		my $res = 999;
		#search over all comparison data (RNAFAR/lincRNA) on this chrom
		next if (!defined $comp->{$chr});
		for (my $j=0; $j < scalar @{$comp->{$chr}{start}}; $j++){

			if ($start==$comp->{$chr}{start}[$j] && $stop ==$comp->{$chr}{stop}[$j]){
				print join("\t",$chr, $start, $stop),"\n";
				last;
			}
			#pass in intervals sorted on start key to overlap()
			if ($comp->{$chr}{start}[$j] < $start) {
				$res = overlap($comp->{$chr}{start}[$j],
								$comp->{$chr}{stop}[$j],
								$start,
								$stop);
			} else {
				$res = overlap($start,
								$stop,
								$comp->{$chr}{start}[$j],
								$comp->{$chr}{stop}[$j]);
			}
			# if something overlaps with a block, extend it.
			# and remove the overlapping block
			if ($res==1){
				$start = $comp->{$chr}{start}[$j] if ($comp->{$chr}{start}[$j] < $start);
				$stop= $comp->{$chr}{stop}[$j] if ($comp->{$chr}{stop}[$j] < $stop);
				#delete overlapping block
				delete_comp_data($chr, $j,$comp); 
			}
		
		}
		print join("\t", $chr, $start, $stop),"\n" if $res==1;
		$res=999;
	}
}

# do any zero gene regions overlap in the file?
# ie compare file against itself and search for overlaps
sub self{
	my $file = shift;
	my %comp=();
	#load_comp_data(\%comp, "mus2hum_zerogene_blocks_fdr30_ordered_sorted.txt");
	#load_comp_data(\%comp, "mus2hum_zerogene_blocks_fdr30_ordered_sorted.lim5mb.txt");
	#load_comp_data(\%comp, "mouse_577_to_human_blocks_format.txt");
	load_comp_data(\%comp, $file);
	#load_comp_data(\%comp, "merged");
	#load_comp_data(\%comp, "mus2hum_zerogene_blocks_fdr30_ordered.txt");
	my %ref = ();
	my %filestruct=( startchrom=>0,startpos=>1,endpos=>2);
	load_ref_blocks(\%ref,
								$file,
								#"mouse_577_to_human_blocks_format.txt",
								#"mus2hum_zerogene_blocks_fdr30_ordered_sorted.lim5mb.txt",
								#"mus2hum_zerogene_blocks_fdr30_ordered_sorted.txt",
								#"mus2hum_zerogene_blocks_fdr30_ordered.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

# merge the overlapping segments
sub self_merge{
	my $file = shift;
	my %comp=();
	#load_comp_data(\%comp, "mus2hum_zerogene_blocks_fdr30_ordered_sorted.txt");
	#load_comp_data(\%comp, "mus2hum_zerogene_blocks_fdr30_ordered_sorted.lim5mb.txt");
	#load_comp_data(\%comp, "mus2hum_zerogene_blocks_fdr30_ordered_sorted.lim5mb.txt");
	#load_comp_data(\%comp, "mouse_577_to_human_blocks.txt");
	#load_comp_data(\%comp, "mouse_577_to_human_blocks_format.txt");
	#load_comp_data(\%comp, "mouse_577_to_human_blocks_format_sorted.txt");
	load_comp_data(\%comp, $file);
	#delete_comp_data(1,8,\%comp);
	#print Dumper(\%comp);
	merge_overlap(\%comp);
}

sub self_human{
	my %comp=();
	my $aref = \%comp;
	open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_FDR30_ranges300k.txt") || croak "cannot open file";
	my $counter=0;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		push @{$aref->{$d[1]}{start}}, $d[2];
		push @{$aref->{$d[1]}{stop}}, $d[5];
		push @{$aref->{$d[1]}{index}}, $counter++;
	}
	close(INPUT);

	my %ref = ();
	my %filestruct=( startchrom=>0,startpos=>1,endpos=>2);
	load_ref_blocks(\%ref,
	             "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_FDR30_ranges300k.txt",
							 \%filestruct);
	overlap_ref_comp(\%ref, \%comp);
}

sub usage{
	print <<EOH;
	usage: $0
		--self <file>: check if file overlaps with self
		--selfmerge <file>: merge overlapping regions 
		--compare <ref file> --compare <comp file>: compare comp_file against ref_file
		--run30: run the fdr30
EOH
}
####### MAIN #############
my %options=();
my @a = ();
unless (@ARGV > 1){
	usage();
	exit(1);
}
GetOptions('self=s' => \$options{self_file},
					'selfmerge=s' => \$options{selfmerge_file},
					'compare=s' => \@{$options{compare_files}},
					'run30h:s' => \$options{run30h},
					'run30m:s' => \$options{run30m}
					);

if (defined $options{self_file} ){
	## compare file against itself
	self( $options{self_file});
} elsif (defined $options{selfmerge_file} ){
	## merge overlapping entries in file
	self_merge( $options{selfmerge_file} );
} elsif (defined $options{run30h}){
	run_comp_mus_hum_zerogene_fdr30h();
} elsif (defined $options{run30m}){
	run_comp_mus_hum_zerogene_fdr30m();
}

## compare human 0-gene blocks versus mouse 0-gene blocks overlap 
#run_comp_mus_hum_zerogene();
