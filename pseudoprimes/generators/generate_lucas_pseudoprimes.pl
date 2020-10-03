#!/usr/bin/perl

# Generate Lucas pseudoprimes.

use 5.020;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(kronecker gcd forprimes forcomb factor);
use List::Util qw(uniq first);
use Math::Prime::Util::GMP qw(
    divisors is_pseudoprime vecprod is_carmichael lucas_sequence is_lucas_pseudoprime is_strong_lucas_pseudoprime
    is_extra_strong_lucas_pseudoprime
    is_almost_extra_strong_lucas_pseudoprime
);

sub find_Q ($n, $P=1) {
    for(my $k = 2; $k <= 1000 ; ++$k) {
        my $D = (-1)**$k * (2*$k + 1);

        if (($P*$P - $D)%4 == 0 and kronecker($D, $n) == -1) {
            return (($P*$P - $D) / 4);
        }
    }
    return undef;
}

sub find_P ($n, $Q=1) {
    for(my $P = 3; $P <= 1000 ; ++$P) {
        if (kronecker($P*$P - 4*$Q, $n) == -1) {
            return $P;
        }
    }
    return undef;
}

sub lucasUmod ($P, $Q, $n, $m) {
    (lucas_sequence($m, $P, $Q, $n))[0];
}

sub lucasVmod ($P, $Q, $n, $m) {
    (lucas_sequence($m, $P, $Q, $n))[1];
}

sub lucas_U_order ($P, $Q, $n, $divisors) {
    (first { lucasUmod($P, $Q, $_, $n) == 0 } @$divisors) // ($n+1);
}

sub lucas_V_order ($P, $Q, $n, $divisors) {
    (first {
        my $t = lucasVmod($P, $Q, $_, $n);
        lucasUmod($P, $Q, $_, $n) == 0
            and (($t == 2) || ($t == $n-2))
    } @$divisors) // ($n+1);
}

sub lucas_pseudoprimes {

    my %common_divisors;

    warn "Sieving...\n";

    my @primes;

    #~ while (<>) {
        #~ my $p = (split(' '))[-1] || next;
        #~ $p = Math::GMPz->new($p);
        #~ push @primes, $p;
    #~ }

    forprimes {
        push @primes, $_;
    } 1e3, 1e5;

    foreach my $p (@primes) {

        #~ (factor($p+1))[-1] <= 1e2 or next;
        #~ (factor($p-1))[-1] <= 1e2 or next;

        my $P = 1;
        my $Q = find_Q($p, $P) // next;

        #~ my $Q = -1;
        #~ my $P = find_P($p, $Q) // next;

        $P = +1 if (abs($P) >= $p);
        $Q = -1 if (abs($Q) >= $p);

        my @divisors = divisors($p - kronecker($P*$P - 4*$Q, $p));

        my $z1 = lucas_U_order($P, $Q, $p, \@divisors);
        #my $z2 = lucas_V_order($P, $Q, $p, \@divisors);

        foreach my $d (@divisors) {
            if (
                    gcd($d, $z1) == $z1
                #or gcd($d, $z2) == $z2
            ) {
                foreach my $k (1..5) {
                    push @{$common_divisors{$d*$k}}, $p;
                }
            }
        }
    }

    warn "Combinations...\n";

    foreach my $arr (values %common_divisors) {

        @$arr = uniq(@$arr);
        my $l = $#{$arr} + 1;

        foreach my $k (3 .. $l) {
            forcomb {
                my $n = vecprod(@{$arr}[@_]);

                if ($n > ~0) {
                    if (
                       is_pseudoprime($n, 2)
                    or is_pseudoprime($n, 3)
                    or is_pseudoprime($n, 5)
                    ) {
                        die "Found a Lucas-Fermat number: $n\n";
                    }
                }

                #if ($n > ~0 and is_pseudoprime($n, 2)) {
                #if (is_strong_lucas_pseudoprime($n)) {
                if ($n > 1e14) {

                    if (
                           is_lucas_pseudoprime($n)
                        or is_strong_lucas_pseudoprime($n)
                        or is_extra_strong_lucas_pseudoprime($n)
                        or is_almost_extra_strong_lucas_pseudoprime($n)
                    ) {
                        warn "$n\n";
                        say $n;
                    }
                }
            } $l, $k;
        }
    }
}

lucas_pseudoprimes();
