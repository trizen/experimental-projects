#!/usr/bin/perl

# Palindromic pseudoprimes in base n.

# See also:
#   https://oeis.org/A210454
#   https://oeis.org/A068445

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use ntheory    qw(:all);
use List::Util qw(uniq);

my $base = 3;

my %seen;
my @nums;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    if ($base <= 10) {
        my $s = join '', todigits($n, $base);
        $s eq reverse($s) or next;
    }
    else {
        my @d = todigits($n, $base);
        my $x = join(' ', @d);
        my $y = join(' ', reverse(@d));
        $x eq $y or next;
    }

    #is_carmichael($n) || next;
    is_pseudoprime($n, 2) || next;

    push @nums, $n;
}

@nums = uniq(@nums);
@nums = sort { $a <=> $b } map { Math::GMPz->new($_) } @nums;

#say join(', ', @nums);
say for @nums;
