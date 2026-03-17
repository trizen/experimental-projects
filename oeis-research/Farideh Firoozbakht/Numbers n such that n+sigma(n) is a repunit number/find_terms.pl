#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 14 March 2026
# https://github.com/trizen

# Numbers n such that n+sigma(n) is a repunit number.
# https://oeis.org/A244444

use 5.036;
use ntheory qw(divisor_sum is_prob_prime);
use Math::GMPz;

sub find_sigma_repunit_k {
    my $limit_K = 1e9; # The small cofactor 'K'
    my $limit_N = 100;     # The max length of the repunit (e.g., up to 500 ones)

    say "Starting optimized search for k + sigma(k) = R_n...";

    for my $K (1 .. $limit_K) {

        my $sigma_K = divisor_sum($K);
        my $M = $K + $sigma_K;

        # Target modulo: We need R_n % M == sigma_K % M
        my $target = $sigma_K % $M;

        my $R_mod = 0;

        for my $n (1 .. $limit_N) {
            # Compute R_n mod M dynamically
            $R_mod = ($R_mod * 10 + 1) % $M;

            if ($R_mod == $target) {

                my $Rn  = Math::GMPz->new('1' x $n);

                # Ensure Rn is large enough to yield a positive s
                if ($Rn > $sigma_K) {
                    my $num = $Rn - $sigma_K;
                    my $s   = $num / $M;

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
}

find_sigma_repunit_k();

__END__
5
4761903
5517762660583
506767303
47379454926624737751
42253521126760563380281690140845070421983
5554746531623
38808343270779723425176258917550576371890625326889683884600092615
506311
506311
5555416315084477193803242075128588575040867078261499174304006505314808781061058111
506311
506311
5555541480743
5458110152757191
4761903
484912468871110034058062882695085908065763399
506767303
5555541480743
546139199807860751551844463475591
506767303
45171625279943274951
