#!/usr/bin/perl

# Smallest odd primitive abundant number (A006038) having n distinct prime factors.
# https://oeis.org/A188342

# Known terms:
#   945, 3465, 15015, 692835, 22309287, 1542773001, 33426748355, 1635754104985, 114761064312895, 9316511857401385, 879315530560980695

# a(14)-a(17) confirmed and a(18) from ~~~~

# New terms:
#   a(14) = 88452776289145528645
#   a(15) = 2792580508557308832935
#   a(16) = 428525983200229616718445
#   a(17) = 42163230434005200984080045
#   a(18) = 1357656019974967471687377449
#   a(19) = 189407457935656632167109232619
#   a(20) = 25557786985317796527581223227267
#   a(21) = 3791929072764979008305867397500527
#   a(22) = 456592871291171295882477091922563457
#   a(23) = 82493607122950800851160328361943800977
#   a(24) = 6580451583576921575588712347025824739473
#   a(25) = 847681808538954352055382308703235786893931
#   a(26) = 166644953895103204196531390578084065448147997
#   a(27) = 33906929661678126419817652938259955699588070113

use 5.036;
use ntheory      qw(:all);
use Math::AnyNum qw(:overload);

sub omega_prime_numbers ($A, $B, $k, $callback) {

    $A = vecmax($A, pn_primorial($k));

    sub ($m, $p, $k) {

        if (divisor_sum($m) > 2 * $m) {
            return;
        }

        my $s = rootint(divint($B, $m), $k);

        foreach my $q (@{primes($p, $s)}) {

            my $r = next_prime($q);

            for (my $v = mulint($m, $q) ; $v <= $B ; $v = mulint($v, $q)) {
                if ($k == 1) {

                    if ($v >= $A) {
                        if (divisor_sum($v) > 2 * $v) {
                            my $ok = 1;
                            foreach my $pp (factor_exp($v)) {
                                my $t = divint($v, $pp->[0]);
                                if (divisor_sum($t) > 2 * $t) {
                                    $ok = 0;
                                    last;
                                }
                            }
                            if ($ok) {
                                $B = $v if ($v < $B);
                                $callback->($v);
                            }
                        }
                    }
                }
                else {
                    if (mulint($v, $r) <= $B) {
                        __SUB__->($v, $r, $k - 1);
                    }
                }
            }
        }
      }
      ->(1, 3, $k);
}

my $n = 16;

my $x = pn_primorial($n + 1) >> 1;
my $y = 2 * $x;

while (1) {
    my @terms;
    omega_prime_numbers(
        $x, $y, $n,
        sub ($k) {
            say "# Candidate: $k";
            push @terms, $k;
        }
    );
    if (@terms) {
        @terms = sort { $a <=> $b } @terms;
        say "a($n) = $terms[0]";
        last;
    }
    $x = $y + 1;
    $y = 2 * $x;
}

__END__

# PARI/GP program:

generate(A, B, n) = A=max(A, vecprod(primes(n+1))\2); (f(m, p, j) = my(list=List()); if(sigma(m) > 2*m, return(list)); forprime(q=p, sqrtnint(B\m, j), my(v=m*q); while(v <= B, if(j==1, if(v>=A && sigma(v) > 2*v, my(F=factor(v)[,1], ok=1); for(i=1, #F, if(sigma(v\F[i], -1) > 2, ok=0; break)); if(ok, listput(list, v))), if(v*(q+1) <= B, list=concat(list, f(v, q+1, j-1)))); v *= q)); list); vecsort(Vec(f(1, 3, n)));
a(n) = my(x=vecprod(primes(n+1))\2, y=2*x); while(1, my(v=generate(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~

# Alternative version, accepting min and max as optional arguments

generate(A, B, n) = A=max(A, vecprod(primes(n+1))\2); (f(m, p, j) = my(list=List()); if(sigma(m) > 2*m, return(list)); forprime(q=p, sqrtnint(B\m, j), my(v=m*q); while(v <= B, if(j==1, if(v>=A && sigma(v) > 2*v, my(F=factor(v)[,1], ok=1); for(i=1, #F, if(sigma(v\F[i], -1) > 2, ok=0; break)); if(ok, listput(list, v))), if(v*(q+1) <= B, list=concat(list, f(v, q+1, j-1)))); v *= q)); list); vecsort(Vec(f(1, 3, n)));
a(n, x=vecprod(primes(n+1))\2, y=2*x) = while(1, my(v=generate(x, y, n)); if(#v >= 1, return(v[1])); x=y+1; y=2*x); \\ ~~~~
