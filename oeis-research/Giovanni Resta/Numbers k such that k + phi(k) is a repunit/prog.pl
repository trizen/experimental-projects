#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 22 August 2019
# https://github.com/trizen

# Numbers k such that k + phi(k) is a repunit.
# https://oeis.org/A309835

# New terms:
#   [3, 179, 124424536519] = 66815976110703
#   [11, 31, 43, 407552767894623156333166236698497] = 5975946235638859341313216528710061511

# 4 a + 1!=0, b = (5555555555555 - a)/(4 a + 1)
# 2 p - 1!=0, q = (p + 11111111111110)/(2 p - 1)

# 2 p q - p - q + 1!=0, r = (p q - p - q + 11111111111112)/(2 p q - p - q + 1)

use 5.014;
use warnings;
use ntheory qw(:all);

# The number 5975946235638859341313216528710061511 also belong to this sequence.

use Math::GMPz;

sub find_pqrst {

    my $lim    = 2e2;
    my @primes = @{primes($lim)};

    foreach my $z (11 .. 100) {    # find terms of the form: k = p*q*r*s*t (no luck)

        my $n = Math::GMPz->new('1' x $z);

        say "[$z] Checking: $n";

        foreach my $p (@primes) {
            for (my $q = next_prime($p) ; $q <= $lim ; $q = next_prime($q)) {
                for (my $r = next_prime($q) ; $r <= $lim ; $r = next_prime($r)) {
                    for (my $s = next_prime($r) ; $s <= $lim ; $s = next_prime($s)) {

                        my $num = $n + ($p - 1) * ($q - 1) * ($r - 1) * ($s - 1);
                        my $den = $p * $q * $r * $s + ($p - 1) * ($q - 1) * ($r - 1) * ($s - 1);

                        if ($num % $den == 0) {

                            my $t = $num / $den;

                            if (is_prob_prime($t)) {
                                say "[$p, $q, $r, $s, $t] = ", $p * $q * $r * $s * $t;
                            }
                        }
                    }
                }
            }
        }
    }
}

#~ find_pqrst();

sub find_ppq {

    foreach my $t (10 .. 100) {    # no luck with k = p^2*q

        my $n = Math::GMPz->new('1' x $t);
        say "[$t] Checking: $n";

        forprimes {
            my $p = $_;

            my $num = $n;
            my $den = $p * (2 * $p - 1);

            if ($num % $den == 0) {

                my $q = $num / $den;

                if (is_prob_prime($q)) {
                    say "[$p^2, $q] = ", $p * $p * $q;
                }
            }

        } 1e8;
    }
}

#~ find_ppq();

sub find_pqrs {

    my $lim    = 1e2;
    my @primes = @{primes($lim)};

    foreach my $t (1 .. 100) {    # find terms of the form: k = p*q*r*s

        my $n = Math::GMPz->new('1' x $t);

        say "[$t] Checking: $n";

        foreach my $p (@primes) {
            for (my $q = next_prime($p) ; $q <= $lim ; $q = next_prime($q)) {
                for (my $r = next_prime($q) ; $r <= $lim ; $r = next_prime($r)) {

                    my $num = $n + ($p - 1) * ($q - 1) * ($r - 1);
                    my $den = $p * $q * $r + ($p - 1) * ($q - 1) * ($r - 1);

                    if ($num % $den == 0) {

                        my $s = $num / $den;

                        if (is_prob_prime($s)) {
                            say "[$p, $q, $r, $s] = ", $p * $q * $r * $s;
                        }
                    }
                }
            }
        }
    }
}

find_pqrs();

sub find_pqr {

    my $lim    = 1e4;
    my @primes = @{primes($lim)};

    foreach my $t (15 .. 100) {    # find terms of the form: k = p*q*r

        my $n = Math::GMPz->new('1' x $t);

        say "[$t] Checking: $n";

        foreach my $p (@primes) {
            for (my $q = next_prime($p) ; $q <= $lim ; $q = next_prime($q)) {

                my $num = $n + ($p - 1) * ($q - 1);
                my $den = $p * $q + ($p - 1) * ($q - 1);

                if ($num % $den == 0) {

                    my $r = $num / $den;

                    if (is_prob_prime($r)) {
                        say "[$p, $q, $r] = ", $p * $q * $r;
                    }
                }
            }
        }
    }
}

#~ find_pqr();

sub find_pq {
    foreach my $t (14 .. 100) {    # find terms of the form: k = p*q

        my $n = Math::GMPz->new('1' x $t);
        say "[$t] Checking: $n";

        forprimes {

            my $p   = $_;
            my $num = $n + ($p - 1);
            my $den = $p + ($p - 1);

            if ($num % $den == 0) {

                my $q = $num / $den;

                if (is_prob_prime($q)) {
                    say "[$p, $q] = ", $p * $q;
                }
            }
        } 1e8;
    }
}

#~ find_pq();

__END__
[72431, 76701881] = 5555593942711
[147221, 37736291] = 5555574497311
[327491, 16964021] = 5555564201311
[16964021, 327491] = 5555564201311
[37736291, 147221] = 5555574497311
[76701881, 72431] = 5555593942711
