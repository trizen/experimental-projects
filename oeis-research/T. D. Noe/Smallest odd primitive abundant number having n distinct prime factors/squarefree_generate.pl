#!/usr/bin/perl

# Smallest odd primitive abundant number (A006038) having n distinct prime factors.
# https://oeis.org/A188342

# Known terms:
#   945, 3465, 15015, 692835, 22309287, 1542773001, 33426748355, 1635754104985, 114761064312895, 9316511857401385, 879315530560980695

use 5.036;
use ntheory qw(:all);
use Math::AnyNum qw(:overload);

sub divceil ($x, $y) {    # ceil(x/y)
    (($x % $y == 0) ? 0 : 1) + divint($x, $y);
}

sub almost_prime_numbers ($A, $B, $k, $callback) {

    $A = vecmax($A, powint(3, $k));

    sub ($m, $p, $k) {

        if (divisor_sum($m) > 2*$m) {
            return;
        }

        if ($k == 1) {

            forprimes {
                my $v = mulint($m,$_);
                if (divisor_sum($v) > 2*$v) {
                    my $ok = 1;
                    foreach my $pp (factor_exp($v)) {
                        my $t = divint($v, $pp->[0]);
                        if (divisor_sum($t) > 2*$t) {
                            $ok = 0;
                            last;
                        }
                    }
                    if ($ok) {
                        $B = $v if ($v < $B);
                        $callback->($v);
                    }
                }
            } vecmax($p, divceil($A, $m)), divint($B, $m);

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        while ($p <= $s) {
            my $t = mulint($m,$p);
            if (divceil($A, $t) <= divint($B, $t)) {
                __SUB__->($t, $p + 1, $k - 1);
            }

            $p = next_prime($p);
        }
    }->(1, 3, $k);
}

my $n = 17;

my $x = pn_primorial($n+1)>>1;
my $y = 2*$x;

while (1) {
    my @terms;
    almost_prime_numbers($x, $y, $n, sub ($k) {
        say "# Candidate: $k";
        push @terms, $k;
    });
    if (@terms) {
        @terms = sort {$a <=> $b} @terms;
        say "a($n) = $terms[0]";
        last;
    }
    $x = $y+1;
    $y = 2*$x;
}

__END__

# PARI/GP program:

generate(A, B, n) = A=max(A, vecprod(primes(n+1))\2); (f(m, p, k) = my(list=List()); if(sigma(m) > 2*m, return(list)); if(k==1, forprime(q=max(p, ceil(A/m)), B\m, my(t=m*q); if(sigma(t) > 2*t, my(F=factor(t)[,1], ok=1); for(i=1, #F, if(sigma(t\F[i], -1) > 2, ok=0; break)); if(ok, listput(list, t)))), forprime(q = p, sqrtnint(B\m, k), list=concat(list, f(m*q, q + 1, k-1)))); list); vecsort(Vec(f(1, 3, n)));
a(n) = my(x=vecprod(primes(n+1))\2, y=2*x); while(1, my(v=generate(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~
