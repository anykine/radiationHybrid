#!/usr/bin/perl -w
#
# Add some information to zero gene peaks ranges files (blocks)
# 1. Take the ranges(blocks) file and average the pvalues over the
# markers in the block.
use strict;
use Data::Average;
use Data::Dumper;

# Load in pvals into specified hash
# pass in [mouse|human], hash ref
sub load_pvals{
	my ($species, $href) = @_;
	# file formats
	my %muscols = (
		gene=>1, marker=>2,
		alpha=>3, nlp=>4
	);
	my %humcols = (
		gene=>0, marker=>1,
		alpha=>2, nlp=>3
	);
	if ($species eq 'mouse') {
		open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/0_gene_300k_trans_4.0.txt")||die "cannot open peaks file";
		while(<INPUT>){
			next if /^#/;
			chomp;
			my @data = split(/\t/);
			if (defined $href->{$data[$muscols{marker}]} ) {
				$href->{$data[$muscols{marker}]} = $data[$muscols{nlp}] if $data[$muscols{nlp}] > $href->{$data[$muscols{marker}]};
			} else {
				$href->{$data[$muscols{marker}]} = $data[$muscols{nlp}];
			}
		}
	} elsif ($species eq 'human') {
		open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/peaks3/zero_gene_peaks3_ucschg18_FDR40.txt")||die "cannot open peaks file";
		#open(INPUT, "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/zero_gene_peaks_ucschg18.txt")||die "cannot open peaks file";
		while(<INPUT>){
			next if /^#/;
			chomp;
			my @data = split(/\t/);
			if (defined $href->{$data[$humcols{marker}]} ) {
				$href->{$data[$humcols{marker}]} = $data[$humcols{nlp}] if $data[$humcols{nlp}] > $href->{$data[$humcols{marker}]};
			} else {
				$href->{$data[$humcols{marker}]} = $data[$humcols{nlp}];
			}
		}
	} else {
		die "species not specified";
	}	
	#while(<INPUT>){
	#	next if /^#/;
	#	chomp;
	#	my @data = split(/\t/);
	#	if (defined $href->{$data[2]} ) {
	#		$href->{$data[2]} = $data[4] if $data[4] > $href->{$data[2]};
	#	} else {
	#		$href->{$data[2]} = $data[4];
	#	}
	#}
	close(INPUT)
}

# calc the pvals for a block
sub avg_pval_ranges{
	my ($start,$end,$pvalref) = @_;
	my $DEBUG = 0;
	my $counter=0;
	my @collect = ();
	my @nocollect = ();

	print "----\n" if $DEBUG;

	my $data = Data::Average->new;
	for(my $i=$start; $i <= $end; $i++){
		if (defined $pvalref->{$i}){
			push @collect, $i;
			$data->add( $pvalref->{$i} ); 
			#print $pvalref->{$i},"\t"; 
		}else {
			push @nocollect, $i;
			#print "$i is not defined\n";
		}
	}
	if ($DEBUG==1){
		print "\n";
		print "collected = [", join("\t", @collect), "]\n";
		print "collected = ", scalar @collect , "\n";
		print "nocollected = [", join("\t", @nocollect), "]\n";
		print "nocollected = ", scalar @nocollect , "\n"; 
		print "----\n";
	}
	return $data->avg;
}

# Read in file with structure specified and calculate pvals
sub add_avg_pvals{
	my ($file, $cols, $pvalref) = @_;
	open(INPUT, $file) || die "can't open $file";
	while(<INPUT>){
		next if /^#/;
		chomp;
		my @d = split(/\t/);
		my ($start,$end) = ($d[$cols->{block_startmarker}], $d[$cols->{block_endmarker}]);
		my $res = avg_pval_ranges($start,$end,$pvalref);
		print join("\t", @d,$res),"\n";
	}
}


# this does all the work
sub add_col_mouse{
	my %cols=(	
		block_startmarker=>0,
		block_startmarkerchr=>1,
		block_startmarkerstartpos=>2,
		block_endmarker=>3,
		block_endmarkerchr=>4,
		block_endmarkerstartpos=>5,
		block_size=>6
	);
	
	my %pvals=();
	load_pvals('mouse', \%pvals);
	
	my $musfile = "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k_size.txt";
	#my $humfile = "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt";
	add_avg_pvals($musfile, \%cols, \%pvals);
}

sub add_col_human{
	# describe column format
	my %colsize=(	
		block_startmarker=>0,
		block_startmarkerchr=>1,
		block_startmarkerstartpos=>2,
		block_endmarker=>3,
		block_endmarkerchr=>4,
		block_endmarkerstartpos=>5,
		block_size=>6
	);
	my %cols=(	
		block_startmarker=>0,
		block_startmarkerchr=>1,
		block_startmarkerstartpos=>2,
		block_endmarker=>3,
		block_endmarkerchr=>4,
		block_endmarkerstartpos=>5,
		block_size=>6
	);
	
	my %pvals=();
	load_pvals('human', \%pvals);

	#my $musfile = "/media/G3data/fdr18/trans/zero_gene_peaks/mouse/unique/zero_gene_peaks_ranges300k.txt";
	#my $humfile = "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k.txt";
	#my $humfile = "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/zero_gene_peaks_ranges300k_size.txt";
	my $humfile = "/media/G3data/fdr18/trans/zero_gene_peaks/NEW/unique/peaks3/zero_gene_peaks3_ranges300k_size.txt";
	add_avg_pvals($humfile, \%colsize, \%pvals);
}

############# MAIN ########
add_col_human();
#add_col_mouse();
