#!/usr/bin/perl

# Smallest number k such that k-n and k+n are consecutive primes and k has exactly n distinct prime factors.
# https://oeis.org/A382110

# Known terms:
#   4, 15, 154, 3045, 22386, 2467465, 3015870, 368961285, 6326289970

# New terms:
#   4, 15, 154, 3045, 22386, 2467465, 3015870, 368961285, 6326289970, 2313524242029, 1568018377380, 5808562826801735, 1575649493651310, 6177821212870783905, 171718219950879367766, 2039004035049368722335, 13156579658122684173390, 112733682549950000276753015, 44458166014178870651768070, 644137715353904311581311377107

# Lower-bounds:
#   a(21) > 3802951800684688204490109616127

=for comment

# PARI/GP program:

generate(A, B, n) = A=max(A, vecprod(primes(n))); (f(m, p, j) = my(list=List()); forprime(q=p, sqrtnint(B\m, j), my(v=m*q); while(v <= B, if(j==1, if(v>=A && (nextprime(v) - v == n) && (v - precprime(v) == n), listput(list, v)), if(v*(q+1) <= B, list=concat(list, f(v, q+1, j-1)))); v *= q)); list); vecsort(Vec(f(1, if(n%2 == 0, 3, 2), n)));
a(n) = my(x=vecprod(primes(n)), y=2*x); while(1, my(v=generate(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

=cut

use 5.036;
use Math::GMPz;
use ntheory qw(:all);

sub omega_prime_numbers ($A, $B, $k) {

    my $diff = $k;

    $A = vecmax($A, pn_primorial($k));
    $A = Math::GMPz->new("$A");
    $B = Math::GMPz->new("$B");

    my $u = Math::GMPz::Rmpz_init();

    my @values = sub ($m, $lo, $j) {

        Math::GMPz::Rmpz_tdiv_q($u, $B, $m);
        Math::GMPz::Rmpz_root($u, $u, $j);

        my $hi = Math::GMPz::Rmpz_get_ui($u);

        if ($lo > $hi) {
            return;
        }

        my @lst;
        my $v = Math::GMPz::Rmpz_init();

        foreach my $q (@{primes($lo, $hi)}) {

            Math::GMPz::Rmpz_mul_ui($v, $m, $q);

            while (Math::GMPz::Rmpz_cmp($v, $B) <= 0) {
                if ($j == 1) {
                    if (Math::GMPz::Rmpz_cmp($v, $A) >= 0) {

                        Math::GMPz::Rmpz_nextprime($u, $v);
                        Math::GMPz::Rmpz_sub($u, $u, $v);

                        if (Math::GMPz::Rmpz_cmp_ui($u, $diff) == 0) {

                            Math::GMPz::Rmpz_prevprime($u, $v);
                            Math::GMPz::Rmpz_sub($u, $v, $u);

                            if (Math::GMPz::Rmpz_cmp_ui($u, $diff) == 0) {
                                push @lst, Math::GMPz::Rmpz_init_set($v);
                            }
                        }
                    }
                }
                else {
                    push @lst, __SUB__->($v, $q + 1, $j - 1);
                }
                Math::GMPz::Rmpz_mul_ui($v, $v, $q);
            }
        }

        return @lst;
      }
      ->(Math::GMPz->new(1), (($diff % 2 == 0) ? 3 : 2), $k);

    sort { Math::GMPz::Rmpz_cmp($a, $b) } @values;
}

my $n = 21;
my $lo = Math::GMPz->new(2);
my $hi = 2*$lo;

while (1) {

    say "Sieving for n = $n: [$lo, $hi]";

    my @terms = omega_prime_numbers($lo, $hi, $n);

    if (@terms) {
        say "Terms: @terms";
        die "Found new term: a($n) = $terms[0]";
    }

    $lo = $hi+1;
    $hi = 2*$lo;
}

__END__
Found new term: a(10) = 2313524242029 at x.sf line 67.
Found new term: a(11) = 1568018377380 at x.sf line 67.
Found new term: a(12) = 5808562826801735 at x.sf line 67.
Found new term: a(13) = 1575649493651310 at x.sf line 67.
Found new term: a(14) = 6177821212870783905 at x.sf line 68.
Found new term: a(15) = 171718219950879367766 at prog_mpz.pl line 91.
Found new term: a(16) = 2039004035049368722335 at prog_mpz.pl line 91.
Found new term: a(17) = 13156579658122684173390 at prog_mpz.pl line 93.
Found new term: a(18) = 112733682549950000276753015 at prog_mpz.pl line 93.
Found new term: a(19) = 44458166014178870651768070 at prog_mpz.pl line 85.
Found new term: a(20) = 644137715353904311581311377107 at prog_mpz.pl line 85.


__END__

 % time perl prog_mpz.pl
Terms: 171718219950879367766
Found new term: a(15) = 171718219950879367766 at prog_mpz.pl line 91.
perl prog_mpz.pl  1825.71s user 0.54s system 98% cpu 30:51.03 total

__END__

Sieving for n = 21: [1901475900342344102245054808063, 3802951800684688204490109616126]
Sieving for n = 21: [3802951800684688204490109616127, 7605903601369376408980219232254]
^C
perl prog_mpz.pl  6115.55s user 1.68s system 99% cpu 1:42:22.77 total
