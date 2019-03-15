# reduce the number of rows in sample
use strict;
my ($file, $stride) = @ARGV;
open(INPUT, $file ) || die "err $!";
while(<INPUT>){
	print if ($. % $stride == 0);
}
