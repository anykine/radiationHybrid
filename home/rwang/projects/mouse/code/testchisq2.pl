#!/usr/bin/perl -w
# Richard Wang 10/21/05
# -strip down to output matrix only
# DOES NOT WORK b/c of huge dataset, rewrote in c++ as rhvector

# based on matrix.pl script in RSPerl in examples/
# match, convert is the match and conversion functions
# for R <-> Perl, which we do not use here but might
# be useful in the future

use R;
use RReferences;
use lib '/home/rwang/lib';
use strict;
use warnings;
use util;
use Data::Dumper;

=head1 Converter Matching/predicate Routine.

This routine is called by the user-converter
mechanism as it loops over the registered converters
while looking for one that claims it can convert an
R object to Perl. This routine examines the object
and determines whether it is a matrix. If it is,
it returns C<TRUE> so that the associated converter
will be called to convert the object.

=cut 

sub match {
    print "[matrix match]\n";
    my $obj = shift;
    print "[match] ", $obj, " ", ref($obj), "\n";
#    my $ok = R::call("inherits", $obj, "matrix");

    my $type = R::call("typeof", $obj);
    print "Typeof r object ", $type, "\n";
       # if there is more than one class, we need to get this as an array.
    my @class = R::call("class", $obj);
    print "Class: ", $class[0], "\n";
    my $ok = ($class[0] eq "matrix");
    print "In matrix match ", $ok, "\n";
    return($ok);
}

=head1 Converter

  This is the routine that actually does the conversion. It is quite
simple and should be modified to do something useful. It illustrates
how we get a reference to the R object as the only argument to this 
converter and then we can invoke R functions using this object,
typically to query its elements so as to convert them to Perl
values. In this case, we ask for 

=over 4

=item [1]
  the type/mode of the elements of the matrix,

=item [2]
    the dimensions of the R matrix,

=item [3]
 then its values.

=back

These are done via simple C<R::call> invocations.

=cut


sub convert {
    my $obj = shift;
    my $type = R::call("typeof", $obj);
    my @dim = R::call("dim", $obj);
    my @values = R::call("as.vector", $obj);
print "Converted matrix: ", $dim[0], ", ", $dim[1], " ", $#values, "\n";

    return(@values);
    #return($values);
}

=head1 Registering the converter

  Here we register the converter, specifying both the match and converter routines
  and a description that can be accessed in R using getPerlConverterDescriptions()
  as in
    C<getPerlConverterDescriptions(c(toPerl=T))>
  The final argument is currently ignored, but is intended to control whether we
  automatically should use this converter when we discover an homogenous array of 
  elements that can be processed by this converter.

=cut

#R::setConverter(\&match, \&convert, "A simple Perl routine for converting an R matrix", 1);

#********************start here************************
unless($ARGV[0]) {
	print "usage $0 <rhvector file>\n";
	exit;
}

# read file
my @raw = get_file_data($ARGV[0]);

# parse & count
my $data_ref = calc(\@raw);

sub calc {
	# scores pres/abs in two vectors into array
	my @calc_data = ();
	my $bothpresent = 0;
	my $bothabsent  = 0;
	my $onepresoneabs   = 0;
	my $oneabsonepres = 0;

	#parens required for reference to array:list mode!
	my($ref_raw) = @_;
	# this is the last elem of array
	my $end = $#{$ref_raw};
	#$end=100;
	for (my $i=0; $i<=$end; $i++) {
		my @vec1 = stringtoarray(${$ref_raw}[$i]);
		for (my $j=$i+1; $j<=$end ; $j++) {
			my @vec2 = stringtoarray(${$ref_raw}[$j]);
					#compare arrays
					#print "dollarhash=$#vec1\n";
					#print "array= ". @vec1 . "\n";
					for (my $k=0; $k<$#vec1; $k++){
						if (($vec1[$k] == 1) && ($vec2[$k] ==1) ){
							$bothpresent++;						
						}
						if (($vec1[$k] == 1) && ($vec2[$k] ==1) ){
							$bothabsent++;						
						}
						if (($vec1[$k] == 1) && ($vec2[$k] ==0) ){
							$onepresoneabs++;						
						}
						if (($vec1[$k] == 0) && ($vec2[$k] ==1) ){
							$oneabsonepres++;						
						}
						#print "$k=$vec1[$k]\n";
					}
					#print "both present=$bothpresent\nboth absent=$bothabsent\n";
					#print "one pres one abs=$onepresoneabs\n";
					#print "one abs one pres=$oneabsonepres\n";
					#store data in array
					#format is like the following:
					# A and B are arrays with A being first and B second:
					# A_present, B_present
					# A_present, B_absent
					# A_absent , B_present
					# A_absent,  B_absent
					# i=marker A, j=marker B
					push @calc_data, [$bothpresent, $onepresoneabs, 
														$oneabsonepres,$bothabsent, $i,$j];
					#clear vars
					$bothpresent = 0;
					$bothabsent  = 0;
					$onepresoneabs   = 0;
					$oneabsonepres = 0;
		}#for
	}#for 
	#need to return as reference
	return \@calc_data;
}#end sub

# do stat
#print "dataref=".$data_ref."\n";
#print "dumper: ". Dumper($data_ref);

my @data = @$data_ref;
# see calc() above for format of file
open (OUTPUT, ">chisq_out.txt") || die("can't open output file");
foreach $a(@data) {
	print OUTPUT "@$a\n";
}


###### FUNCTIONS ######

sub stringtoarray {
	#this needs () to get the whole string?!
	my($str) = @_;
	my @vec = split(//,$str);
	return @vec;
}
sub runR {
	##start R##
	&R::startR("--silent", "--vanilla");
	R::library("RSPerl");

	##pass in parm
				for my $a(@$data_ref){
					my ($a1,$a2,$a3,$a4) = @$a;
					#print ($a1,$a2,$a3,$a4) ;
					#print "@$a\n";
					my @input = ($a1,$a2,$a3,$a4) ;
					my $var = &R::matrix(\@input,2,2);
					my $res = &R::call("chisq.test", $var);
					print $res->getEl('p.value')."\n";
	}
}

sub test{
				my @test=(58,28,71,92);
				#another way, create function
				#R::eval("testmat <<- function() {matrix(c(58,28,71,92),2,2) }");
				#my $var = R::call("testmat");
				#R: matrix(data, nrow, ncol, byrow)
				my $var = &R::matrix(\@test,2,2);
				my $res = &R::call("chisq.test", $var);
				print $res->getEl('p.value');
}
