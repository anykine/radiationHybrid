#!/usr/bin/perl

$perldir=`which perl`;
chomp $x;
$dir=`pwd`;
chomp $dir;


foreach $file ("miRscan", "anote.pl","modifyalidotps","modifyrnafoldps_clusters_new","newconsens.pl","split.pl") {
    open(F, "exe/$file");
    open(G, ">exe/tmp");
    while(<F>) {
	if (/^\$EXEDIR/) {
	    print G qq(\$EXEDIR="$dir/exe";\n);
	} else {
	    if (/^\#!/) {
		print G qq(\#!$perldir\n);
	    } else {
		if (/^\$MATRIXDIR/) {
		    print G qq(\$MATRIXDIR="$dir/matrices";\n);
		} else {
		    print G;
		}
	    }
	}
    }
    close F; close G;
    system("mv $dir/exe/tmp $dir/exe/$file; chmod a+x $dir/exe/$file;");
}
