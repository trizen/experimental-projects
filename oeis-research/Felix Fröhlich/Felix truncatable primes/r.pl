#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 12 January 2019
# https://github.com/trizen

# Generate the entire sequence of both-truncatable primes in a given base between 3 and 36.

# Maximum value for each base is given in the following OEIS sequence:
#   https://oeis.org/A323137

# a(17) = 631
# a(18) = ?

# See also:
#   https://www.youtube.com/watch?v=azL5ehbw_24
#   https://en.wikipedia.org/wiki/Truncatable_prime

use 5.010;
use strict;
use warnings;

#use Math::AnyNum;
use ntheory qw(fromdigits is_prob_prime vecmax);

use Math::GMPz;
my $limit = Math::GMPz->new(10)**18;

# 202715129

sub is_right_truncatable {
    my ($n, $base) = @_;

    while (length($n) > 0) {
        is_prob_prime(fromdigits($n, $base)) || return 0;
        chop $n;
    }

    return 1;
}

sub is_left_truncatable {
    my ($n, $base) = @_;

    while (length($n) > 0) {
        is_prob_prime(fromdigits($n, $base)) || return 0;
        $n = substr($n, 1);
    }

    return 1;
}

sub left_truncatable_primes {
    my ($p, $base, $digits) = @_;

      #   if (not is_right_truncatable($p, $base)) {
       #      return ();
       #  }

    #say "left: $p";

    my @seq = ($p);

    foreach my $n (@$digits) {
        my $next = "$n$p";

        my $q = (fromdigits($next, $base));
        if (is_prob_prime($q) && $q < $limit) {
            push @seq, left_truncatable_primes($next, $base, $digits);
        }
  #  }
    }

    return @seq;
}

sub right_truncatable_primes {
    my ($p, $base, $digits) = @_;

        #if (not is_left_truncatable($p, $base)) {
        #     return ();
        # }

    #say "right: $p";

    my @seq = ($p);

    foreach my $n (@$digits) {
        my $next = "$p$n";

        my $q = (fromdigits($next, $base));
        if (is_prob_prime($q) && $q < $limit) {
            push @seq, right_truncatable_primes($next, $base, $digits);
        }
    }

    return @seq;
}

sub both_truncatable_primes_in_base {
    my ($base) = @_;

    if ($base < 3 or $base > 36) {
        die "error: base must be between 3 and 36\n";
    }

    my @digits = (1 .. $base - 1);

    if ($base > 10) {
        @digits = (1 .. 9);
        my $letter = 'a';

        for (1 .. $base - 10) {
            push @digits, $letter;
            ++$letter;
        }
    }

    my @d = grep { is_prob_prime(fromdigits($_, $base)) } @digits;

    my %left;
    my %right;

    foreach my $p (@d) {
        say "Left: $p -> ", scalar(keys %left);
        @left{left_truncatable_primes($p, $base, \@digits)} = ();
        say "Right: $p", scalar(keys %right);
        @right{right_truncatable_primes($p, $base, \@digits)} = ();
    }

    map { fromdigits($_, $base) } grep { exists($right{$_}) } keys(%left);
}

foreach my $base (18) {
    say "Largest both-truncatable prime in base $base is: ", vecmax(both_truncatable_primes_in_base($base));
}

__END__
Largest both-truncatable prime in base 3 is: 23
Largest both-truncatable prime in base 4 is: 11
Largest both-truncatable prime in base 5 is: 67
Largest both-truncatable prime in base 6 is: 839
Largest both-truncatable prime in base 7 is: 37
Largest both-truncatable prime in base 8 is: 1867
Largest both-truncatable prime in base 9 is: 173
Largest both-truncatable prime in base 10 is: 739397
Largest both-truncatable prime in base 11 is: 79
Largest both-truncatable prime in base 12 is: 105691
Largest both-truncatable prime in base 13 is: 379
Largest both-truncatable prime in base 14 is: 37573
Largest both-truncatable prime in base 15 is: 647
Largest both-truncatable prime in base 16 is: 3389
Largest both-truncatable prime in base 17 is: 631
