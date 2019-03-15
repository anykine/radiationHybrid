open(INPUT, "amon_negs.txt");
while(<INPUT>){
	chomp;
	@list = split(/\t/);
	if ($list[1] > 0){
		next;
	}
	if ($list[0] =~ /\/\/\//){
		my @terms = split(/ \/\/\/ /, $list[0]);
		foreach $t (@terms){
			print "$t\t$list[1]\n";
			#print "$t\n";
			#print "$list[1]\n";
			#print "$t\t\n";
		}
	}else{
		print join("\t", @list),"\n";
	}
}
