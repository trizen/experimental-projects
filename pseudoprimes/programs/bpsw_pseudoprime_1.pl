#!/usr/bin/perl

# Try to find a BPSW pseudoprime.

use 5.020;
use strict;
use warnings;

use Math::Prime::Util::GMP qw(
  is_pseudoprime
  is_lucas_pseudoprime
  is_strong_lucas_pseudoprime
  is_extra_strong_lucas_pseudoprime
  is_almost_extra_strong_lucas_pseudoprime
);

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;
    $n =~ /^[0-9]+\z/ or next;
    next if ($n < ~0);

    is_pseudoprime($n, 2) || next;

    if (is_lucas_pseudoprime($n)) {
        say $n;
    }
}

__END__
