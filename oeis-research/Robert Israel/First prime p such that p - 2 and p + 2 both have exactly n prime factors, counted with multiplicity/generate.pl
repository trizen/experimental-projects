#!/usr/bin/perl

# a(n) is the first prime p such that p - 2 and p + 2 both have exactly n prime factors, counted with multiplicity.
# https://oeis.org/A371651

# Known terms:
#   5, 23, 173, 2693, 32587, 495637, 4447627, 35303123, 717591877, 928090627, 69692326373, 745041171877, 5012236328123

# New terms:
#   a(14) = 64215009765623
#   a(15) = 945336806640623
#   a(16) = 8885812685546873

use 5.036;
use integer;
use ntheory qw(:all);
use List::Util qw(max);

sub almost_prime_numbers ($A, $B, $k, $callback) {

    $A = max($A, powint(2, $k));

    sub ($m, $lo, $j) {

        if ($j == 1) {

            forprimes {

                if (is_prime($m*$_-2) and is_almost_prime($k, $m*$_-4)) {
                    my $v = $m*$_-2;
                    say "Found upperbound: a($k) <= ", $v;
                    $callback->($v);
                    $B = $v+4 if ($B > $v+4);
                }

            } max($lo, cdivint($A, $m)), divint($B, $m);

            return;
        }

        my $p = $lo;
        my $hi = rootint(divint($B, $m), $j);

        while ($p <= $hi) {
            __SUB__->($m*$p, $p, $j - 1);
            $p = next_prime($p);
        }
    }->(1, 3, $k);
}

my $n = 16;

my $lo = 1;
my $hi = 2*$lo;

while (1) {

    say "Sieving range: [$lo, $hi]";

    my @terms;
    almost_prime_numbers($lo, $hi, $n, sub ($v) { push @terms, $v });
    @terms = sort {$a <=> $b} @terms;

    if (@terms) {
        say "a($n) = $terms[0]";
        last;
    }

    $lo = $hi+1;
    $hi = (3*$lo)/2;
}

__END__

# PARI/GP program:

generate(A, B, n) = A=max(A, 2^n); (f(m, p, j) = my(list=List()); if(j==1, forprime(q=max(p,ceil(A/m)), B\m, my(t=m*q); if(isprime(t-2) && bigomega(t-4) == n, listput(list, t-2))), forprime(q = p, sqrtnint(B\m, j), list=concat(list, f(m*q, q, j-1)))); list); vecsort(Vec(f(1, 3, n)));
a(n) = my(x=2^n, y=2*x); while(1, my(v=generate(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

-----------------------------------------------

Sieving range: [281474976710655, 562949953421310]
Sieving range: [562949953421311, 1125899906842622]
Found upperbound: a(15) <= 945336806640623
a(15) = 945336806640623
perl generate.pl  839.16s user 0.91s system 97% cpu 14:21.07 total

Sieving range: [5885310018362942, 8827965027544413]
Sieving range: [8827965027544414, 13241947541316621]
Found upperbound: a(16) <= 8885812685546873
a(16) = 8885812685546873
perl generate.pl  3837.43s user 13.48s system 90% cpu 1:11:10.85 total
