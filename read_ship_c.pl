#!/usr/bin/perl -w

use strict;
use Data::Dumper;

my $f_name = "ship";

my %arrays;
open(H, "<", $f_name.".c");
my $in_array = 0;
my $l;
my $cur_key;
while( $l = <H>) {
    chomp $l;
	#пропускаем закоментированные строки
    if($l =~ m/^\s*\/\//) {
	next;
    }

    if($l =~ m/^.+\s+([^[\s]+)\s*\[.+\]\s*=\s*{/) {		#ищем начало объявления массива
	$in_array = 1;
	$cur_key  = $1;	
	#print	"find $cur_key\n";
	#print	"my \@$cur_key = (\n";
	$arrays{$cur_key} = [];
    }

	#ищем начало объявления массива или его окончание
    if($in_array) {	#мы в массиве, надо разобрать текущую строку и добавить данные из не в текущий массив
	if($l =~ m/^\s*};/) {
	    #print "end $cur_key\n";
	    #print "); #end $cur_key\n";
	    $in_array = 0;
	    next;
	}
	    #Разбираем строку выделяем элементы содержащиеся в скобочках {} при этом не содержащие скобок
	foreach my $e ($l =~ m/{([^{}]+)}/g) {
	    $e =~ s/f//g;
	    push @{$arrays{$cur_key}}, $e;
	    #print "[ $e ]";
	}
    } 
}
close(H);

open(H, '>', $f_name."_data.pm");
print H "package ${f_name}_data;\n\n";
foreach my $k (sort keys %arrays ) {
    print H "our \@$k = (\n";
    my $a = $arrays{$k};
    foreach my $i (0..$#$a-1 ) {
	print H "\t[ $a->[$i] ],\n";
    }
    print H "\t[ $a->[$#$a] ]\n";
    print H "); #end $k\n";
}
print H "1;\n";

close(H);
#print "Dump arrays:\n".Dumper(\%arrays);
