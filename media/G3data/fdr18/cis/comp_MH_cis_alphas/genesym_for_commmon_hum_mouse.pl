#!/usr/bin/perl -w
#
# quick script to add gene symbols to common mus/human cis alphas
#
%mousesym = ();

sub load_mousesym{
	open(INPUT, "/media/G3data/fdr18/cis/comp_MH_cis_alphas/mouse_genesym.txt") || die "cannot open mouse symbols";
	while(<INPUT>){
		next if /^#/; chomp;
		my ($idx, $sym) = split(/\t/);
		$mousesym{$idx} = $sym;	
	}
}

sub add_genesymbol{
	#open(INPUT, "comp_hum_mouse_FDR40.txt") || die "cannot open comp hum mouse fdr 40";
	#open(INPUT, "comp_hum_mouse_FDR10.txt") || die "cannot open comp hum mouse fdr 40";
	#open(INPUT, "comp_MH_FDR30.txt") || die "cannot open comp hum mouse fdr 40";
	open(INPUT, "comp_MH_FDR40.txt") || die "cannot open comp hum mouse fdr 40";

	while(<INPUT>){
	
		next if /^#/; chomp;
		my @d = split(/\t/);
		print join("\t", @d),"\t";
		print uc($mousesym{$d[5]}), "\n";
	}
}



######### MAIN ##########
load_mousesym();
add_genesymbol();
