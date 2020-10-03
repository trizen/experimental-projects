#!/usr/bin/perl

# Erdos construction method for Fermat pseudoprimes:
#   1. Choose an even integer L with many divisors.
#   2. Let P be the set of primes p such that p-1 divides L and p does not divide L.
#   3. Find a subset S of P such that n = prod(S) satisfies 2^(n-1) == 1 (mod n).

use 5.020;
use warnings;

use ntheory qw(:all);
use List::Util qw(uniq);
use experimental qw(signatures);

sub lambda_primes ($L) {

    # Primes p such that `p - kronecker(D,p)` divides L and p does not divide L.

    my $sigma0 = divisor_sum($L, 0);

    $sigma0 < 1e5 or return;

    my @divisors = divisors($L);

    my @A = grep {
              ($_ > 2)
          and (modint($L, $_) != 0)
          #and (modint($_, 8) == 3)
          and is_prime($_)
          #and (kronecker(5,$_) == -1)
          #and (kronecker(-7,$_) == -1)
          #and (kronecker(-11,$_) == -1)
          #and is_smooth(addint($_, 1), 50)

    } map { addint($_, 1) } @divisors;

    return @A;
}

sub fermat_pseudoprimes ($L) {    # smallest numbers first

    my $max   = 1e4;
    my $max_k = 15;

    my @P = lambda_primes($L);

    my @orig = @P;

    foreach my $k (3 .. (@P >> 1)) {

        last if ($k > $max_k);
        ($k % 2 == 1) or next;

        my $count = 0;

        forcomb {

            my $n = Math::Prime::Util::GMP::vecprod(@P[@_]);

            if ($n > ~0 and Math::Prime::Util::GMP::is_pseudoprime($n, 2)) {
                say $n;
            }

            lastfor if (++$count > $max);
        } scalar(@P), $k;

        next if ($count < $max);
        @P     = reverse(@P);
        $count = 0;

        forcomb {

            my $n = Math::Prime::Util::GMP::vecprod(@P[@_]);

            if ($n > ~0 and Math::Prime::Util::GMP::is_pseudoprime($n, 2)) {
                say $n;
            }

            lastfor if (++$count > $max);
        } scalar(@P), $k;
    }

    return;

    @P = @orig;

    my $len = scalar(@P);
    my $t   = Math::Prime::Util::GMP::vecprod(@P);

    foreach my $k (1 .. (@P >> 1)) {

        last if ($k > $max_k);
        (($len - $k) % 2) == 1 or next;

        my $count = 0;

        forcomb {

            my $n = Math::Prime::Util::GMP::divint($t, Math::Prime::Util::GMP::vecprod(@P[@_]));

            if ($n > ~0 and Math::Prime::Util::GMP::is_pseudoprime($n, 2)) {
                say $n;
            }

            lastfor if (++$count > $max);
        } scalar(@P), $k;

        next if ($count < $max);
        @P     = reverse(@P);
        $count = 0;

        forcomb {

            my $n = Math::Prime::Util::GMP::divint($t, Math::Prime::Util::GMP::vecprod(@P[@_]));

            if ($n > ~0 and Math::Prime::Util::GMP::is_pseudoprime($n, 2)) {
                say $n;
            }

            lastfor if (++$count > $max);
        } scalar(@P), $k;
    }
}

#~ foreach my $n(2..1e6) {
#~ $n%2 == 0 or next;
#~ lucas_pseudoprimes($n);
#~ }

#~ __END__
while (<>) {
    chomp;

    #next if ($_ < 1e7);
    #next if ($_ < ~0);
    fermat_pseudoprimes($_);
}

__END__
foreach my $n(2..1e6) {
    $n % 2 == 0 or next;
    lucas_pseudoprimes($n);
}
