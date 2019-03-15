#!/usr/bin/perl -w

$t="\t";
$n="\n";


$a1="1_ll.txt";
$a2="2_ll.txt";
$a3="3_ll.txt";
$a4="4_ll.txt";
$a5="5_ll.txt";

%over=();
open (A1, $a1);
while (<A1> ) {
	chomp $_;
	$over{$_}=1;
}
close (HANDLE);

open (A2, $a2);
while (<A2> ) {
	chomp $_;
	if ( defined $over{$_} ) { $over{$_}++; }
	else {	$over{$_}=1;	}
}
close (HANDLE);

open (A3, $a3);
while (<A3> ) {
	chomp $_;
	if ( defined $over{$_} ) { $over{$_}++; }
	else {	$over{$_}=1;	}
}
close (HANDLE);

open (A4, $a4);
while (<A4> ) {
	chomp $_;
	if ( defined $over{$_} ) { $over{$_}++; }
	else {	$over{$_}=1;	}
}
close (HANDLE);

open (A5, $a5);
while (<A5> ) {
	chomp $_;
	if ( defined $over{$_} ) { $over{$_}++; }
	else {	$over{$_}=1;	}
}
close (HANDLE);

foreach $ll (keys %over ) {
	if ($over{$ll} == 2) {
		print $ll.$n;
	}
}

