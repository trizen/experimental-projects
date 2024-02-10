#!/usr/bin/perl

# Least odd primitive abundant number with n prime factors, counted with multiplicity.
# https://oeis.org/A275449

# Known terms:
#   945, 7425, 81081, 78975, 1468935, 6375105, 85930875, 307879299, 1519691625, 8853249375, 17062700625

# New terms:
#   a(16) = 535868474337
#   a(17) = 2241870572475
#   a(18) = 12759034818375
#   a(19) = 64260996890625
#   a(20) = 866566808687853
#   a(21) = 2964430488515625
#   a(22) = 23849823423763953
#   a(23) = 100139192108634825
#   a(24) = 772934641006640625
#   a(25) = 2696807941801171875

use 5.036;
use ntheory qw(:all);

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
                    $callback->($v) if $ok;
                }
            } vecmax($p, divceil($A, $m)), divint($B, $m);

            return;
        }

        my $s = rootint(divint($B, $m), $k);

        while ($p <= $s) {
            my $t = mulint($m,$p);
            if (divceil($A, $t) <= divint($B, $t)) {
                __SUB__->($t, $p, $k - 1);
            }

            $p = next_prime($p);
        }
    }->(1, 3, $k);
}

my $n = 26;

my $x = powint(3, $n);
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

generate(A, B, n) = A=max(A, 3^n); (f(m, p, k) = my(list=List()); if(k==1, forprime(q=max(p, ceil(A/m)), B\m, my(t=m*q); if(sumdiv(t, d, sigma(d, -1)>2)==1, listput(list, t))), forprime(q = p, sqrtnint(B\m, k), list=concat(list, f(m*q, q, k-1)))); list); vecsort(Vec(f(1, 3, n)));
a(n) = my(x=3^n, y=2*x); while(1, my(v=generate(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

# Faster version

generate(A, B, n) = A=max(A, 3^n); (f(m, p, k) = my(list=List()); if(k==1, forprime(q=max(p, ceil(A/m)), B\m, my(t=m*q); if(sumdiv(t, d, sigma(d, -1)>2)==1, listput(list, t))), forprime(q = p, sqrtnint(B\m, k), if (sigma(m*q) < 2*m*q, list=concat(list, f(m*q, q, k-1))))); list); vecsort(Vec(f(1, 3, n)));
a(n) = my(x=3^n, y=2*x); while(1, my(v=generate(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

# Even faster version

generate(A, B, n) = A=max(A, 3^n); (f(m, p, k) = my(list=List()); if(sigma(m) > 2*m, return(list)); if(k==1, forprime(q=max(p, ceil(A/m)), B\m, if(sumdiv(m*q, d, sigma(d, -1)>2)==1, listput(list, m*q))), forprime(q = p, sqrtnint(B\m, k), list=concat(list, f(m*q, q, k-1)))); list); vecsort(Vec(f(1, 3, n)));
a(n) = my(x=3^n, y=2*x); while(1, my(v=generate(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

# Fastest version

generate(A, B, n) = A=max(A, 3^n); (f(m, p, k) = my(list=List()); if(sigma(m) > 2*m, return(list)); if(k==1, forprime(q=max(p, ceil(A/m)), B\m, my(t=m*q); if(sigma(t) > 2*t, my(F=factor(t)[,1], ok=1); for(i=1, #F, if(sigma(t\F[i], -1) > 2, ok=0; break)); if(ok, listput(list, t)))), forprime(q = p, sqrtnint(B\m, k), list=concat(list, f(m*q, q, k-1)))); list); vecsort(Vec(f(1, 3, n)));
a(n) = my(x=3^n, y=2*x); while(1, my(v=generate(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~
