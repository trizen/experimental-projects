#!/usr/bin/perl

# Try to generate a Carmichael number that is also a Lucas-Carmichael number, from a given list of prime factors.

use 5.036;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use Math::GMPz;

sub carmichael_numbers_in_range ($A, $k, $primes, $callback) {

    my $max_prime = ~0;

    if (vecprod(@$primes) < $A) {
        say "# Too few and too small primes...";
        return;
    }

    $A = vecmax($A, pn_primorial($k));
    $A = Math::GMPz->new("$A");

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();

    my $end = $#{$primes};

    sub ($m, $L1, $L2, $j, $k) {

        if ($k == 1) {

            Math::GMPz::Rmpz_invert($v, $m, $L1) || return;

            my $x = Math::GMPz::Rmpz_init_set($v);

            Math::GMPz::Rmpz_invert($v, $m, $L2) || return;
            Math::GMPz::Rmpz_sub($v, $L2, $v);

            my $y = Math::GMPz::Rmpz_init_set($v);
            my $t = Math::GMPz->new(Math::Prime::Util::GMP::chinese([$x, $L1], [$y, $L2]) || return);

            say "# Checking t = $t with [$L1, $L2] and m = $m";

            my $L3 = Math::GMPz->new(Math::Prime::Util::GMP::lcm($L1, $L2));

            my $reps = 1e4;

            for (my $p = $t ; --$reps > 0 ; Math::GMPz::Rmpz_add($p, $p, $L3)) {
                if (Math::GMPz::Rmpz_probab_prime_p($p, 10) and !Math::GMPz::Rmpz_divisible_p($m, $p)) {
                    Math::GMPz::Rmpz_mul($v, $m, $p);
                    Math::GMPz::Rmpz_add_ui($u, $v, 1);
                    if (Math::GMPz::Rmpz_divisible_p($u, $p + 1)) {
                        $callback->(Math::GMPz::Rmpz_init_set($v));
                        Math::GMPz::Rmpz_sub_ui($u, $v, 1);
                        if (Math::GMPz::Rmpz_divisible_p($u, $p - 1)) {
                            die "Found counter-example: $v";
                            $callback->(Math::GMPz::Rmpz_init_set($v));
                        }
                    }
                }
            }

            return;
        }

        my $z    = Math::GMPz::Rmpz_init();
        my $lcm1 = Math::GMPz::Rmpz_init();
        my $lcm2 = Math::GMPz::Rmpz_init();

        foreach my $congr (7, 11) {
            foreach my $i ($j .. $end) {
                my $p = $primes->[$i];

                #last if ($p > $y);

                #$p % 8 == 3 or next;
                $p % 12 == $congr        or next;    # prime factors must be congruent to each other modulo 12
                gcd($p - 1, $p + 1) == 2 or next;

                #kronecker(5, $p) == -1 or next;

                #is_square_free(($p-1)>>1) or next;
                #is_square_free(($p+1)>>2) or next;

                #(vecall { $_ % 4 == 1} factor(($p-1)>>1)) or next;
                #(vecall { $_ % 4 == 3} factor(($p+1)>>2)) or next;

                #(vecall { $_ % 4 == 3} factor(($p-1)>>1)) or next;
                #(vecall { $_ % 4 == 1} factor(($p+1)>>2)) or next;

                modint(divint(subint(mulint($p, $p), 1), 2), 12) == 0 or next;

                Math::GMPz::Rmpz_gcd($z, $m, $p - 1);
                Math::GMPz::Rmpz_cmp_ui($z, 1) == 0 or next;
                Math::GMPz::Rmpz_gcd($z, $m, $p + 1);
                Math::GMPz::Rmpz_cmp_ui($z, 1) == 0 or next;

                Math::GMPz::Rmpz_lcm($lcm1, $L1, $p - 1);
                Math::GMPz::Rmpz_lcm($lcm2, $L2, $p + 1);

                Math::GMPz::Rmpz_gcd($z, $lcm1, $lcm2);
                Math::GMPz::Rmpz_cmp_ui($z, 2) == 0 or next;

                #~ my $lcm1 = Math::GMPz->new(lcm($L1, $p - 1));
                #~ gcd($lcm1, $m) == 1 or next;

                #~ my $lcm2 = Math::GMPz->new(lcm($L2, $p + 1));
                #~ gcd($lcm2, $m) == 1 or next;

                #~ gcd($lcm1, $lcm2) == 2 or next;

                Math::GMPz::Rmpz_mul_ui($z, $m, $p);

                __SUB__->($z, $lcm1, $lcm2, $i + 1, $k - 1);
            }
        }
      }
      ->(Math::GMPz->new(1), Math::GMPz->new(1), Math::GMPz->new(1), 0, $k);
}

sub is_pomerance_prime ($p) {

    # p == 3 (mod 8) and (5/p) = -1
    # is_congruent(p, 3, 8) && (kronecker(5, p) == -1) &&

    # (p-1)/2 and (p+1)/4 are squarefree
    # is_squarefree((p-1)/2) && is_squarefree((p+1)/4) &&

    # all factors q of (p-1)/2 are q == 1 (mod 4)
    # factor((p-1)/2).all { |q|
    #     is_congruent(q, 1, 4)
    # } &&

    # all factors q of (p+1)/4 are q == 3 (mod 4)
    # factor((p+1)/4).all {|q|
    #    is_congruent(q, 3, 4)
    # }

    # p == 3 (mod 8)
    $p % 8 == 3 or return;

    # (5/p) = -1
    kronecker(5, $p) == -1 or return;

    # (p-1)/2 and (p+1)/4 are squarefree
    (is_square_free(($p - 1) >> 1) and is_square_free(($p + 1) >> 2)) || return;

    # all prime factors q of (p-1)/2 are q == 1 (mod 4)
    (vecall { $_ % 4 == 1 } factor(($p - 1) >> 1)) || return;

    # all prime factors q of (p+1)/4 are q == 3 (mod 4)
    (vecall { $_ % 4 == 3 } factor(($p + 1) >> 2)) || return;

    return 1;
}

use IO::Handle;
open my $fh, '>>', 'carmichael-lucas-carmichael.txt';
$fh->autoflush(1);

my @primes;
my %seen;

while (<>) {
    /^#/ and next;
    my $n = (split(' ', $_))[-1];
    $n = Math::GMPz->new($n);
    if (is_pomerance_prime($n) and !$seen{$n}++) {
        push @primes, $n;
    }
}

@primes = sort { $a <=> $b } @primes;

foreach my $k (5 .. 320) {
    last if ($k > scalar(@primes));
    say "# k = $k -- primes: ", scalar(@primes);
    carmichael_numbers_in_range(Math::GMPz->new(~0), $k, \@primes, sub ($n) { say $n; say $fh $n; });
}
