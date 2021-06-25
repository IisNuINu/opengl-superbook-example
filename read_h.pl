#!/usr/bin/perl -w

use strict;

my $f_name = shift || die "Need define filename as firs parametr!\n";

open(H, "<", $f_name);
my @lines = <H>;
close(H);
my ($w, $h) = (0, 0);
foreach my $l (@lines) {
    foreach my $he ($l =~ m/0[xX]([0-9a-fA-F]{2})/g) {
	$w++ if($h == 0);	#Ширину считаем только по 1 элементу массива
	print "'$he', ";
    }
    $h++;
    print "\n";
}
$w  *= 8; 
print "width = $w, height = $h\n";
