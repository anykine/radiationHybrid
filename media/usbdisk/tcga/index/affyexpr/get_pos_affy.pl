#!/usr/bin/perl -w
#
# get probe pos info and make table for AFFY, hg18 ncbi 36.1

use strict;
use Data::Dumper;

sub reformat_affy{
	open(INPUT, "affypos.txt") ||die "err";
	<INPUT>;
	while(<INPUT>){
		chomp;
		my($probe, $sym, undef, undef, $chr, $start, $stop) = split(/\t/);
		next if $chr !~/^chr/;
		next if $chr =~/random/;
		next if $chr =~/_/;
		$chr =~ s/^chr//;
		$chr = 23 if $chr=~/X/;
		$chr = 24 if $chr=~/Y/;
		next if $chr eq 'M';
		print join("\t", $chr, $start, $stop, $probe, $sym),"\n";
	}
}

sub unique_pos_probe{
	open(INPUT, "affypos_final.txt") || die "error unique pos";
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

sub unique_pos_symbol{
	open(INPUT, "affypos_final.txt") || die "error unique pos";
	my %probe= ();
	while(<INPUT>){
		chomp;
		my ($chr, $start, $stop, $probe, $sym) = split(/\t/);
		if (defined $probe{$sym}){
			$probe{$sym}{start} = $start if ($start < $probe{$sym}{start});
			$probe{$sym}{stop} = $stop if ($stop > $probe{$sym}{stop});
		} else {
			$probe{$sym} = {chrom=>$chr, start=>$start, stop=>$stop, sym=>$sym};
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
#unique_pos_probe();
unique_pos_symbol();
