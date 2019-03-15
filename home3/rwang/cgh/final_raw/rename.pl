#!/usr/bin/perl -w
#
open(INPUT, "cgh.config.final") || die;
#open(INPUT, "cgh.config") || die;
while(<INPUT>){
	chomp; next if /^#/;
	my($file, $num ) = split(/,/);
	my $newfile = "cgh_rh".$num;
	print $file,"\n";
	#`mv $file $newfile`;
	`mv $newfile $file`;
}
