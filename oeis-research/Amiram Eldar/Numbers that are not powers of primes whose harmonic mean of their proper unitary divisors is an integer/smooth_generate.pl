#!/usr/bin/perl

# Numbers that are not powers of primes (A024619) whose harmonic mean of their proper unitary divisors is an integer.
# https://oeis.org/A335270

# Known terms:
#   228, 1645, 7725, 88473, 20295895122, 22550994580

# These are numbers m such that omega(m) > 1 and (usigma(m)-1) divides m*(2^omega(m)-1).

# Conjecture: all terms have the form n*(usigma(n)-1) where usigma(n)-1 is prime.
# The conjecture was inspired by the similar conjecture of Chai Wah Wu from A247077.

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    #~ 1

    #~ if ($p == 2) {
    #~ return valuation($n, $p) < 5;
    #~ }

    #~ if ($p == 3) {
    #~ return valuation($n, $p) < 3;
    #~ }

    #~ if ($p == 7) {
    #~ return valuation($n, $p) < 3;
    #~ }

    if ($p <= 13) {
        return (valuation($n, $p) < 2);
    }

    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

sub usigma {
    vecprod(map { powint($_->[0], $_->[1]) + 1 } factor_exp($_[0]));
}

sub isok ($m) {
    modint(mulint($m, ((1 << prime_omega($m)) - 1)), usigma($m) - 1) == 0;
}

my $h = smooth_numbers(1e10, primes(200));

say "\nTotal: ", scalar(@$h), " terms\n";

my %table;

foreach my $n (@$h) {

    #$n > 1e7 || next;

    my $p = usigma($n) - 1;

    is_prime($p) || next;

    next if ($n == $p);

    my $m = mulint($n, $p);

    if (isok($m)) {
        say "Found: $n -> $m";
    }
}

__END__
Found: 12 -> 228
Found: 75 -> 7725
Found: 35 -> 1645
Found: 231 -> 88473
Found: 108558 -> 20295895122
Found: 120620 -> 22550994580
