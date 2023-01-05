#!/usr/bin/perl

# a(n) is the least prime p that is the first of three consecutive primes p, q, r such that p^i + q^i - r^i is prime for i from 1 to n but not n+1
# https://oeis.org/A358745

# Known terms:
#   2, 7, 41, 13, 4799, 45631, 332576273

# a(8) = 4001045161 (found by Robert Israel)

# No other terms < 2*10^10. (Michael S. Branicky)

# New term found:
#   a(7) = 157108359787

# PARI/GP program:
#   a(n) = my(p=2, q=nextprime(p+1)); forprime(r=nextprime(q+1), oo, my(c=0); for(k=1, oo, if(isprime(p^k + q^k - r^k), c+=1, break)); if(c==n, return(p)); p = q; q = r); \\ ~~~~

use 5.020;
use warnings;

use ntheory qw(:all);
use Math::Prime::Util::GMP;

#my $from = 4001045161 - 1e7;
#my $upto = 4001045161 + 1e6;

#my $from = 157108359787 - 1e7;
#my $upto = 157108359787 + 1e6;

my $from = 157108359787;
my $upto = powint(10, 13);

my $p = next_prime($from - 1);
my $q = next_prime($p);

my $min_n = 9;
my %seen;

forprimes {

    if (is_prime($p + $q - $_)) {
        my $count = 1;

        for (my $k = 2 ; ; ++$k) {

            #if (is_prime(subint(addint(powint($p, $k), powint($q, $k)), powint($_, $k)))) {
            if (
                Math::Prime::Util::GMP::is_prime(
                                                 Math::Prime::Util::GMP::subint(
                                                                                Math::Prime::Util::GMP::addint(
                                                                                        Math::Prime::Util::GMP::powint($p, $k),
                                                                                        Math::Prime::Util::GMP::powint($q, $k)
                                                                                                              ),
                                                                                Math::Prime::Util::GMP::powint($_, $k)
                                                                               )
                                                )
              ) {
                ++$count;
            }
            else {
                last;
            }
        }

        if ($count >= $min_n and not exists $seen{$count}) {
            say "a($count) = $p";
            $seen{$count} = 1;
        }
    }

    ($p, $q) = ($q, $_);
} next_prime($q), $upto;

__END__
a(7) = 157108359787
^C
perl prog.pl  6641.47s user 20.16s system 94% cpu 1:57:36.31 total
