#!/usr/bin/perl

# Separate Carmichael numbers.

use 5.014;
use ntheory qw(:all);

open my $car_fh, '>', 'zcar.txt';
open my $fer_fh, '>', 'zfer.txt';

while (<>) {

    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];
    $n || next;

    if (is_carmichael($n)) {
        say "[$.] Carmichael: $n";
        say {$car_fh} $n;
    }
    else {
        say {$fer_fh} $n;
    }
}

close $car_fh;
close $fer_fh;
