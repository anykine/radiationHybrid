#!/usr/bin/perl -w

use R;
use RReferences;

&R::initR("--silent");
#$x = &R::call("sum", (1,2,3));
@a = (1,2,3,4);
#R::eval("a<--matrix(c(1,2,3,4), ncol=2,byrow=1); fisher.test(a)");
$b = R::callWithNames("matrix", {'data', \@a, 'ncol',2,'byrow',1});
#print $x;
 #R::callWithNames("fisher.test", $b);
#print $y;
