#!/usr/bin/perl -w
#
# binary search algorithm
#
# pass a SORTED list
sub bsearch{
	my($target, $aref) = @_;
	my($lower, $upper) = (0, $#$aref);
	my $i;
	while ($lower <= $upper){
		$i = int(($lower+$upper)/2);
		if ($aref->[$i] < $target){
			$lower = $i+1;
		} elsif( $aref->[$i] > $target){
			$upper = $i-1;
		} else {
			return $i;
		}
	}
	return -1; #not found

}
sub pad{
	my ($i, $n) = @_;
	my @a = ();
	for($c = 0; $c < $n; $c++){
		push (@a, $i);
	}
	return @a;
}
	
my @a10 = (0,pad(1,10), 2);
print "@a10\n";
my $ans = bsearch(1, \@a10);
print $ans,"\n";
