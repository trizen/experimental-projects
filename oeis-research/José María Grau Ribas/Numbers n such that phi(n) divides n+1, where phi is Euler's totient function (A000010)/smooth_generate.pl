#!/usr/bin/perl

# Numbers n such that phi(n) divides n+1, where phi is Euler's totient function (A000010).
# https://oeis.org/A203966

# Known terms:
#   1, 2, 3, 15, 255, 65535, 83623935, 4294967295, 6992962672132095

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 68;
    }

    #~ if ($p == 11) {
        #~ return valuation($n, $p) < 4;
    #~ }

    #~ if ($p == 29) {
        #~ return valuation($n, $p) < 4;
    #~ }

   # if ($p == 157) {
        return valuation($n, $p) < 4;
  #  }

    #($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (Math::GMPz->new(1));
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

sub isok ($n) {
    is_square_free(subint($n, 1)) || return;
    modint($n, euler_phi(subint($n, 1))) == 0;
}

my $h = smooth_numbers(Math::GMPz->new(10)**40, [2, 11, 29, 2999]);

say "\nFound: ", scalar(@$h), " terms";

foreach my $n (@$h) {

    if ($n >= 6992962672132095 and $n % 2 == 0 and isok($n)) {
        say subint($n, 1);
    }
}
