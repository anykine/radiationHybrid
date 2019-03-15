#!/usr/bin/perl -w
use Data::Dumper;

$t="\t";
$n="\n";

%id_to_ll=();
%id_to_probe=();
$file="gnf1m_annot.txt";
$id=1;
open(HANDLE, $file);
while (<HANDLE> ){
	chomp $_;
	($p,$n,$gb,$nm, $name, $ll) = split ("\t" , $_);
	
	unless ($ll eq "" ) {
		$id_to_ll{$id}=$ll;
		$id_to_probe{$id}=$p;
	}
	$id++;
}
close (HANDLE);


%gene_hash=();
$file1="sym_atlas_unlogged.txt";
$id=0;

open(HANDLE, $file1);
while(<HANDLE>) {
	chomp $_;
	$id++;
	@line = split ("\t" , $_);
	
	#($Probeset, $RefSeq, $UniGene, $RIKEN, $Gene, $Symbol, $Name, $Extra, $Adorsalstriatum_Signal, $Adorsalstriatum_Detection, $Bdorsalstriatum_Signal, $Bdorsalstriatum_Detection, $Afrontalcortex_Signal, $Afrontalcortex_Detection, $Bfrontalcortex_Signal, $Bfrontalcortex_Detection, $Ahypothalamus_Signal, $Ahypothalamus_Detection, $Bhypothalamus_Signal,$Bhypothalamus_Detection, $StriatumAve, $CortexAve, $HypothalamusAve) = split("\t", $_);

	if (defined $id_to_ll{$id} ) {

		$Probeset=$id_to_probe{$id};
		$Symbol=$id_to_ll{$id};

		if ($Probeset=~/x_at/){
			push(@{$gene_hash{$Symbol}{x_at}{probe}}, $Probeset );
			for ($j=0; $j<61; $j++) {
				push(@{$gene_hash{$Symbol}{x_at}{$j}}, $line[$j]);
			}
		}

		if ($Probeset=~/s_at/){
			push(@{$gene_hash{$Symbol}{s_at}{probe}}, $Probeset );
				for ($j=0; $j<61; $j++) {
				push(@{$gene_hash{$Symbol}{s_at}{$j}}, $line[$j]);
			}
		}

		if ($Probeset=~/a_at/){
			push(@{$gene_hash{$Symbol}{a_at}{probe}}, $Probeset );
				for ($j=0; $j<61; $j++) {
				push(@{$gene_hash{$Symbol}{a_at}{$j}}, $line[$j]);
			}
		}

		if ($Probeset=~/[0-9]_at/){
			push(@{$gene_hash{$Symbol}{_at}{probe}}, $Probeset );
				for ($j=0; $j<61; $j++) {
				push(@{$gene_hash{$Symbol}{_at}{$j}}, $line[$j]);
			}
		}
	}
}
close (HANDLE);

# diagnostic :
# 
# print Dumper (\%gene_hash).$n;




foreach $Symbol (sort keys %gene_hash) {
	$found=0;
	if( defined @{$gene_hash{$Symbol}{_at}{probe}}[0]) {
		print $Symbol.$t;
		for ($j=0; $j<61; $j++) {
			print avg(\@{$gene_hash{$Symbol}{_at}{$j}} ); print $t;
		}
#		print $n;
		$found=1;
	}

	if( $found==0 && defined @{$gene_hash{$Symbol}{a_at}{probe}}[0]) {
		print $Symbol.$t;
		for ($j=0; $j<61; $j++) {
			print avg(\@{$gene_hash{$Symbol}{a_at}{$j}} ); print $t;
		}
#		print $n;

		$found=1;
	}

	if( $found==0 && defined @{$gene_hash{$Symbol}{s_at}{probe}}[0]) {
		print $Symbol.$t;
		for ($j=0; $j<61; $j++) {
			print avg(\@{$gene_hash{$Symbol}{s_at}{$j}} ); print $t;
		}
#		print $n;
		$found=1;
	}

	if( $found==0 && defined @{$gene_hash{$Symbol}{x_at}{probe}}[0]) {
		print $Symbol.$t;
		for ($j=0; $j<61; $j++) {
			print avg(\@{$gene_hash{$Symbol}{x_at}{$j}} ); print $t;
		}
#		print $n;
	}
	print "\n";
}

#subroutine to calculate average value of an array
sub avg {
	my $result;
	my $ar = shift;
	foreach (@$ar) { $result += $_ }
	return $result / scalar(@$ar);
}

