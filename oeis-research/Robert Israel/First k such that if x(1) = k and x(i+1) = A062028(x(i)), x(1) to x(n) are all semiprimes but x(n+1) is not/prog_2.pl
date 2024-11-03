#!/usr/bin/perl

# a(n) is the first k such that if x(1) = k and x(i+1) = A062028(x(i)), x(1) to x(n) are all semiprimes but x(n+1) is not.
# https://oeis.org/A376693

# New terms:
#   a(13) = 471779113

use 5.036;
use ntheory qw(:all);
use Math::GMPz;

my @table;
my ($count, $t, $k);

while (<>) {

    chomp($k = $_);
    $k || next;

    $count = 1;
    $t = Math::GMPz->new($k) + sumdigits($k);

    while (is_semiprime($t)) {
        $t = Math::GMPz->new($t) + sumdigits($t);
        ++$count;
    }

    if ($count >= 13 and !$table[$count]) {
        say "a($count) = ", $k;
        $table[$count] = 1;
    }
}

__END__
a(1) = 4
a(2) = 15
a(3) = 22
a(5) = 33
a(4) = 39
a(6) = 291
a(7) = 23174
a(8) = 90137
a(9) = 119135
a(11) = 1641337
a(10) = 1641362
a(12) = 7113362
a(13) = 471779113

# PARI/GP program:

a(n) = if(n==0, return(1)); for(k=1, oo, if(bigomega(k) == 2, my(c=1, t=k+sumdigits(k)); while(bigomega(t) == 2, c += 1; t += sumdigits(t)); if(c == n, return(k)))); \\ ~~~~
