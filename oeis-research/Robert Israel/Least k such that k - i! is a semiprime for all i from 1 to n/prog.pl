#!/usr/bin/perl

# a(n) is the least k such that k - i! is a semiprime for all i from 1 to n.
# https://oeis.org/A376332

# Known terms:
#   5, 11, 16, 135, 135, 923, 6083, 71663, 423959, 3995879, 43216583, 489118019, 6233987183, 87199150463

use 5.036;
use ntheory qw(:all);

sub a($n) {

    my $min     = factorial($n);
    my $min_nm1 = factorial($n - 1);
    my $min_nm2 = factorial($n - 2);
    my $min_nm3 = factorial($n - 3);
    my $min_nm4 = factorial($n - 4);

    my @range = map { factorial($_) } reverse(1 .. ($n - 5));

    my $k = divint($min, 4) * 4 + 3;

    while (1) {

        if (    is_semiprime($k - $min)
            and is_semiprime($k - $min_nm1)
            and is_semiprime($k - $min_nm2)
            and is_semiprime($k - $min_nm3)
            and is_semiprime($k - $min_nm4)) {
            say "Testing: $k";
            if (vecall { is_semiprime($k - $_) } @range) {
                return $k;
            }
        }

        $k += 4;
    }
}

say a(14);

__END__

# PARI/GP program:

a(n) = if(n <= 3, return([5,11,16][n])); my(N=n!, k=(N\4)*4+3, F=vector(n, i, (n - i + 1)!), ok=1); while(1, ok=1; for(i=1, n, if(bigomega(k - F[i]) != 2, ok=0; break)); ok && return(k); k += 4); \\ ~~~~
