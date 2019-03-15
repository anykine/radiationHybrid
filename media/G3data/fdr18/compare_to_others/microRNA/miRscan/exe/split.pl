#!/usr/bin/perl


# split RNAfold output into separate .mfe files. E.g:
# split.pl RNAfold.out   or RNAfold < sequences | split.pl

$max_name=30;  # current clustalw cuts names at 30 characters
while (<>) {
  next unless (/^>/); #skip junk (e.g. from part_func folding)
  chomp;
  ($blah, $name) = split;
  $seq=<>;
  $struct = <>;
  $fname = substr($name,0,$max_name) . ".mfe";
  open(OUT, ">$fname");
  print OUT "> $name\n", $seq, $struct;
  close(OUT);
}
