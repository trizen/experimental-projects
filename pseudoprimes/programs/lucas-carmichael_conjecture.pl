#!/usr/bin/perl

# Lucas-Carmichael numbers: squarefree composite numbers n such that p | n => p+1 | n+1.

# It is not known whether any Lucas–Carmichael number is also a Carmichael number.

# See also:
#   https://oeis.org/A006972
#   https://en.wikipedia.org/wiki/Lucas%E2%80%93Carmichael_number

use 5.020;
use strict;
use warnings;
use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
use Math::AnyNum qw(is_smooth);
use Math::Prime::Util::GMP;

my %seen;
my @nums;

sub is_lucas_carmichael_1 ($n) {
    my $t = $n + 1;
    vecall { $t % ($_ + 1) == 0 } Math::Prime::Util::GMP::factor($n);
}

sub is_lucas_carmichael_2 ($n) {
    vecprod(map { $_ - 1 } grep { is_prime($_ - 1) } map { Math::GMPz->new("$_") } Math::Prime::Util::GMP::divisors($n + 1))
      % $n == 0;
}

while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;

    next if $n < ~0;

    #next if ($n < ~0);

    Math::Prime::Util::GMP::is_pseudoprime($n, 2) || next;
    is_smooth($n, 1e5)                            || next;
    Math::Prime::Util::GMP::is_carmichael($n)     || next;

    if ($n > ((~0) >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    say "Testing: $n";

    is_lucas_carmichael_1($n) || next;

    die "Found counter-example: $n";
}
