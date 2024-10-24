#!/usr/bin/perl

# a(n) is the least k such that k - i! is a semiprime for all i from 1 to n.
# https://oeis.org/A376332

# Known terms:
#   5, 11, 16, 135, 135, 923, 6083, 71663, 423959, 3995879, 43216583, 489118019, 6233987183, 87199150463

# New terms:
#   a(15) = 1310334397523       (took 1:05 min)
#   a(16) = 20937254735843
#   a(17) = 355693511854763     (took 2:39 min)

# Lower-bounds:
#   a(18) > 6403070892470783    (took ~7 hours)
#   a(19) > 121645666594440467  (took ~7 hours)

use 5.036;
use ntheory qw(:all);

sub a($n) {     # for n > 5

    my $min     = factorial($n);
    my $min_nm1 = factorial($n - 1);
    my $min_nm2 = factorial($n - 2);
    my $min_nm3 = factorial($n - 3);
    my $min_nm4 = factorial($n - 4);

    my @range = map { factorial($_) } reverse(1 .. ($n - 5));

    my $k            = $min;
    my $return_value = undef;

    forprimes {

        $k = ($_ << 1) + 1;

        if (
                is_semiprime($k - $min)
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

    } $k>>1, $k;

    return $return_value;
}

say a(18);

__END__

a(n) = if(n <= 3, return([5,11,16][n])); my(N=n!, F=vector(n, i, (n - i + 1)!)); forprime(p = N>>1, oo, my(k=2*p+1, ok=1); for(i=1, n, if(bigomega(k - F[i]) != 2, ok=0; break)); ok && return(k)); \\ ~~~~
