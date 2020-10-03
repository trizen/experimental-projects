#!/usr/bin/perl

# Terms of A082180 that are not squares or cubes of primes.
# https://oeis.org/A328497

# Known terms:
#   418, 27173, 2001341

# a(4) > 10^8. - Giovanni Resta, Oct 18 2019

# It's hard to find a(4), if it exists.

# a(4) > 100000569

# Upper-bound:
#   a(4) <= 16024189487

# See also:
#   https://oeis.org/A228562

use 5.010;
use strict;
use warnings;

use integer;

use experimental qw(signatures);
use ntheory qw(:all);

sub modular_binomial ($n, $k, $m) {

    my @rems_mods;
    foreach my $pair (factor_exp($m)) {
        my ($p, $e) = @$pair;
        push @rems_mods, [modular_binomial_prime_power($n, $k, $p, $e), powint($p,$e)];
    }

    return chinese(@rems_mods);
}

sub factorial_prime_pow ($n, $p) {
    ($n - vecsum(todigits($n, $p))) / ($p - 1);
}

sub binomial_prime_pow ($n, $k, $p) {
#<<<
      factorial_prime_pow($n,      $p)
    - factorial_prime_pow($k,      $p)
    - factorial_prime_pow($n - $k, $p);
#>>>
}

sub binomial_non_prime_part ($n, $k, $p, $e) {
    my $pe = powint($p, $e);
    my $r  = $n - $k;

    my $acc     = 1;
    my @fact_pe = (1);

    foreach my $x (1 .. $pe - 1) {
        if ($x % $p == 0) {
            $x = 1;
        }
        $acc = mulmod($acc, $x, $pe);
        push @fact_pe, $acc;
    }

    my $top         = 1;
    my $bottom      = 1;
    my $is_negative = 0;
    my $digits      = 0;

    while ($n) {

        if ($acc != 1 and $digits >= $e) {
            $is_negative ^= $n & 1;
            $is_negative ^= $r & 1;
            $is_negative ^= $k & 1;
        }

#<<<
        $top    = mulmod($top,    $fact_pe[$n % $pe], $pe);
        $bottom = mulmod($bottom, $fact_pe[$r % $pe], $pe);
        $bottom = mulmod($bottom, $fact_pe[$k % $pe], $pe);
#>>>

        $n = $n / $p;
        $r = $r / $p;
        $k = $k / $p;

        ++$digits;
    }

    my $res = mulmod($top, invmod($bottom, $pe), $pe);

    if ($is_negative and ($p != 2 or $e < 3)) {
        $res = $pe - $res;
    }

    return $res;
}

sub modular_binomial_prime_power ($n, $k, $p, $e) {
    my $pow = binomial_prime_pow($n, $k, $p);

    if ($pow >= $e) {
        return 0;
    }

    my $modpow = $e - $pow;
    my $r = binomial_non_prime_part($n, $k, $p, $modpow) % powint($p,$modpow);

    if ($pow == 0) {
        return ($r % powint($p,$e));
    }

    return mulmod(powmod($p, $pow, powint($p,$e)), $r, powint($p,$e));
}

say modular_binomial(2*16024189487, 16024189487, 16024189487);

my $count = 0;
#forcomposites {
forsquarefree {

    say "Testing: $_";

    my $k = $_;

    #~ if (is_square($k) and is_prime(sqrtint($k))) {
        #~ ## ok
    #~ }
    #~ elsif (is_power($k, 3) and is_prime(rootint($k, 3))) {
        #~ ## ok
    #~ }

    if (is_prime($k)) {
        ## ok
    }
    elsif (modular_binomial($k<<1, $k, $k) == 2) {
        die "Found: $k";
    }
} 100000569, 2e8;
