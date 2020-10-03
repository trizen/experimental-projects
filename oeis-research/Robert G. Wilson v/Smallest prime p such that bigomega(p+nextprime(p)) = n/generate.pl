#!/usr/bin/perl

# Generate upper-bounds the smallest prime p such that bigomega(p + nextprime(p)) = n.
# https://oeis.org/A105418

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
#use Math::AnyNum qw(is_smooth);

sub check_valuation ($n, $p) {

    if ($p == 2) {
        return valuation($n, $p) < 225;
    }

    if ($p == 3) {
        return valuation($n, $p) < 15;
    }

    if ($p == 5) {
        return valuation($n, $p) < 5;
    }

    if ($p == 7) {
        return valuation($n, $p) < 5;
    }

    #~ if ($p == 11) {
        #~ return valuation($n, $p) < 2;
    #~ }

    #~ if ($p == 13) {
        #~ return valuation($n, $p) < 2;
    #~ }

    ($n % $p) != 0;
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

sub isok ($n) {
    $n > 1e6 or return 0;
    my $p = prev_prime($n>>1);
    my $q = next_prime($p);
    my $t = addint($p, $q);
    "$t" eq "$n" or return 0;
    scalar factor($t);
}

#~ my @primes =(2, 3, 7, 5, 11, 13, 17, 19, 23, 29,31);
#~ @primes = (2, 3, 5, 79, 83, 89, 97);
#~ my $h = smooth_numbers(1e100, \@primes);
#~ say "\nFound: ", scalar(@$h), " terms";

my %table;
my $h = [];

foreach my $k(3..100) {
    my $z = Math::GMPz->new(1)<<$k;
    foreach my $j(1..1000) {
        #is_smooth($j, 200) || next;
        if (isok($z*$j)) {
            say 'here -> ', $z*$j;
            push @$h, $z*$j;
        }
    }
}

foreach my $n (@$h) {

    my $p = isok($n);

    if ($p >= 30) {
        #say "a($p) = $n -> ", join(' * ', map { "$_->[0]^$_->[1]" } factor_exp($n));
        push @{$table{$p}}, prev_prime($n>>1);
    }
}

say '';

foreach my $k (sort { $a <=> $b } keys %table) {
    say "$k ", vecmin(@{$table{$k}});
}
