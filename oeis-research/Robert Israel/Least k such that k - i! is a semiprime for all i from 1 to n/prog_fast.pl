#!/usr/bin/perl

# a(n) is the least k such that k - i! is a semiprime for all i from 1 to n.
# https://oeis.org/A376332

# Known terms:
#   5, 11, 16, 135, 135, 923, 6083, 71663, 423959, 3995879, 43216583, 489118019, 6233987183, 87199150463

# New terms:
#   a(15) = 1310334397523       (took  2:25 min)
#   a(16) = 20937254735843      (took 15:22 min)
#   a(17) = 355693511854763     (took  6:01 min)

use 5.036;
use ntheory qw(:all);

sub a($n) {

    my $min     = factorial($n);
    my $min_nm1 = factorial($n - 1);
    my $min_nm2 = factorial($n - 2);
    my $min_nm3 = factorial($n - 3);
    my $min_nm4 = factorial($n - 4);

    my @range = map { factorial($_) } reverse(1 .. ($n - 5));

    my $k            = $min;
    my $return_value = undef;

    forsemiprimes {

        $k = $_ + 1;

        if (    $k % 4 == 3
            and is_semiprime($k - $min)
            and is_semiprime($k - $min_nm1)
            and is_semiprime($k - $min_nm2)
            and is_semiprime($k - $min_nm3)
            and is_semiprime($k - $min_nm4)) {
            say "Testing: $k";
            if (vecall { is_semiprime($k - $_) } @range) {
                $return_value = $k;
                lastfor;
                return $return_value;
            }
        }

    } $k, 2 * $k;

    return $return_value;
}

say a(18);
