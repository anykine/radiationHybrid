#!/usr/bin/perl -w
#
# add position to all.expr.merged.txt file
# which has same genes as TCGA normalized

my %affypos = ();
sub load_affypos{
	open(INPUT, "../index/affyexpr/affypos_common_final.txt") || die "cannot open affy pos";
	while(<INPUT>){
		chomp; next if /^#/;
		my ($index, $chrom, $start, $stop, $sym)  = split(/\t/);
		$affypos{$sym} = {
			chrom=> $chrom,
			start=> $start,
			stop => $stop
		} ;
	}
}


#add position info to file
sub add_pos2file{
	open(INPUT, "all.expr.merged.txt") || die "cannot open merged";
	while(<INPUT>){
		chomp; next if /^#/;
		my @d = split(/\t/);
		if (defined $affypos{$d[0]} ){
			print join("\t", $affypos{$d[0]}->{chrom},
						$affypos{$d[0]}->{start},
						$affypos{$d[0]}->{stop},
						@d
					), "\n";
		}
	}
}
######### MAIN #####################
load_affypos();
add_pos2file();
