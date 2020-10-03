#!/usr/bin/perl

# a(n) is the smallest positive integer such that with the letters of the name of that number we can spell the name of exactly n smaller positive integers.
# https://oeis.org/A317422

use strict;
use warnings;

use Memoize qw(memoize);
use Number::Spell qw(spell_number);

memoize('check_letters');
memoize('count_letters');

sub count_letters {
    my ($n) = @_;
    my $s = spell_number($n);
    $s =~ tr/a-z//dc;
    my %h; ++$h{$_} for split(//, $s); \%h;
}

sub check_letters {
    my ($n, $k) = @_;

    my $h = count_letters($n);
    my $t = count_letters($k);

    foreach my $k (keys %$t) {
        return 0 if not(exists($h->{$k}) and $h->{$k} >= $t->{$k});
    }

    return 1;
}

sub a {
    my ($i) = @_;
    for (my $n = 1 ; ; ++$n) {
        my $c = 0;
        foreach my $k (1 .. $n - 1) {
            ++$c if check_letters($n, $k);
        }
        return $n if ($c == $i);
    }
}

my @terms;
foreach my $n (1 .. 50) {
    my $t = a($n);
    print "a($n) = $t\n";
    push @terms, $t;
}

print "\nFirst ", scalar(@terms), " terms: ";
print join(', ', @terms), "\n";

# First 100 terms:
# 15, 13, 14, 21, 24, 72, 76, 74, 113, 115, 121, 171, 122, 150, 131, 142, 127, 147, 124, 129, 159, 138, 135, 153, 137, 156, 126, 125, 128, 165, 168, 157, 158, 467, 289, 265, 267, 487, 275, 392, 278, 754, 692, 492, 257, 857, 572, 524, 674, 428, 1133, 748, 1322, 867, 752, 764, 972, 824, 847, 1391, 1418, 1241, 1280, 1129, 1132, 1124, 1147, 1197, 1480, 1163, 1169, 1277, 1134, 874, 1342, 1361, 1194, 1136, 1229, 1234, 1198, 1239, 1162, 1236, 1152, 1633, 1329, 1138, 1137, 1251, 1146, 1436, 1126, 1153, 1176, 1128, 1577, 1238, 1226, 1452
