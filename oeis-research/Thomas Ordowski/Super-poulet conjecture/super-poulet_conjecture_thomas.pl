#!/usr/bin/perl

use 5.014;
use Math::GMPz;
use ntheory qw(is_prime forprimes);
use Math::Prime::Util::GMP qw(is_pseudoprime divisors powmod);

# Checked up to 57719

# Super-poulet up to p=359

my $t = Math::GMPz->new(0);
my $u = Math::GMPz->new(0);
my $v = Math::GMPz->new(0);

forprimes {
    my $p = $_;

    if (is_prime(($p - 1) >> 1)) {

        print "Testing: $p\n";

        Math::GMPz::Rmpz_ui_pow_ui($t, 2, $p - 1);
        Math::GMPz::Rmpz_sub_ui($t, $t, 1);
        Math::GMPz::Rmpz_divexact_ui($t, $t, 3);

        my @divisors = map { Math::GMPz->new($_) } divisors($t);

        shift @divisors;

        foreach my $d (@divisors) {
            powmod(2, $d, $d) eq '2'
                or die "error for p=$p and d=$d"
        }

        #~ if (is_pseudoprime($t, 2)) {
            #~ ## ok
        #~ }
        #~ else {
            #~ die "counter-example for p=$p";
        #~ }
    }
} 10, 1e6;
