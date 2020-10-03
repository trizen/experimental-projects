#!/usr/bin/perl



use 5.014;
use ntheory qw(forprimes);
use Math::GMPz;

my $k = 220729;
my $n = Math::GMPz->new(2)**$k - 1;

forprimes {
    if (Math::GMPz::Rmpz_divisible_ui_p($n, $_)) {
        say "Found factor: $_";

        if ($_ % $k != 1) {
            die "Counter-example: $_ = ", $_ % $k, " (mod $n)\n";
        }
    }
} 1e8,1e9;
