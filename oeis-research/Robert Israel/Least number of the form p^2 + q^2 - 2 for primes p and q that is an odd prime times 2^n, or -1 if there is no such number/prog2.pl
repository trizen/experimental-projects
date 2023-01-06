#!/usr/bin/perl

# a(n) is the least number of the form p^2 + q^2 - 2 for primes p and q that is an odd prime times 2^n, or -1 if there is no such number
# https://oeis.org/A359492

# Known terms:
#   11, 6, -1, 56, 48, 96, 192, 384, 2816, 1536, 109568, 10582016, 12288, 7429922816, 64176128, 4318724096, 196608, 60486975488, 9388028592128

use 5.020;
use strict;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub sum_of_two_squares_solutions ($n) {

    $n < 0  and return [];
    $n == 0 and return [[0, 0]];

    my %sqrtmod_cache;

    my $find_solutions = sub ($factor_exp) {

        my $prod1 = 1;
        my $prod2 = 1;

        my @prod1_factor_exp;

        foreach my $f (@$factor_exp) {
            my ($p, $e) = @$f;
            if ($p % 4 == 3) {    # p = 3 (mod 4)
                $e % 2 == 0 or return;    # power must be even
                $prod2 *= Math::GMPz->new($p)**($e >> 1);
            }
            elsif ($p == 2) {             # p = 2
                if ($e % 2 == 0) {        # power is even
                    $prod2 *= Math::GMPz->new($p)**($e >> 1);
                }
                else {                    # power is odd
                    $prod1 *= $p;
                    $prod2 *= Math::GMPz->new($p)**(($e - 1) >> 1);
                    push @prod1_factor_exp, [$p, 1];
                }
            }
            else {                        # p = 1 (mod 4)
                $prod1 *= Math::GMPz->new($p)**$e;
                push @prod1_factor_exp, $f;
            }
        }

        $prod1 == 1 and return [$prod2, 0];
        $prod1 == 2 and return [$prod2, $prod2];

        my @congruences;

        foreach my $pe (@prod1_factor_exp) {
            my ($p, $e) = @$pe;
            my $pp  = Math::GMPz->new($p)**$e;
            my $key = Math::GMPz::Rmpz_get_str($pp, 10);
            my $r = (
                $sqrtmod_cache{$key} //= sqrtmod(-1, $pp) // do {
                    require Math::Sidef;
                    Math::Sidef::sqrtmod(-1, $pp);
                }
            );
            $r = Math::GMPz->new("$r") if ref($r);
            push @congruences, [[$r, $pp], [$pp - $r, $pp]];
        }

        my @square_roots;

        forsetproduct {
            push @square_roots, Math::GMPz->new(chinese(@_));
        } @congruences;

        my @solutions;

        foreach my $r (@square_roots) {

            my $s = $r;
            my $q = $prod1;

            while ($s * $s > $prod1) {
                ($s, $q) = ($q % $s, $s);
            }

            push @solutions, [$prod2 * $s, $prod2 * ($q % $s)];
        }

        foreach my $pe (@prod1_factor_exp) {
            my ($p, $e) = @$pe;

            for (my $i = $e % 2 ; $i < $e ; $i += 2) {

                my @factor_exp;
                foreach my $pp (@prod1_factor_exp) {
                    if ($pp->[0] == $p) {
                        push(@factor_exp, [$p, $i]) if ($i > 0);
                    }
                    else {
                        push @factor_exp, $pp;
                    }
                }

                my $sq = $prod2 * Math::GMPz->new($p)**(($e - $i) >> 1);

                push @solutions, map {
                    [map { $_ * $sq } @$_]
                } __SUB__->(\@factor_exp);
            }
        }

        return @solutions;
    };

    my @factor_exp = factor_exp($n);
    my @solutions  = $find_solutions->(\@factor_exp);

    #~ @solutions = sort { $a->[0] <=> $b->[0] } do {
        #~ my %seen;
        #~ grep { !$seen{$_->[0]}++ } map {
            #~ [sort { $a <=> $b } @$_]
        #~ } @solutions;
    #~ };

    return \@solutions;
}

sub a($n) {
    my $t = powint(2, $n);

    # 381469721

    forprimes {
        my $solutions = sum_of_two_squares_solutions(addint(mulint($t, $_), 2));

        say "[$n] Checking: p = $_" if @$solutions;

        if (@$solutions and (vecany { is_prime($_->[0]) and is_prime($_->[1]) } @$solutions)) {
            die "Found: a($n) = ", mulint($t, $_);
        }

    } 3, 1e13;

    return -1
}

say a(21);

__END__
Found: a(20) = 214058289594368 at prog2.pl line 143.
perl prog2.pl  1186.26s user 13.50s system 91% cpu 21:46.79 total

Found: a(21) = 896029329195008 at prog2.pl line 143.
perl prog2.pl  2482.54s user 32.97s system 91% cpu 45:54.40 total
