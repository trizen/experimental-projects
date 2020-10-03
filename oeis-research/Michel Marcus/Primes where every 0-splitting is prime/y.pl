#!/usr/bin/perl

# Daniel "Trizen" Șuteu
# Date: 10 August 2019
# https://github.com/trizen

# !!! UPDATE !!! a(5) does NOT exist!
# https://www.primepuzzles.net/puzzles/puzz_970.htm

# Various techniques to search for an upper-bound for a(5), which is currently unknwon.

use 5.020;
use ntheory qw(:all);
use experimental qw(signatures);
use List::Util qw(uniq);

my @examples_a4;

{
    open my $fh, '<', 'examples_for_a(4).txt';

    while (<$fh>) {
        while (/(\d+)/g) {
            push @examples_a4, $1;
        }
    }

    close $fh;
}

@examples_a4 = uniq(@examples_a4);

say "Total number of a(4) examples: ", scalar(@examples_a4);

sub isok ($p) {

    is_prob_prime($p) || return;

    my @P   = split('0', $p);
    my $end = $#P;

    foreach my $i (0 .. $end - 1) {
        foreach my $j ($i + 1 .. $end) {
            is_prob_prime(join('0', @P[$i .. $j])) || return;
        }
    }

    vecall { is_prob_prime($_) } @P;
}

sub check_small_primes {
    forprimes {

        if (!/0/) {
            say "Testing: $_";

            foreach my $p (@examples_a4) {
                if (isok($p . '0' . $_)) {
                    die "Found: $p 0 $_";
                }

                if (isok($_ . '0' . $p)) {
                    die "Found: $_ 0 $p";
                }
            }
        }

    }
    1e6;
}

foreach my $p (@examples_a4) {
    isok($p) || die "error for p = $p";
}

#my @primes = grep { $_ != 2 } grep { $_ != 5 } grep { !/0/ } @{primes(1e5)};

my @primes;
my %seen;

sub extract_special_primes ($p) {
    if ($p =~ /^30([^0]+)030/) {
        push(@primes, $1) if !$seen{$1}++;
    }

    if ($p =~ /030([^0]+)03\z/) {
        push(@primes, $1) if !$seen{$1}++;
    }
}

foreach my $p (@examples_a4) {
    extract_special_primes($p);
}

#~ forprimes {

#~ if (!/0/) {
#~ if (is_prime('30' . $_) and is_prime($_ . '03') and is_prime("30" . $_ .'03')) {
#~ push(@primes, $_) if !$seen{$_}++;
#~ }
#~ }

#~ } 1e7;

@primes = uniq(3, @primes);

#~ @primes = grep { $_ > 1e10 } @primes;

say "Total number of primes: ", scalar(@primes);

#my @prefix_primes = grep { is_prime("30${_}") } @primes;
#my @suffix_primes = grep { is_prime("${_}03") } @primes;

#~ my @prefix_primes = @special_primes;
#~ my @suffix_primes = @special_primes;

#~ unshift @prefix_primes, 3;
#~ unshift @suffix_primes, 3;

#~ @prefix_primes = uniq(@prefix_primes);
#~ @suffix_primes = uniq(@suffix_primes);

#~ say "Total number of prefix primes: ", scalar(@prefix_primes);
#~ say "Total number of suffix primes: ", scalar(@suffix_primes);

sub generate_from_prefix ($root, $k) {

    #~ return if ($root >= 30281172370306703);

    if ($k >= 4) {
        say "k = $k -> $root";

        extract_special_primes($root);

        if ($k >= 5) {
            die "Found: $root";
        }
    }

    foreach my $p (@primes) {

        my $x = join('0', $root, $p);

        if (isok($x)) {
            __SUB__->($x, $k + 1);
        }
    }
}

sub generate_from_suffix ($root, $k) {

    #~ return if ($root >= 30281172370306703);

    if ($k >= 4) {
        say "k = $k -> $root";

        extract_special_primes($root);

        if ($k >= 5) {
            die "Found: $root";
        }
    }

    foreach my $p (@primes) {

        my $x = join('0', $p, $root);

        if (isok($x)) {
            __SUB__->($x, $k + 1);
        }
    }
}

# Prefix/Suffix small prime from 1123
# Tested from p = 2 up to 2159793272 with k = 2

forprimes {

    if (!/0/) {

        #my $t = "302811723703";

        # 30281172370306703
        # 3067030332163394903

        if (is_prob_prime('30' . $_) and is_prob_prime($_ . '03') and is_prob_prime('30' . $_ . '03')) {
            my $t = "30${_}03";
            generate_from_prefix($t, 2);
            generate_from_suffix($t, 2);
        }

        #~ if (is_prob_prime($_ . '03')) {
        #~ say "Testing: $_";
        #~ generate_from_prefix($_ . '03', 1);
        #~ }

        #~ if (is_prob_prime('30' . $_)) {
        #~ generate_from_suffix('30' . $_, 1);
        #~ }
    }
}
1, 1e11;    # from 22991332421
