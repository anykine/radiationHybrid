#!/usr/bin/perl -w
# the CGH file does not have a header, let's make one like this:
# ID | Chrom | Start | End | TCGA1.test | TCGA1.ref | TCGA2.test
# using the matched_files.cgh1.1.txt
#
my @header = ();
push @header, "ID";
push @header, "Chrom";
push @header, "Start";
push @header, "End";
open(INPUT, "/media/usbdisk/tcga/matched_files.cghl1.1.txt") || die "err $!";
while(<INPUT>){
	#use the second file name, truncate .CEL
	if ($. % 2 == 0){
		/(TCGA-\d{2}-\d{4}-\d{2})/;
		my $s = $1;
		#print $s,"\n";
		$s =~ s/-/\./g;
		# uncomment for CGHnormaliter
		#push @header, "$s.test", "$s.ref";
		# uncomment for CGHcall
		push @header, "$s";
	}
}
print join("\t", @header);
