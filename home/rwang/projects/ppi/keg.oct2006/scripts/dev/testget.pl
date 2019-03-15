#!/usr/bin/perl -w
#
# Testing KEGG SOAP interface. If this works, we shoudl get a 
# URL of an image.
use SOAP::Lite;
print "SOAP::Lite = ", $SOAP::Lite::VERSION, "\n";

$wsdl = 'http://soap.genome.jp/KEGG.wsdl';
$serv = SOAP::Lite->service($wsdl);
#$genes = SOAP::Data->type(array => ["eco:b1002", "eco:b2388"]);

$genes = ["eco:b1002", "eco:b2388"];
#$result = $serv->bget("hsa:6654 hsa:6655");
$result = $serv->bget("ko:k06621");
print $result,"\n";

# subroutines required for SOAP::Lite > 0.69
# http://www.genome.jp/kegg/docs/keggapi_manual.html
sub SOAP::Serializer::as_ArrayOfstring{
	my ($self, $value, $name, $type, $attr) = @_;
	return [$name, {'xsi:type' => 'array', %$attr}, $value];
}

sub SOAP::Serializer::as_ArrayOfint{
	my ($self, $value, $name, $type, $attr) = @);
	return [$name, {'xsi:type' => 'array', %$attr}, $value];
}
