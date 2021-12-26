#!/usr/bin/perl

# Compute the frequency of bytes in a given input data stream

use 5.014;
use strict;
use warnings;

use experimental qw(signatures);

binmode(STDIN,  ':raw');
binmode(STDOUT, ':raw');

my %table;
my $total = 0;

while (<>) {
    foreach my $c (unpack("C*", $_)) {
        ++$table{$c};
        ++$total;
    }
}

sub print_line ($key, $value) {
    printf("%3d  %2s  %.2f\n", $key, chr($key) =~ /[[:print:]]/ ? chr($key) : '--', $value / $total * 100);
}

foreach my $key (sort { $a <=> $b } keys %table) {
    print_line($key, $table{$key});
}

say "\nTop 10 (max):";

my @top10_max = sort { ($table{$b} <=> $table{$a}) || ($a <=> $b) } keys %table;

$#top10_max = 10;

foreach my $key (@top10_max) {
    print_line($key, $table{$key});
}

say "\nTop 10 (min):";

my @top10_min = sort { ($table{$a} <=> $table{$b}) || ($a <=> $b) } keys %table;

$#top10_min = 10;

foreach my $key (@top10_min) {
    print_line($key, $table{$key});
}
