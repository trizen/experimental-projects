#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 08 July 2019
# https://github.com/trizen

use 5.020;
use Math::GMPz;
use ntheory qw(:all);
use experimental qw(signatures);

my @primes = (@{primes(1000)});

my %table;

sub f($n) {

    my $count = -1;

    while (is_semiprime($n) && !is_square($n)) {
        my ($x, $y) = factor($n);
        $n = ($y - $x);
        ++$count;
    }

    $count;
}

my $from = Math::GMPz->new("5");

my @arr = [f($from), $from];

foreach my $n (@arr) {
    foreach my $p (@primes) {
        my $t = $p * ($n->[1] + $p);
        if (is_semiprime($t) and !is_square($t)) {

            my $count = $n->[0] + 1;
            push @arr, [$count, $t];

            #if ($count == 3) {
             #   say join ', ', map{$_->[1]}grep{$_->[0] == 1}@arr;
                #say "$t = $p * ($n->[1] + $p)";
            #}

            if (exists $table{$count}) {
                if ($t < $table{$count}) {
                    $table{$count} = $t;
                    say "a($count) <= $t";
                }
            }
            else {
                $table{$count} = $t;
                say "a($count) <= $t";
            }
        }
    }
}
