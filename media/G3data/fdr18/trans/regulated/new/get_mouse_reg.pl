#1/usr/bin/perl -w
#
use strict;
use Data::Dumper;

my %mouse_gene_count=();
my %human_gene_count=();
my %common_genes=();

# count number of markers regulating each mouse genes
sub count_mouse_regulators{
	open(INPUT, "mouse_trans_peaks_3.99.txt") || die ;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
			$mouse_gene_count{$d[0]}++;
	}
	#output_mouse_regulators();
}

sub output_mouse_regulators{
	foreach my $k (sort {$a<=>$b} keys %mouse_gene_count) {
		print "$k\t$mouse_gene_count{$k}\n";
	}
}

# load counts of regulators foreach gene from file
sub count_human_regulators{
	open(INPUT, "../genes_FDR40.txt") || die ;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		$human_gene_count{$d[0]} = $d[2];
	}
}

# load common mouse-human gene index
sub load_common_gene_index{
	open(INPUT, "/media/G3data/fdr18/trans/comp_MH_regulators/common_human_mouse_indexes.txt") || die;
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		$common_genes{ $d[0] } = $d[1];
	}
	#print scalar (keys %common_genes),"\n";
}

# find the orth genes and print out
sub construct_correlation{
	
	print "#hum\thumcount\tmouse\tmousecount\n";
	#iter over common genes (human - mouse)
	while( my ($h, $m) = each (%common_genes)){
		if (defined $human_gene_count{$h} && defined $mouse_gene_count{$m}){
			print "$h\t$human_gene_count{$h}\t";
			print "$m\t$mouse_gene_count{$m}\n";
		}
	}
}
########### MAIN #####################
count_mouse_regulators();
count_human_regulators();
#print Dumper(\%human_gene_count);exit(1);
load_common_gene_index();
construct_correlation();
