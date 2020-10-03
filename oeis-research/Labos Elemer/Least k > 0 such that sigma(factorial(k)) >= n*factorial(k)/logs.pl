#!/usr/bin/perl

# Least k > 0 such that sigma(k!) >= n*k!, with a(0) = a(1) = 1.
# https://oeis.org/A061556

# Known terms:
#  1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, 1451, 2549, 4483, 7879, 13859, 24247, 42683, 75037

use 5.020;
use strict;
use warnings;

use experimental qw(signatures);
use ntheory qw(forprimes vecsum todigits :all);
use Math::AnyNum qw(ipow factorial lgamma log );

sub factorial_power ($n, $p) {
    ($n - vecsum(todigits($n, $p))) / ($p - 1);
}

my $t = Math::GMPz::Rmpz_init();

sub sigma_of_factorial ($n) {

    #my $sigma = Math::GMPz::Rmpz_init_set_ui(1);
    my $sigma = 0;

    forprimes {
        my $p = $_;
        my $k = factorial_power($n, $p);

        # (p^(k+1) - 1) / (p-1)
        $sigma += (log($p) * ($k + 1)) - log($p - 1);
    }
    $n;

    return $sigma;
}

say sigma_of_factorial(42683);
say sigma_of_factorial(75037);
say sigma_of_factorial(126000);

# Least k > 0 such that sigma(k!) >= n*k!.
my @array = (1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, 1451, 2549, 4483, 7879, 13859, 24247, 42683, 75037, 131707);
#my @array = (1, 1, 3, 5, 9, 14, 23, 43, 79, 149, 263, 461, 823, 1451, 2549, 4483, 7879, 13859, 24247, 42683, 75037, 131707, 230773, 405401, 710569, 1246379, 2185021, 3831913, 6720059, 11781551, 20657677);

#my @array = (0..12, 1451, 2549, 4483, 7879, 13859, 24247, 42683, 75037, 131707, 230773, 405401, 710569, 1246379, 2185021, 3831913, 6720059, 11781551, 20657677, 36221753, 63503639, 111333529, 195199289, 342243479, 600036989);

say "Sanity checking...";

foreach my $n (0 .. $#array) {

    my $k = $array[$n];
    say "[$n] Testing: $k";

    next if $k < 1000;
    next if $k == 1;

    my $s = Math::AnyNum->new(sigma_of_factorial($k));
    my $t = log($n) + lgamma($k + 1);
    $s >= $t or die "error for $k";

    next if $k < 1000;

    my $s2 = sigma_of_factorial($k - 1);
    my $t2 = log($n) + lgamma($k);

    $s2 >= $t2 and die "too large: $k -- ($s2 >= $t2)";
}

say "Test passed...";

my $n = 21;
local $| = '1';

my $k         = 131707 - 100;
my $factorial = lgamma($k + 1);

#$factorial = Math::GMPz->new("$factorial");

for (; $k <= 1e6 ; ++$k) {

    say "Testing: $k" if ($k % 1000 == 0);

    while (sigma_of_factorial($k) >= log($n) + $factorial) {
        print($k, ", ");

        if ($k > 131707) {
            die "Found: $k";
        }
        ++$n;
    }

    #$factorial *= ($k + 1);
    #Math::GMPz::Rmpz_mul_ui($factorial, $factorial, $k+1);
    $factorial += log($k + 1);
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
