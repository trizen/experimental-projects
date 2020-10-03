#!/usr/bin/perl

# Erdos construction method for Lucas D-pseudoprimes, for discriminant D = P^2-4Q:
#   1. Choose an even integer L with many divisors.
#   2. Let P be the set of primes p such that p-kronecker(D,p) divides L and p does not divide L.
#   3. Find a subset S of P such that n = prod(S) satisfies U_n(P,Q) == 0 (mod n) and kronecker(D,n) == -1.

# Alternatively:
#   3. Find a subset S of P such that n = prod(P) / prod(S) satisfies U_n(P,Q) == 0 (mod n) and kronecker(D,n) == -1.

use 5.020;
use warnings;

use ntheory qw(:all);
use List::Util qw(uniq);
use experimental qw(signatures);

sub lambda_primes ($L, $D) {

    # Primes p such that `p - kronecker(D,p)` divides L and p does not divide L.

    my @divisors = divisors($L);

    my @A = grep { ($_ > 2) and is_prime($_) and ($L % $_ != 0) and kronecker($D, $_) == -1 } map { $_ - 1 } @divisors;

    return @A;

    my @B = grep { ($_ > 2) and is_prime($_) and ($L % $_ != 0) and kronecker($D, $_) == +1 } map { $_ + 1 } @divisors;

    sort { $a <=> $b } uniq(@A, @B);
}

sub lucas_pseudoprimes ($L, $P = 1, $Q = -1) {    # smallest numbers first

    my $max = 1e2;
    my $max_k = 5;

    my $D = ($P * $P - 4 * $Q);
    my @P = lambda_primes($L, $D);

    my @orig = @P;

    foreach my $k (3 .. (@P>>1)) {

        last if ($k > $max_k);
        ($k % 2 == 1) or next;

        my $count = 0;

        forcomb {

            my $n = Math::Prime::Util::GMP::vecprod(@P[@_]);
            #my $k = Math::Prime::Util::GMP::kronecker($D, $n);

            if ( $n > 1e12 and Math::Prime::Util::GMP::is_lucas_pseudoprime($n)) { #and (lucas_sequence($n, $P, $Q, $n - $k))[0] == 0) {
                say $n;
            }

            lastfor if (++$count > $max);
        } scalar(@P), $k;

        next if ($count < $max);
        @P = reverse(@P);
        $count = 0;

        forcomb {

            my $n = Math::Prime::Util::GMP::vecprod(@P[@_]);
            #my $k = Math::Prime::Util::GMP::kronecker($D, $n);

            if ( $n > 1e12 and Math::Prime::Util::GMP::is_lucas_pseudoprime($n)) { #and (lucas_sequence($n, $P, $Q, $n - $k))[0] == 0) {
                say $n;
            }

            lastfor if (++$count > $max);
        } scalar(@P), $k;
    }

    @P = @orig;

    my $len = scalar(@P);
    my $t = Math::Prime::Util::GMP::vecprod(@P);

    foreach my $k (1 .. (@P>>1)) {

        last if ($k > $max_k);
        (($len - $k) % 2) == 1 or next;

        my $count = 0;

        forcomb {

            my $n = Math::Prime::Util::GMP::divint($t, Math::Prime::Util::GMP::vecprod(@P[@_]));
            #my $k = Math::Prime::Util::GMP::kronecker($D, $n);

            if ( $n > 1e12 and Math::Prime::Util::GMP::is_lucas_pseudoprime($n)) { #and (lucas_sequence($n, $P, $Q, $n - $k))[0] == 0) {
                say $n;
            }

            lastfor if (++$count > $max);
        } scalar(@P), $k;

        next if ($count < $max);
        @P = reverse(@P);
        $count = 0;

        forcomb {

            my $n = Math::Prime::Util::GMP::divint($t, Math::Prime::Util::GMP::vecprod(@P[@_]));
            #my $k = Math::Prime::Util::GMP::kronecker($D, $n);

            if ( $n > 1e12 and Math::Prime::Util::GMP::is_lucas_pseudoprime($n)) { #and (lucas_sequence($n, $P, $Q, $n - $k))[0] == 0) {
                say $n;
            }

            lastfor if (++$count > $max);
        } scalar(@P), $k;
    }
}

while(<>) {
    chomp;
    #next if ($_ < 1e6);
    lucas_pseudoprimes($_);
}

__END__
foreach my $n(2..1e6) {
    $n % 2 == 0 or next;
    lucas_pseudoprimes($n);
}
