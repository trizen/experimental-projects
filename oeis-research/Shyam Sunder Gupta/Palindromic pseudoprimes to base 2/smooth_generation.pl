#!/usr/bin/perl

# Palindromic pseudoprimes (base 2)
# https://oeis.org/A068445

# Known terms:
#   101101, 129921, 1837381, 127665878878566721, 1037998220228997301

use 5.020;
use warnings;

use experimental qw(signatures);

use Math::GMPz;
use ntheory qw(:all);
use List::Util qw(uniq);

sub check_valuation ($n, $p) {
    ($n % $p) != 0;
}

sub smooth_numbers ($limit, $primes) {

    my @h = (1);
    foreach my $p (@$primes) {

        say "Prime: $p";

        foreach my $n (@h) {
            if ($n * $p <= $limit and check_valuation($n, $p)) {
                if (!ref($n) and $n * $p > ~0) {
                    push @h, Math::GMPz::Rmpz_init_set_ui($n) * $p;
                }
                else {
                    push @h, $n * $p;
                }
            }
        }
    }

    return \@h;
}

sub isok ($n) {
    is_pseudoprime($n, 2) and !is_prime($n);
}

my @smooth_primes;

my %orders;
@orders{2, 3, 5, 7, 9, 10, 12, 18, 20, 30, 50, 60, 68, 100, 135, 144, 210, 364, 680, 756} = ();

#@orders{2, 3, 5, 6, 7, 9, 10, 12, 14, 15, 18, 20, 21, 30, 36, 40, 42, 50, 60, 63, 68, 72, 100, 120, 126, 135, 136, 144, 210, 250, 270, 288, 330, 364, 576, 660, 680, 756, 1320, 1360, 4732} = ();

foreach my $p (@{primes(3449)}) {

    if ($p == 2) {
        next;
    }

    #my @f = factor($p - 1);
    #my @d = divisors($p - 1);

    #my $count = grep { powmod(2, $_, $p) == 1 } @d;

    # $count >= 4 || next;

    #my $order = znorder(2, $p);

    #if ($f[-1] <= 7) {
    #if (exists $orders{$order}) {
    #if (vecany { exists($orders{$_}) } grep { powmod(2, $_, $p) == 1} @d) {

    my @p = (5);

    #if (vecany { $_ < 35 } grep { powmod(2, $_, $p) == 1} @d) {
    if (vecall { valuation($p - 1, $_) >= 2 } @p) {
        push @smooth_primes, $p;
    }
}

# Good primes:
#   4951, 4969, 4993, 4999, 5023, 5081, 5101, 5153, 5179, 5209, 5237, 5281, 5419

#@smooth_primes = (4951, 4969, 4993, 4999, 5023, 5081, 5101, 5153, 5179, 5209, 5237, 5281, 5419);

my @factors = (3, 7, 11, 13, 19, 31, 41, 61, 73, 101, 127, 137, 211, 251, 271, 331, 577, 757, 1321, 1361, 4733);

#@smooth_primes = qw(3 7 11 13 19 31 41 61 73 101 127 137 211 251 271 331 577 757 1321 1361 4001 4159 4483 4591 4733);

#push @smooth_primes, @factors;
#push @smooth_primes, grep { $_ < 73 } @factors;
#@smooth_primes = @factors;
#push @smooth_primes, $p;

#push @smooth_primes, grep { is_square_free($_-1) }  @factors;

@smooth_primes = uniq(@smooth_primes);
@smooth_primes = sort { $a <=> $b } @smooth_primes;

#@smooth_primes = grep { $_ <= 739} @smooth_primes;

#@smooth_primes = qw(3 7 11 13 19 31 41 61 73 101 127 137 211 251 271 331 577 757 1321 1361 4733 4801 4861 4951);

say "Smooth primes = (@smooth_primes)";

my $h = smooth_numbers(1e30, \@smooth_primes);

say "\nFound: ", scalar(@$h), " terms\n";

foreach my $n (@$h) {

    if ($n > 1e15 and isok($n)) {

        say $n;

        if ("$n" eq reverse("$n")) {
            say "Palindrome: $n";
            if ($n > ~0) {
                die "Found: $n";
            }
        }
    }
}
