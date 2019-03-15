#!/usr/bin/perl -w
#
# Homebrew version of liftover. Maps mouse zero gene blocks
# to human coordinates.
#
# Liftover does not work well for noncoding regions, so the solution is to use
# lifted markers(imputed or not) to determine the corresponding human region
# of mouse blocks.
# 
use strict;
use Data::Dumper;

my %mus2hum=();
sub load_mus2human_markers{
	my $imputeflag = shift;
	if (defined $imputeflag && $imputeflag == 1){
		print STDERR "Using imputed markers ...\n";
		open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/mus2human_markers_imputed.bed") || die "cannot open imputed markers";
	} else{
		print STDERR "Using nonimputed markers ...\n";
		open(INPUT, "/media/G3data/mm7tohg18/markers/liftover10/mus2human_noimpute_closest.txt") || die "cannot open nonimputed markers";
	}
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		$d[0] =~ s/chr//;
		$mus2hum{$d[3]}{chrom}= $d[0] ;
		$mus2hum{$d[3]}{chrom}=23 if $d[0] eq 'X';
		$mus2hum{$d[3]}{chrom}=24 if $d[0] eq 'Y';
		$mus2hum{$d[3]}{start}= $d[1];
		$mus2hum{$d[3]}{stop}= $d[2];
	}
}

# mouse block file format:
# mstart|mstartchrom|startpos| mend|mendchrom|endpos
sub parse_mouse_block_file{
	my $file = shift;
	open(INPUT, $file) || die "cannot open file\n";
	# the largest zero gene block allowable is 5mb
	# to avoid a zero gene block taking up 100mb. Without this there are 10
	# regions > 1mb and 4 >5mb.
	my $limit = 5000000;
	my $blocknum = 0;
	while(<INPUT>){
		next if /^#/;chomp;
		my ($m1,$m1chrom,$m1pos,$m2,$m2chrom,$m2pos) = split(/\t/);
		$blocknum++;
		#print join("\t", $m1,$m1chrom,$m1pos,$m2,$m2chrom,$m2pos),"\n"; 

		my $chrom=0;
		my %liftedblock=();
		# is start marker in map?
		if ( defined $mus2hum{$m1} ) {
			
			$chrom = $mus2hum{$m1}{chrom};
			$liftedblock{chrom} = $mus2hum{$m1}{chrom};
			$liftedblock{start} = $mus2hum{$m1}{start};

			# is the end marker in map?
			if (defined $mus2hum{$m2} && abs($mus2hum{$m2}{start}-$mus2hum{$m1}{start})<$limit){
				# if startmarker=endmarker, add 60bp
				if ($m2==$m1){
					$liftedblock{stop} = $mus2hum{$m2}{stop}+60;
				} else {
					$liftedblock{stop} = $mus2hum{$m2}{stop};
				}
			} else {
				# end marker not in list, try searching for it
				for (my $i=$m2; $i>$m1; $i--){
					if (defined $mus2hum{$i} && $mus2hum{$i}{chrom}==$chrom && abs($mus2hum{$i}{start}-$mus2hum{$m1}{start})<$limit){
						$liftedblock{stop} = $mus2hum{$i}{stop};
						#print "\t$m2 substituted with $i\n";
						last;
					}
				}
			}

		# output the mouse block in human coordinates
		# chrom | start | stop | mouse_blocknum
		print join("\t",$liftedblock{chrom}, $liftedblock{start}, $liftedblock{stop},$blocknum),"\n" if (defined $liftedblock{stop});

		} else {
			print STDERR "m1 NOT FOUND: ", join("\t", $m1,$m2),"\n";
		}
	}
}
######### MAIN #####################
unless (@ARGV==1){
	print "usage $0 <mouse zero gene ranges file>\n";
	exit(1);
}
my $impute=1;
load_mus2human_markers($impute);
#print Dumper(\%mus2hum);
#parse_mouse_block_file("mouse_zero_gene_peaks2_ranges300k_FDR30.txt");
parse_mouse_block_file($ARGV[0]);
