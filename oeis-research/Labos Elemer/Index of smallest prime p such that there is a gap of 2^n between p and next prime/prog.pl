#!/usr/bin/perl

# Index of smallest prime p such that there is a gap of 2^n between p and next prime
# https://oeis.org/A062531

use 5.014;
use ntheory qw(factor prime_count forprimes);
#my $k = 1;
my $p = 2;
my $n = 1;

my $from = 2;
#my $pow = 512;

forprimes {

    my $q = $_;

    #if (scalar(factor($p+$q)) == $n and $n == scalar(factor($q-$p))) {
    #if ($q - $p == 2**$n) {
    if ($q - $p == 2**$n) {
        say "Found: ", prime_count($p), " with ", $p+$q, " and ", $q-$p, ", where p=$p";
        ++$n;
    }

    $p = $_;
    #++$k;
} $from, 1e13;

__END__
% perl y.pl                                                            » /tmp «
Found: 73268943890 with 3998133423294 and 512, where p=1999066711391
perl y.pl  7934.18s user 0.14s system 99% cpu 2:12:21.14 total
