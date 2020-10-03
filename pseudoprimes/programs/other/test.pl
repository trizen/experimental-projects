#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use Math::GMPz;
use ntheory qw(powmod rootint next_prime);

my $max = 0;

sub is_provable_prime {
    my ($n) = @_;

    return 1 if $n == 2;
    return 0 if powmod(2, $n - 1, $n) != 1;

    # Probably, we can improve this limit even further
    my $limit = rootint($n, 3);

    #(n/log(n,2)).iroot(3)
    #my $limit = rootint(int($n/ntheory::logint($n, 2)), 3);

    my $count = 0;
    for (my $p = 3 ; $p <= $limit ; $p = next_prime($p)) {
        ++$count;
        powmod($p, $n - 1, $n) != 1 and do {

            if ($count > $max) {
                $max = $count;
                say "$n -> $count (p=$p ; limit=$limit) -- ", $p / $limit;
            }
            return 0;
        }
    }

    return 1;
}

my %seen;
my @nums;
while (<>) {
    next if /^\h*#/;
    /\S/ or next;
    my $n = (split(' ', $_))[-1];

    $n || next;
    next if $seen{$n}++;

    #say $. if $. % 10000 == 0;

    if ($n >= (~0 >> 1)) {
        $n = Math::GMPz->new("$n");
    }

    push @nums, $n;

    #is_provable_prime($n) && die "error: $n\n";
    #ntheory::is_prime($n) && die "error: $n\n";
    #ntheory::is_aks_prime($n) && die "error: $n\n";
    #ntheory::miller_rabin_random($n, 7) && die "error: $n\n";
}

@nums = sort { $a <=> $b } @nums;

foreach my $n (@nums) {
    is_provable_prime($n) && warn "error: $n\n";
}
