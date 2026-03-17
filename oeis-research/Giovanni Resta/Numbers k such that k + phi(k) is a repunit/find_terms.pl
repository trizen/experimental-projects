#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 14 March 2026
# https://github.com/trizen

# Numbers k such that k + phi(k) is a repunit.
# https://oeis.org/A309835

use 5.036;
use ntheory qw(euler_phi is_prob_prime);
use Math::GMPz;

sub find_large_repunit_k {
    my $limit_K = 1e9; # The small cofactor 'K'
    my $limit_N = 100;     # The max length of the repunit (e.g., up to 500 ones)

    say "Starting optimized search for k + phi(k) = R_n...";

    # Loop over ANY integer K (this replaces the p, q, r loops)
    for my $K (1 .. $limit_K) {

        my $phi_K = euler_phi($K);
        my $M = $K + $phi_K;

        # Target modulo: We need R_n % M == target
        my $target = ($M - ($phi_K % $M)) % $M;

        my $R_mod = 0;

        for my $n (1 .. $limit_N) {
            # Compute R_n mod M dynamically. No BigInts used here!
            $R_mod = ($R_mod * 10 + 1) % $M;

            # If the divisibility condition holds, investigate further
            if ($R_mod == $target) {

                # Now we construct the BigInts
                my $Rn  = Math::GMPz->new('1' x $n);
                my $num = $Rn + $phi_K;
                my $s   = $num / $M; # GMPz overloads '/' for division

                # Verify s is prime, and that s doesn't divide K
                if (is_prob_prime($s) && $K % $s != 0) {

                    my $k = Math::GMPz->new($K) * $s;
                    say $k;
                    #say "\nFound a sequence term: k = $k";
                    #say "  => length of repunit n = $n";
                   # say "  => composed of K = $K, s = $s";
                }
            }
        }
    }
}

find_large_repunit_k();

__END__
69182389937106918239031
69182389937106918238993710691823899371069182389937106918239031
66815976110703
5798663
5975946235638859341313216528710061511
75068156510386668202593735
5798663
5555593942711
67514380865879503481683318195579775961247350893127459884953072963972146533454435361821447
5555574497311
5555564201311
5798663
70589291738427354101887409172132553115444760551056101417831
5555564201311
5555574497311
5555593942711
