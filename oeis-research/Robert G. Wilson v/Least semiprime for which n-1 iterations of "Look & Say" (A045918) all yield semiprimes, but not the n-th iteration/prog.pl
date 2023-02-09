#!/usr/bin/perl

# Least semiprime for which n-1 iterations of "Look & Say" (A045918) all yield semiprimes, but not the n-th iteration.
# https://oeis.org/A205300

# Known terms:
#   6, 14, 4, 119, 993, 21161, 588821

# a(8) > 10^7. - Tyler Busby, Feb 07 2023

# New terms found:
#   a(8) = 26600591

# Upper-bounds:
#   a(8) <= 39849073

# Lower-bounds:
#   a(9) > 180714047

use 5.020;
use strict;
use warnings;

use ntheory qw(:all);
use List::Util qw(uniq);
use experimental qw(signatures);
use Math::Sidef;

$Sidef::Types::Number::Number::VERBOSE = 1;
$Sidef::Types::Number::Number::USE_YAFU = 1;
$Sidef::Types::Number::Number::USE_FACTORDB = 1;

sub look_and_say ($n) {
    $n =~ s{(?<all>(?<digit>[0-9])\g{digit}*+)}{length($+{all}) . $+{digit}}ger;
}

my @table;

forsemiprimes {

    my $count = 1;
    my $k = look_and_say($_);

    if ($k ne $_) {

        while ((length($k) <= 45) ? is_semiprime($k) : Math::Sidef::is_semiprime($k)) {
            my $next = look_and_say($k);
            if ($next eq $k) {
                $count = -1;
                last;
            }
            $k = $next;
            ++$count;
        }

        if ($count >= 6) {
            say "Checked: $_";
        }

        if ($count > 0 and not $table[$count]) {
            say "a($count) = ", $_;
            $table[$count] = 1;

            if ($count >= 9) {
                die "Found new term: a($count) = $_";
            }
        }
    }

} 180714047, 1e11;
