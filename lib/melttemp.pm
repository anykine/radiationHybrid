# perl implementation of web pcr primer calculator
# members.aol.com/_ht_a/lucatoldo/myhomepage/JaMBW/3/1/9/index.html
#
#

sub countACTG {
	my %ACTG;
	my($seq) = @_;
	#count number of nucleotides
	$ACTG{'a'}  = ($seq =~ tr/Aa//);
	$ACTG{'c'}  = ($seq =~ tr/Cc//);
	$ACTG{'g'}  = ($seq =~ tr/Gg//);
	$ACTG{'t'}  = ($seq =~ tr/Tt//);
	return \%ACTG;
}

sub melttemp {
	my($seq) = @_;
	$hash_ref = countACTG($seq);
	$len = length($seq);

	if ($len > 0) {
		if ($len < 14) {
			$temp = 2*(${$hash_ref}{'a'} + ${$hash_ref}{'t'}) + 
				4*(${$hash_ref}{'g'} + ${$hash_ref}{'c'});
		} else {
			$temp = 64.9 + 41*((${$hash_ref}{'g'}+${$hash_ref}{'c'}-16.4)/$len);
		}
		return $temp;
	} else {
		print "Sequence length is zero\n";
		return;
	}
}

sub GCcontent {
	my($seq) = @_;
	my $len = length($seq);
	$hash_ref = countACTG($seq);
	if ($len > 0) {
		$ans = 100*(${$hash_ref}{'g'}+${$hash_ref}{'c'})/($len);
		return $ans;
	} else {
		print "divide by zero error\n";
		return;
	}
}

sub cleanseq{
	my($seq) = @_;
	@chars = split(//, $seq);
	for ($i=0; $i<=$#chars; $i++){
		if (($chars[$i] eq 'A') || ($chars[$i] eq 'a') ||
		($chars[$i] eq 'C') || ($chars[$i] eq 'c') ||
		($chars[$i] eq 'G') || ($chars[$i] eq 'g') ||
		($chars[$i] eq 'T') || ($chars[$i] eq 't')) {
			$str .= $chars[$i];
		}
	}	
	return $str;
}

1
