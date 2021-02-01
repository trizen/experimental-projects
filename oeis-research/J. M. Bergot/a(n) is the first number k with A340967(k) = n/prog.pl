#!/usr/bin/perl

# a(n) is the first number k with A340967(k) = n.
# https://oeis.org/A340969

# Known terms:
#   1, 2, 8, 12, 14, 54, 158, 159, 203, 2159, 5999, 8339, 143098, 85679, 724919, 2417594, 7415099

# New terms:
#   a(17) = 44026799
#   a(18) = 183578399
#   a(19) = 446036579

use 5.014;

use integer;
use ntheory qw(:all);
use experimental qw(signatures);

sub f($n) {

    my $count = 0;
    my $x = $n;

    while ($x > 1) {
        ++$count;
        $x = $n % vecsum(factor($x));
    }

    return $count;
}

say join ', ', map {f ($_) } (1, 2, 8, 12, 14, 54, 158, 159, 203, 2159, 5999, 8339, 143098, 85679, 724919, 2417594, 7415099);

my @table;

foreach my $k (1..2417594) {

    my $r = f($k);

    if (not $table[$r]) {
        $table[$r] = 1;
        say "a($r) = $k";
    }
}

__END__

(PARI)
f(n) = my(x=n,c=0,t); while(x > 1, c++; x = n % ((t=factor(x))[, 1]~*t[, 2])); c; \\ A340967
a(n) = for(k=1, oo, if(f(k) == n, return(k))); \\ ~~~~
