#!/usr/bin/perl

# Lexicographically earliest sequence of prime numbers whose partial products, starting from the second, are all Fermat pseudoprimes to base 2 (A001567).
# https://oeis.org/A374028

# First few terms:
#   11, 31, 41, 61, 181, 54001, 6841, 54721, 110017981, 13681, 20521, 61561, 123121, 225721, 246241, 205201, 410401, 1128601, 513001, 3078001, 4617001, 73442619001, 96993612810001, 55404001, 7188669001, 16773561001, 67094244001, 821904489001, 29370505311001

use 5.036;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use Math::GMPz;

# PARI/GP program:
#   my(P=List(11), base=2); my(m = vecprod(Vec(P))); my(L = znorder(Mod(base, m))); print1(P[1], ", "); while(1, forstep(p=lift(1/Mod(m, L)), oo, L, if(isprime(p) && m % p != 0 && base % p != 0, if((m*p-1) % znorder(Mod(base, p)) == 0, print1(p, ", "); listput(P, p); L = lcm(L, znorder(Mod(base, p))); m *= p; break))));

my @primes = (11);

my $base = 2;
my $m    = Math::GMPz->new(vecprod(@primes));
my $L    = Math::GMPz->new(znorder($base, $m));

while (1) {

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();
    my $t = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_invert($v, $m, $L);

    for (my $p = $v ; ; Math::GMPz::Rmpz_add($p, $p, $L)) {

        if (Math::GMPz::Rmpz_probab_prime_p($p, 5) && !Math::GMPz::Rmpz_divisible_p($m, $p)) {

            Math::GMPz::Rmpz_mul($u, $m, $p);
            Math::GMPz::Rmpz_sub_ui($u, $u, 1);

            Math::GMPz::Rmpz_set_str($t, Math::Prime::Util::GMP::znorder($base, $p), 10);

            if (Math::GMPz::Rmpz_divisible_p($u, $t)) {
                say $p;
                push @primes, Math::GMPz::Rmpz_init_set($p);
                $L = Math::GMPz->new(lcm($L, $t));
                $m *= $p;
                last;
            }
        }
    }
}

__END__
31
41
61
181
54001
6841
54721
110017981
13681
20521
61561
123121
225721
246241
205201
410401
1128601
513001
3078001
4617001
73442619001
96993612810001
55404001
7188669001
16773561001
67094244001
821904489001
29370505311001
91281718962001
18014804514001
45037011285001
225185056425001
10358512595550001
56971819275525001
145019176337700001
217528764506550001
870115058026200001
1160153410701600001
6815901287871900001
68159012878719000001
112980379747764614400001
245426973573691375200001
