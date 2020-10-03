#!/usr/bin/perl

# a(n) is the smallest positive integer such that with the letters of the name of that number we can spell the name of exactly n smaller positive integers.
# https://oeis.org/A317422

use strict;
use warnings;

use 5.014;
use Memoize qw(memoize);
use Number::Spell qw(spell_number);

#memoize('check_letters');
#memoize('count_letters');

my %c1;
my %c2;

sub count_letters {
    my ($n) = @_;
    return $c1{$n} if exists($c1{$n});
    my $s = spell_number($n);
    $s =~ tr/a-z//dc;
    my %h; ++$h{$_} for split(//, $s); $c1{$n} = \%h;
}

sub check_letters {
    my ($n, $k) = @_;

    my $key = "$n $k";
    return $c2{$key} if exists($c2{$key});

    my $h = count_letters($n);
    my $t = count_letters($k);

    foreach my $k (keys %$t) {
        if (not(exists($h->{$k}) and $h->{$k} >= $t->{$k})) {
            $c2{$key} = 0;
            return 0;
        }
    }

    $c2{$key} = 1;
    return 1;
}

sub a {
    my ($i) = @_;
    for (my $n = 1 ; ; ++$n) {
        my $c = 0;
        foreach my $k (1 .. $n - 1) {
            if (check_letters($n, $k)) {
                last if ++$c > $i;
            }
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
