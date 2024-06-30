#!/usr/bin/perl

# Lexicographically earliest sequence of numbers whose partial products are all Fermat pseudoprimes to base 2 (A001567).
# https://oeis.org/A374027

# Previously known terms:
#   341, 41, 61, 181, 721, 3061, 6121, 9181, 27541, 36721, 91801, 100981, 238681, 21242521, 67665781, 477361, 48690721, 7160401, 76377601, 35802001

use 5.036;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use Math::GMPz;

# PARI/GP program (faster):
#   my(S=List(341), base=2); my(m = vecprod(Vec(S))); my(L = znorder(Mod(base, m))); print1(S[1], ", "); while(1, forstep(k=lift(1/Mod(m, L)), oo, L, if(gcd(m,k) == 1 && k > 1 && base % k != 0, if((m*k-1) % znorder(Mod(base, k)) == 0, print1(k, ", "); listput(S, k); L = lcm(L, znorder(Mod(base, k))); m *= k; break)))); \\ ~~~~

my @primes = (341);

my $base = 2;
my $m    = Math::GMPz->new(vecprod(@primes));
my $L    = Math::GMPz->new(znorder($base, $m));

say $primes[0];

while (1) {

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();
    my $t = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_invert($v, $m, $L);

    for (my $p = $v ; ; Math::GMPz::Rmpz_add($p, $p, $L)) {

        if (gcd($m, $p) == 1 and $p > 1) {

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
341
41
61
181
721
3061
6121
9181
27541
36721
91801
100981
238681
21242521
67665781
477361
48690721
7160401
76377601
35802001
83394792001
7500519001
60004152001
3420236664001
1380095496001
13110907212001
56583915336001
128003857254001
2760190992001
2969965507392001
71764965792001
1150535931577344001
713092582592208001
13650629438193696001
2037407378834880001
4074814757669760001
12224444273009280001
8544886546833486720001
1586975318114685894720001
86398297306871921280001
863982973068719212800001
474875898533320533612480001
10435680053280029920320001
8787941097498972564480001
101061322621238184491520001
606367935727429106949120001
331076892907176292394219520001
