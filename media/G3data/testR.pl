use R;
use RReferences;

&R::initR("--silent");
@x = &R::rnorm(10);
#print "@x\n";
&R::call("pdf", "test.pdf");
%args = ('pch', "+", 'id',100);
&R::callWithNames("plot", {'', \@x, 'ylab', 'Richard stuff'});
@x = &R::call("dev.off");
$x = &R::callWithNames("foo", \%args);
print "Result=$x\n";
print "@x\n";
