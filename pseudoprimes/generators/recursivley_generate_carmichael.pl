#!/usr/bin/perl

# Author: Daniel "Trizen" Șuteu
# Date: 10 August 2020
# https://github.com/trizen

# Recursively generate Carmichael numbers from a given input numbers, using its lambda value.

use 5.020;
use warnings;

use Math::GMPz;
use Math::AnyNum qw(is_smooth is_rough smooth_part rough_part);
use ntheory qw(mulmod divisor_sum divisors forcomb is_prime factor);
use Math::Prime::Util::GMP qw(gcd totient carmichael_lambda mulint divint vecprod modint binomial);
use experimental qw(signatures);

sub is_cyclic ($n) {
    gcd(totient($n), $n) == 1;
}

sub lambda_primes ($L, $n) {
    grep {
            ($_ > 2)
        and (($L % $_) != 0)
        and is_prime($_)
        and gcd($n, $_) == 1
        and is_cyclic(mulint($n, $_))
    }
    map { ($_ >= ~0) ? (Math::GMPz->new($_) + 1) : ($_ + 1) } divisors($L);
}

sub generate($n) {

    is_cyclic($n) || return;

    #~ if ($n >= ~0 and ref($n) ne 'Math::GMPz') {
        #~ $n = Math::GMPz->new("$n");
    #~ }

    my $L = carmichael_lambda($n);

    #~ if ($L >= ~0) {
        #~ $L = Math::GMPz->new($L);
    #~ }

    if (divisor_sum($L, 0) > 2**17) {    # too many divisors
        return;
    }

    my @P = lambda_primes($L, $n);
    my $r = modint($n, $L);

    my @arr;

    foreach my $p (@P) {
        if (mulmod($p, $r, $L) == 1) {
            push @arr, mulint($n, $p);
            say $arr[-1];
        }
    }

    foreach my $k (3) {
        if (binomial(scalar(@P), $k) < 1e6) {
            forcomb {
                my $z = vecprod(@P[@_]);
                if (mulmod($r, $z, $L) == 1) {
                    push @arr, mulint($n, $z);
                    say $arr[-1];
                }
            } scalar(@P), $k;
        }
    }

    foreach my $k (@arr) {
        generate($k);
    }
}

use Memoize qw(memoize);
memoize('generate');

#<<<
#~ foreach my $k(1e6..1e7) {
    #~ is_cyclic($k) || next;
    #~ generate($k);
#~ }
#>>>

#~ __END__

while (<>) {
    my $n = (split(' ', $_))[-1];

    $n                || next;
    $n =~ /^[0-9]+\z/ || next;

    #is_smooth($n, 1e7) || next;
    is_rough($n, 1e7) && next;

    if (length($n) > 40) {
        is_smooth($n, 1e7) || next;
    }

    #~ my @f = factor($n);

    #~ next if scalar(@f) > 20;

    #~ foreach my $k (1..3) {
        #~ forcomb {
            #~ generate(divint($n, vecprod(@f[@_])));
        #~ } scalar(@f), $k;
    #~ }

    #~ foreach my $k(2..1e5) {
        #~ modint($n,$k) == 0 or next;
        #~ generate(divint($n,$k));
    #~ }

    #my $s = smooth_part($n, 1e3);
    #~ my $s = rough_part($n, 1e4);

    #~ divisor_sum($s, 0) <= 2**10 or next;

    #~ foreach my $k (divisors($s)) {
        #~ $k > 1 or next;
        #~ generate(divint($n,$k));
    #~ }

    generate($n);
}
