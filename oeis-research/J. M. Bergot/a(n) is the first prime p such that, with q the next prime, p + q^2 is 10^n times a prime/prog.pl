#!/usr/bin/perl

# a(n) is the first prime p such that, with q the next prime, p + q^2 is 10^n times a prime.
# https://oeis.org/A352848

# Known terms:
#   2, 409, 25819, 101119, 3796711, 4160119, 264073519, 2310648079, 165231073519, 9671986711

#~ a(0) = 2
#~ a(1) = 409
#~ a(2) = 25819
#~ a(3) = 101119
#~ a(4) = 3796711
#~ a(5) = 4160119
#~ a(6) = 264073519
#~ a(7) = 2310648079
#~ a(9) = 9671986711

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use Math::GMPz;

my $from_p = 2;
my $upto_p = 1e13;

my ($p, $q) = ($from_p, next_prime($from_p));

my @seen;

my $z = Math::GMPz::Rmpz_init();
my $ten = Math::GMPz::Rmpz_init_set_ui(10);

forprimes {

    Math::GMPz::Rmpz_set_ui($z, $q);
    Math::GMPz::Rmpz_mul($z, $z, $z);
    Math::GMPz::Rmpz_add_ui($z, $z, $p);

    my $v = Math::GMPz::Rmpz_remove($z, $z, $ten);

    if (not $seen[$v]) {

        if (Math::GMPz::Rmpz_probab_prime_p($z, 20)) {
            say "a($v) = $p";
            $seen[$v] = $p;
        }
    }

    ($p, $q) = ($q, $_);
} $q+1, $upto_p;

__END__

# PARI/GP program:

isok(n,p,q) = my(v=valuation(p+q^2, 10)); (v == n) && isprime((p+q^2)/10^v);
a(n) = my(p=2); forprime(q=p+1, oo, if(isok(n,p,q), return(p)); p=q); \\ ~~~~
