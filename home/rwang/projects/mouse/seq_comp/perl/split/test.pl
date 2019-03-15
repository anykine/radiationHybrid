#!/usr/bin/perl -w

$pfile = "56407896";
$prefix = "./gbfiles/";

open(INPUT, "$prefix$pfile") or die "cannot open";
@data = <INPUT>;
close(INPUT);

print "size " , scalar @data, "\n";
print $data[1], "\n";

for $i (@data){
	print $. , ":", $i,"\n";
}
