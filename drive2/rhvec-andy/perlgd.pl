#!/usr/bin/perl -w
#
use GD::Simple;
$img = GD::Simple->new(640, 480);
$img->fgcolor('black');
$img->bgcolor('yellow');
$img->rectangle(10,10,50,50);
$img->ellipse(50,50);
print $img->png;
