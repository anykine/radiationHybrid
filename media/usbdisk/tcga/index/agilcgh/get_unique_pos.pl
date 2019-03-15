
#!/usr/bin/perl -w
#
# get probe pos info and make table for AFFY, hg18 ncbi 36.1

use strict;
use Data::Dumper;

my %probe=();

sub unique_pos_probe{
	open(INPUT, "cgh_pos.txt") || die "error unique pos";
	my %probe= ();
	while(<INPUT>){
		chomp;
		my ($chr, $start, $stop, $probe, $sym) = split(/\t/);
		if (defined $probe{$probe}){
			$probe{$probe}{start} = $start if ($start < $probe{$probe}{start});
			$probe{$probe}{stop} = $stop if ($stop > $probe{$probe}{stop});
		} else {
			$probe{$probe} = {chrom=>$chr, start=>$start, stop=>$stop, sym=>$sym};
		}
	}
	#print Dumper(\%probe);
	#output the hash
	foreach my $k (keys %probe){
		print join("\t", 
			$probe{$k}{chrom},
			$probe{$k}{start},
			$probe{$k}{stop},
			$probe{$k}{sym},
			$k),"\n";
	}
}


######### MAIN #####################
unique_pos_probe();
