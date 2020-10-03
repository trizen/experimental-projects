#!/usr/bin/perl

# a(n) is the least number such that the n-th prime is the least coprime quadratic nonresidue modulo a(n).
# https://oeis.org/A306493

#b(p, k) = gcd(p, k)==1&&!issquare(Mod(p, k))
#a(n) = my(k=1); while(sum(i=1, n-1, b(prime(i), k))!=0 || !b(prime(n), k), k++); k


use 5.014;
use ntheory qw(:all);

my $n = 6;
my $p = nth_prime($n);

sub leastNonRes {
    my ($p) = @_;

    for(my $q = 2; ; ++$q) {
        if (kronecker($q, $p) != 1) {
            return $q;
        }
    }
}

sub a {
    my ($n) = @_;

    my $pn = nth_prime($n);
    my $an = nth_prime(1);

    for (;;) {
        my $k = leastNonRes($an);
        if ($pn == $k) {
            return $k;
        }
        $an = next_prime($an);
    }

}

#say a(10);

foreach my $n(2..20) {
    say a($n);
}

__END__
foreach my $k(1..1e6) {
    if (gcd($k, $p) == 1 and kronecker($k, $p) == -1) {
        say $k;
        last;
    }
}

__END__

leastNonRes[p_] := For[q = 2, True, q = NextPrime[q], If[JacobiSymbol[q, p] != 1, Return[q]]]; a[1] = 3; a[n_] := For[pn = Prime[n]; k = 1, True, k++, an = Prime[k]; If[pn == leastNonRes[an], Print[n, " ", an];  Return[an]]]; Array[a, 20] (* Jean-François Alcover, Nov 28 2015 *)

use 5.014;
use ntheory qw(:all);

#foreach my $n(408203125..8408203125) {
    #my $n = $k * 5**14;
   # my $n = int(rand(8408203125-408203125)) + 408203125;
 #   if (powmod(5, $n, 10**length($n)) eq $n) {
  #      say "Found: $n";
   # }
#}


use Math::AnyNum qw(:overload);

my $t = 5;

for (1..20) {

    foreach my $k(1..1e6) {

        my $n = Math::AnyNum->new("$k$t");
        if (powmod(5, $n, 10**length($n)) == $n) {
            say $n;
            $t = $n;
            last;
        }
    }

}


__END__

8408203125, 18408203125, 618408203125, 2618408203125, 52618408203125, 152618408203125, 3152618408203125


      8408203125
     18408203125
    618408203125
   2618408203125
  52618408203125
 152618408203125
3152618408203125
