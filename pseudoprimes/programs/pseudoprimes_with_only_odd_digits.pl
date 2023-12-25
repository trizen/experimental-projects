#!/usr/bin/perl

# List various pseudoprimes > 2^64 with only odd digits.

use 5.036;

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;
    $n > ~0 or next;

    $n =~ tr/02468// and next;

    say $n;
}

__END__
177335371997353711177
391557355557595533797
395793517593599999999
