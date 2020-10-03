#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 23 August 2019
# https://github.com/trizen

# Numbers n such that n+sigma(n) is a repunit number.
# https://oeis.org/A244444

# New terms found:
#   5458110152757191
#   38808343270779723425176258917550576371890625326889683884600092615
#   5555416315084477193803242075128588575040867078261499174304006505314808781061058111

use 5.014;
use warnings;
use ntheory qw(:all);

use Math::GMPz;

sub find_pqrst {

    my $lim    = 1e2;
    my @primes = @{primes($lim)};

    foreach my $z (1 .. 100) {    # find terms of the form: k = p*q*r*s*t

        my $n = Math::GMPz->new('1' x $z);

        say "[$z] Checking: $n";

        foreach my $p (@primes) {
            for (my $q = next_prime($p) ; $q <= $lim ; $q = next_prime($q)) {
                for (my $r = next_prime($q) ; $r <= $lim ; $r = next_prime($r)) {
                    for (my $s = next_prime($r) ; $s <= $lim ; $s = next_prime($s)) {

                        my $num = $n - ($p + 1) * ($q + 1) * ($r + 1) * ($s + 1);
                        my $den = $p * $q * $r * $s + ($p + 1) * ($q + 1) * ($r + 1) * ($s + 1);

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

find_pqrst();

sub find_ppq {

    foreach my $t (10 .. 100) {    # no luck with k = p^2*q

        my $n = Math::GMPz->new('1' x $t);
        say "[$t] Checking: $n";

        forprimes {
            my $p = $_;

            my $num = $n - ($p * $p + $p + 1);
            my $den = (2 * $p * $p + $p + 1);

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

    my $lim    = 1e3;
    my @primes = @{primes($lim)};

    foreach my $t (7 .. 100) {    # find terms of the form: k = p*q*r*s

        my $n = Math::GMPz->new('1' x $t);

        say "[$t] Checking: $n";

        foreach my $p (@primes) {
            for (my $q = next_prime($p) ; $q <= $lim ; $q = next_prime($q)) {
                for (my $r = next_prime($q) ; $r <= $lim ; $r = next_prime($r)) {

                    my $num = $n - ($p + 1) * ($q + 1) * ($r + 1);
                    my $den = $p * $q * $r + ($p + 1) * ($q + 1) * ($r + 1);

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

#~ find_pqrs();

sub find_pqr {

    my $lim    = 1e4;
    my @primes = @{primes($lim)};

    foreach my $t (21 .. 100) {    # find terms of the form: k = p*q*r

        my $n = Math::GMPz->new('1' x $t);

        say "[$t] Checking: $n";

        foreach my $p (@primes) {
            for (my $q = next_prime($p) ; $q <= $lim ; $q = next_prime($q)) {

                my $num = $n - ($p + 1) * ($q + 1);
                my $den = $p * $q + ($p + 1) * ($q + 1);

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
            my $num = $n - ($p + 1);
            my $den = $p + ($p + 1);

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
[13, 17, 29, 79] = 506311
[3, 1587301] = 4761903
[73, 75585789871] = 5517762660583
[3433, 1618044431] = 5554746531623
[198761, 27950863] = 5555541480743
[47, 107, 211, 5143730489] = 5458110152757191
[3, 113, 139762403913347309] = 47379454926624737751
[29, 1736797, 10843170618253636088926607] = 546139199807860751551844463475591
[3, 5, 7, 53, 6973646589538135386374889293360391082100741298632467903791571] = 38808343270779723425176258917550576371890625326889683884600092615
[19949, 278480942156723504626960853933961029376954588112762503098100481493548988974939] = 5555416315084477193803242075128588575040867078261499174304006505314808781061058111
