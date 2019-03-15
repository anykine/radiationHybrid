#!/usr/bin/perl -w
#
# extract the relevant columns from human peaks and mouse peaks
# based on gene index file
# 9/9/10 - modified to produce HM regulator count file at FDR30 (human)



my %mouse = ();
my %human = ();

sub load_human{
	# find the max #regulators for each gene
	open(HUMAN, "/media/G3data/fdr18/trans/regulators/new/nearest_gene_to_markerFDR30.txt") || die "cannot open human\n";
	while(<HUMAN>){
		chomp;
		my @line = split(/\t/);
		if (defined $human{$line[1]} && $human{$line[1]}{regulators} < $line[3]){
			$human{$line[1]} = {
					regulators=>$line[3],
					sym => $line[2]
				};
		} else {
			$human{$line[1]} = {
					regulators=>$line[3],
					sym => $line[2]
				};
		}
	}
	close(HUMAN);
}

sub load_mouse{
	open(MOUSE, "mouse/mouse_regulator_counts.txt") || die "cannot open mouse\n";
	while(<MOUSE>){
		chomp;
		my @line = split(/\t/);
			$mouse{$line[0]} = $line[1];
	}
	close(MOUSE);
}

sub output{
	open(INDEX, "common_human_mouse_indexes.txt") || die "cannot read indexes\n";
	while(<INDEX>){
		chomp;
		my ($hidx, $midx) = split(/\t/);
		if (defined $human{$hidx} ) {
			if (defined $mouse{$midx}) {
				print join("\t",
					$hidx,
					$human{$hidx}{regulators},
					$human{$hidx}{sym},
					$midx,
					$mouse{$midx}
					),"\n";
			}
		}
	}
}


####### MAIN ########
load_human();
load_mouse();
output();
