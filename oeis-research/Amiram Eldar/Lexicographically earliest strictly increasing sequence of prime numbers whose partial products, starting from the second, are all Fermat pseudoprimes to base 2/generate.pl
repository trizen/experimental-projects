#!/usr/bin/perl

# Lexicographically earliest strictly increasing sequence of prime numbers whose partial products, starting from the second, are all Fermat pseudoprimes to base 2 (A001567).
# https://oeis.org/A374029

# Known terms:
#   11, 31, 41, 61, 181, 54001, 54721, 61561, 123121, 225721, 246241, 430921, 523261, 800281, 2400841, 9603361, 28810081, 76826881, 96033601, 15909022209601, 133133396385601, 5791302742773601, 15443473980729601, 61773895922918401, 386086849518240001, 13706083157897520001, 1398406568955065280001, 44872171911558407520001

use 5.036;
use ntheory qw(:all);
use Math::Prime::Util::GMP;
use Math::GMPz;

# PARI/GP program:
#   my(P=List(11),base=2); print1(P[1], ", "); while(1, my(m = vecprod(Vec(P))); my(L = znorder(Mod(base, m))); forstep(p=lift(1/Mod(m, L)), oo, L, if(p > P[#P] && isprime(p) && base % p != 0, if((m*p-1) % znorder(Mod(base, p)) == 0, print1(p, ", "); listput(P, p); break)))); \\ ~~~~

# PARI/GP program (faster):
#   my(P=List(11),base=2); my(m = vecprod(Vec(P))); my(L = znorder(Mod(base, m))); print1(P[1], ", "); while(1, forstep(p=lift(1/Mod(m, L)), oo, L, if(p > P[#P] && isprime(p) && base % p != 0, if((m*p-1) % znorder(Mod(base, p)) == 0, print1(p, ", "); listput(P, p); L = lcm(L, znorder(Mod(base, p))); m *= p; break)))); \\ ~~~~

my @primes = (11);

my $base = 2;
my $m    = Math::GMPz->new(vecprod(@primes));
my $L    = Math::GMPz->new(znorder($base, $m));

while (1) {

    my $u = Math::GMPz::Rmpz_init();
    my $v = Math::GMPz::Rmpz_init();
    my $t = Math::GMPz::Rmpz_init();

    Math::GMPz::Rmpz_invert($v, $m, $L);

    my $prev_p = $primes[-1];

    for (my $p = $v ; ; Math::GMPz::Rmpz_add($p, $p, $L)) {

        if ($p > $prev_p and Math::GMPz::Rmpz_probab_prime_p($p, 10)) {

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
15909022209601
133133396385601
5791302742773601
15443473980729601
61773895922918401
386086849518240001
13706083157897520001
1398406568955065280001
44872171911558407520001
