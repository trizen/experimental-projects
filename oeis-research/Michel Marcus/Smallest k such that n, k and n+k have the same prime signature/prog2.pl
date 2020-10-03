#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 06 March 2019
# https://github.com/trizen

# Smallest k such that n, k and n+k have the same prime signature (canonical form), or 0 if no such number exists.
# https://oeis.org/A085080

# Generalized algorithm for generating numbers that are smooth over a set A of primes, bellow a given limit.

# Found only two upper-bounds for n = {384, 768}, which are in the temporary list of integers <= 1000 for which a(n) is unknown:
#   a(384) <= 1281916327741
#   a(768) <= 1367088016014857

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);

sub check_valuation ($n, $p) {
    my @f = factor_exp($n*$p);
    return 0 if @f > 2;
    vecall { $_->[1] <= 8 }  @f;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (Math::GMPz->new(1));
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                push @h, $n * $p;
            }
        }
    }

    return \@h;
}

#
# Example for finding numbers `m` such that:
#     sigma(m) * phi(m) = n^k
# for some `n` and `k`, with `n > 1` and `k > 1`.
#
# See also: https://oeis.org/A306724
#

my %table;

foreach my $n( (72, 200, 288, 384, 432, 500, 648, 768, 800, 864, 968, 972)) {
    my $sig = join(' ', sort {$a <=> $b} map{$_->[1]}factor_exp($n));
    push @{$table{$sig}}, $n;
}

sub isok ($n) {
    my $sig = join(' ', sort{ $a <=> $b } map{$_->[1]} factor_exp($n));

    if (exists($table{$sig})) {
        foreach my $k(@{$table{$sig}}) {

            if ($sig eq  join(' ', sort{ $a <=> $b } map{$_->[1]} factor_exp($n+$k))) {
                return $k;
            }

            if ($n - $k > 2) {
                if ($sig eq  join(' ', sort{ $a <=> $b } map{$_->[1]} factor_exp($n-$k))) {
                    return $k;
                }
            }
        }
    }

    0;
}

# 1556587 * 7^7
# 4997921 * 11^7
# 923617 * 17^7

#~ my $min = 1367088016014857;

#~ foreach my $p(@{primes(11,100)}) {

    #~ say "Testing prime: $p -- up to ", int($min / $p**8);

    #~ forprimes {

        #~ if (isok($p**8 * $_)) {

            #~ if ($p**8 * $_ < $min) {
                #~ die "Found a smaller one: $_";
            #~ }
        #~ }

    #~ } 1+int($min / $p**8);
#~ }

#~ __END__

foreach my $p(@{primes(2, 100)}) {
    my $base = Math::GMPz->new($p)**3;
    say "Testing: $p";
forprimes {
    my $k = isok($base * $_*$_);
    if ($k) {
        say "Found: $_ * $base -- for k=$k";
    }
} 1e7;
}

__END__
my $h = smooth_numbers(10**50, primes(500));

say "\nFound: ", scalar(@$h), " terms";

my %list;

foreach my $n (@$h) {

    my $p = isok($n);

    if ($p) {
        say "a($p) = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
        push @{$list{$p}}, $n;
    }
}

say '';

foreach my $k (sort { $a <=> $b } keys %list) {
    say "a($k) <= ", vecmin(@{$list{$k}});
}
