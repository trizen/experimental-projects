#!/usr/bin/perl

# a(n) is the first prime p such that, with q the next prime, p^2+q is 10^n times a prime.
# https://oeis.org/A352803

# Previously known terms:
#   2, 523, 2243, 39419, 763031, 37427413

# New terms found:
#   a(6) = 594527413
#   a(7) = 5440486343
#   a(8) = 1619625353
#   a(9) = 35960850223

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

    Math::GMPz::Rmpz_set_ui($z, $p);
    Math::GMPz::Rmpz_mul($z, $z, $z);
    Math::GMPz::Rmpz_add_ui($z, $z, $q);

    my $v = Math::GMPz::Rmpz_remove($z, $z, $ten);

    if (not $seen[$v]) {

        if (Math::GMPz::Rmpz_probab_prime_p($z, 20)) {
            say "a($v) = $p";
            $seen[$v] = $p;
            exit if ($v == 6);
        }
    }

    ($p, $q) = ($q, $_);
} $q+1, $upto_p;

__END__

# PARI/GP program:

isok(n,p,q) = my(v=valuation(p^2+q, 10)); (v == n) && isprime((p^2+q)/10^v);
a(n) = my(p=2); forprime(q=p+1, oo, if(isok(n,p,q), return(p)); p=q); \\ ~~~~
