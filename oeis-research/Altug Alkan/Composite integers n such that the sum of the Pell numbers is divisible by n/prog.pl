#!/usr/bin/perl

# Composite integers n such that the sum of the Pell numbers A000129(0) + ... + A000129(n-1) is divisible by n.
# https://oeis.org/A270345

# These are composite numbers n such that A048739(n) is divible by n.
# These are composite numbers n such that V_n(2, -1) == 2 (mod n).
# These are composite numbers n such that A002203(n)-2 is divisible by n.

# Identities:
#   (A002203(n)-2) / A048739(n-2) = 4
#   A048739(n) = (A002203(n+2)-2)/4

# Terms that are not divisible by 4 are 169, 385, 961, 1105, 1121, 3827, 4901, 6265, 6441, 6601, 7107, 7801, 8119, ...

# See also:
#   https://en.wikipedia.org/wiki/Lucas_pseudoprime

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);

local $| = 1;

sub isok ($n) {
    is_prime($n) and return;
    $n > 1 or return;
    my ($U, $V) = lucas_sequence($n, 2, -1, $n);
    $V == 2;
}

#~ foreach my $n(..1344) {
    #~ print($n, ", ") if isok($n);
#~ }

#~ __END__

my ($V);
my $count = 7714;
foroddcomposites {

    (undef, $V) = lucas_sequence($_, 2, -1, $_);

    if ($V == 2) {
        say "$count $_";
        ++$count;
        exit if ($count > 10_000);
    }

} 7036679161, 1e11;
