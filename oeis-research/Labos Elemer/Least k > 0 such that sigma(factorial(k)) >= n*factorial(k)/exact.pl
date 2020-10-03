#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 25 July 2017
# https://github.com/trizen

# An efficient algorithm for computing sigma_k(n!), where k > 0.

use 5.020;
use strict;
use warnings;

use experimental qw(signatures);
use ntheory qw(forprimes vecsum todigits :all);
use Math::AnyNum qw(ipow factorial);

prime_precalc(3e7);

my $t = Math::GMPz::Rmpz_init();

sub sigma_of_factorial ($n) {

    my $sigma = Math::GMPz::Rmpz_init_set_ui(1);

    forprimes {
        my $p = $_;
        my $k = ($n - vecsum(todigits($n, $p))) / ($p - 1);

        if (log($p) * ($k + 1) > log(2) * 63) {

            #$sigma *= ((ipow($p, ($k + 1)) - 1) / ($p - 1));

            Math::GMPz::Rmpz_ui_pow_ui($t, $p, $k + 1);
            Math::GMPz::Rmpz_sub_ui($t, $t, 1);
            Math::GMPz::Rmpz_divexact_ui($t, $t, $p - 1);
            Math::GMPz::Rmpz_mul($sigma, $sigma, $t);
        }
        else {
            #$sigma *= divint(powint($p, $k+1) - 1, $p-1);

            Math::GMPz::Rmpz_mul_ui($sigma, $sigma, divint(powint($p, $k + 1) - 1, $p - 1));
        }
    } $n;

    return $sigma;
}

#say sigma_of_factorial(10, 1);    # sigma_1(10!) = 15334088
#say sigma_of_factorial(10, 2);    # sigma_2(10!) = 20993420690550
#say sigma_of_factorial( 8, 3);    # sigma_3( 8!) = 78640578066960

# Least k > 0 such that sigma(k!) >= n*k!.
#my @array = (1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, 1451, 2549, 4483, 7879, 13859, 24247, 42683, 75037, 131707, 230773);
my @array = (1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, 1451, 2549, 4483, 7879, 13859, 24247, 42683, 75037, 131707, 230773, 405401, 710569, 1246379, 2185021, 3831913, 6720059, 11781551, 20657677);

say "Sanity checking...";

foreach my $n (0 .. $#array) {

    my $k = $array[$n];
    say "Testing: $k";

    my $s = Math::AnyNum->new(sigma_of_factorial($k));
    my $t = $n * factorial($k);
    $s >= $t or die "error for $k";

    next if $k == 1;

    my $s2 = Math::AnyNum->new(sigma_of_factorial($k - 1));
    my $t2 = $n * factorial($k - 1);

    $s2 >= $t2 and die "too large: $k";
}

say "Test passed...";

#say sigma_of_factorial(75037,1);
# 1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, 1451, 2549, 4483, 7879, 13859, 24247, 42683, 75037

my $n = 0;
local $| = '1';

my $k         = 1;
my $factorial = factorial($k);
$factorial = Math::GMPz->new("$factorial");

for (; $k <= 1e6 ; ++$k) {

    while (sigma_of_factorial($k) >= $n * $factorial) {
        print($k, ", ");
        ++$n;
    }

    $factorial *= ($k + 1);
}

__END__
1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, perl r.pl  2.13s user 0.01s system 99% cpu 2.140 total
1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, perl r.pl  0.77s user 0.02s system 99% cpu 0.794 total
1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, perl r.pl  0.77s user 0.02s system 99% cpu 0.788 total
1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, perl r.pl  0.40s user 0.02s system 99% cpu 0.423 total
1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, perl r.pl  0.19s user 0.01s system 99% cpu 0.203 total

1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, 1451, 2549, 4483, perl r.pl  2.94s user 0.01s system 99% cpu 2.967 total
1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, 1451, 2549, 4483, perl r.pl  2.95s user 0.02s system 99% cpu 2.974 total
1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, 1451, 2549, 4483, perl r.pl  2.93s user 0.02s system 98% cpu 3.003 total
